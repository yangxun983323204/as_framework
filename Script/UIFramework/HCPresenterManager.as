// 某类视图控制器的列表
class UHCPresenterList
{
	UPROPERTY()
	TSubclassOf<UHCPresenterBase_AS> Type;

	UPROPERTY()
	TArray<UHCPresenterBase_AS> Presenters;
}

// 视图控制器管理器
class UHCPresenterManager_AS : UScriptWorldSubsystem
{
	private uint32 GenId;

	UPROPERTY()
	private TMap<TSubclassOf<UHCPresenterBase_AS>, UHCPresenterList> AllPresenters;

	UPROPERTY()
	private UHCViewManager_AS ViewManager;
	UFUNCTION(BlueprintPure)
	UHCViewManager_AS GetViewManager(){return ViewManager;}

	UPROPERTY()
	private FMessageDelegate InputTypeChangeDelegate;

	UPROPERTY()
	private TArray<UHCPresenterBase_AS> PresenterQueue;

	// 获取当前的控制器队列数组的复制，越靠后的越后打开
	TArray<UHCPresenterBase_AS> GetPresenterQueue()
	{
		TArray<UHCPresenterBase_AS> NewArray;
		NewArray.Append(PresenterQueue);
		return NewArray;
	}

	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
		ViewManager = Cast<UHCViewManager_AS>(NewObject(this, UHCViewManager_AS::StaticClass()));
	}

	UFUNCTION(BlueprintOverride)
	void OnWorldBeginPlay()
	{
		ViewManager.Init();

		auto Id = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::Change);
		InputTypeChangeDelegate.BindUFunction(this, n"OnInputTypeChange");
		UMessageCenter::Instance.Listen(InputTypeChangeDelegate, Id);
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
		if (UMessageCenter::Instance != nullptr)
		{
			auto Id = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::Change);
			UMessageCenter::Instance.UnListen(InputTypeChangeDelegate, Id);
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		ViewManager.Tick(DeltaTime);
	}

	UFUNCTION()
	void OnInputTypeChange(int Id, FString Arg)
	{
		ReopenAll();
	}

	// 打开或查找到视图控制器实例
	UFUNCTION()
	UHCPresenterBase_AS Open(TSubclassOf<UHCPresenterBase_AS> Type, UObject CustomInitData = nullptr)
	{
		if (Type == nullptr)
		{
			FString ErrorMsg = "Type == nullptr";
			Error(ErrorMsg);
			Print(ErrorMsg, 10, FLinearColor::Red);
			return nullptr;
		}
		bool bMultiInstance = Cast<UHCPresenterBase_AS>(Type.Get().DefaultObject).bMultiInstance;
		UHCPresenterList List = Cast<UHCPresenterList>(NewObject(nullptr, UHCPresenterList::StaticClass()));
		auto bFound = AllPresenters.Find(Type, List);
		if (!bFound || List.Presenters.Num() <= 0 || bMultiInstance)
		{
			auto NewPresenter = NewPresenter(Type, nullptr, CustomInitData);
			List.Type = Type;
			List.Presenters.Add(NewPresenter);
			PresenterQueue.Add(NewPresenter);
			AllPresenters.Add(Type, List);
			NewPresenter.OnOpened();
			return NewPresenter;
		}
		else
		{
			auto First = List.Presenters[0];
			// @think 是否更新队列顺序？
			return First;
		}
	}

	// 新附加或获取已附加到子视图的控制器实例
	UFUNCTION()
	UHCPresenterBase_AS AttachToSubview(UHCViewBase_AS View, TSubclassOf<UHCPresenterBase_AS> Type, UObject CustomInitData = nullptr)
	{
		check(View != nullptr);
		if (ViewManager.IsRootView(View))
		{
			Error(f"{View}不是一个子视图，因此不能被附加控制器");
			return nullptr;
		}

		if (View.Presenter != nullptr)
		{
			if (View.Presenter.ClassPrivate.IsChildOf(Type))
			{
				return View.Presenter;
			}
			else
			{
				Error(f"{View}子视图已附加一个不同类型的控制器:{View.Presenter}");
				return nullptr;
			}
		}

		auto NewPresenter = NewPresenter(Type, View, CustomInitData);
		NewPresenter.OnOpened();
		return NewPresenter;
	}

	// 关闭并销毁视图控制器
	UFUNCTION()
	void Close(UHCPresenterBase_AS Presenter)
	{
		if (Presenter.bIsRelased__)
			return;

		Presenter.bIsRelased__ = true;
		UHCPresenterList List;
		Presenter.OnWillClose();
		ReleasePresenter(Presenter);
		auto bFound = AllPresenters.Find(Presenter.ClassPrivate, List);
		if (bFound)
		{
			PresenterQueue.Remove(Presenter);
			List.Presenters.Remove(Presenter);
		}
		Presenter.OnClosed();
	}

	// 关闭并销毁所有视图控制器
	UFUNCTION()
	void ClearAll()
	{
		for (auto KV : AllPresenters)
		{
			for (auto Presenter : KV.Value.Presenters)
			{
				Presenter.OnWillClose();
				ReleasePresenter(Presenter);
				Presenter.OnClosed();
			}
		}
		PresenterQueue.Empty();
		AllPresenters.Empty();
	}

	// 关闭再重新打开所有视图控制器，可用于输入模式变更时的UI刷新
	UFUNCTION()
	void ReopenAll()
	{
		for (auto KV : AllPresenters)
		{
			for (auto Presenter : KV.Value.Presenters)
			{
				Presenter.OnWillClose();
				ReleasePresenter(Presenter);
				Presenter.OnClosed();

				Presenter.OnWillCreateView();
				ViewManager.NewView(Presenter);
				Presenter.OnWillOpen();
				ViewManager.AddView(Presenter.GetView());
				Presenter.OnOpened();
			}
		}
	}

	private UHCPresenterBase_AS NewPresenter(TSubclassOf<UHCPresenterBase_AS> Type, UHCViewBase_AS ExistingView = nullptr, UObject CustomInitData = nullptr)
	{
		// Outer需要设置，不然Presenter没有归属的World
		auto Presenter = Cast<UHCPresenterBase_AS>(NewObject(this, Type));
		++GenId;
		Presenter.InstanceId = GenId;
		Presenter.OnCreated();
		Presenter.OnSetCustomInitData(CustomInitData);
		Presenter.OnWillCreateView();
		if (ExistingView == nullptr)
		{
			ViewManager.NewView(Presenter);
		}
		else
		{
			Presenter.View = ExistingView;
			Presenter.View.SetPresenter(Presenter);
		}
		Presenter.OnWillOpen();
		if (ExistingView == nullptr)
		{
			ViewManager.AddView(Presenter.GetView());
		}
		return Presenter;
	}

	private void ReleasePresenter(UHCPresenterBase_AS Presenter)
	{
		ViewManager.RemoveView(Presenter.GetView());
		ViewManager.ReleaseView(Presenter);
	}
};