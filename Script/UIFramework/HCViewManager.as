// 延迟关闭的UI
class UViewDelayCloseInfo : UObject
{
	float DelayTime = 0;
	UHCViewBase_AS View;
}

// 视图管理器
class UHCViewManager_AS : UObject
{
	private bool bMouseInputInVR = false;

	UPROPERTY()
	private TSubclassOf<UHCUiRootWidget> RootUiType;

	UPROPERTY(BlueprintReadOnly)
	UHCUiRootWidget PCRootUI;

	UPROPERTY()
	private TMap<UHCViewBase_AS, AHCVrUiContainer_AS> AllVrUiBind;

	UPROPERTY()
	private TArray<UViewDelayCloseInfo> AllDelayCloseView;

	UPROPERTY()
	private TSet<UHCViewBase_AS> RootViews;

	void Init()
	{
		RootUiType = GetHCUiRootWidgetType();
		if (RootUiType != nullptr)
		{
			PCRootUI = Cast<UHCUiRootWidget>(WidgetBlueprint::CreateWidget(RootUiType, Gameplay::GetPlayerController(0)));
			PCRootUI.AddToViewport(100);
		}

		if (RootUiType == nullptr)
		{
			PrintError("RootUiType == nullptr");
		}
	}

	UFUNCTION()
	void NewView(UHCPresenterBase_AS Presenter)
	{
		if (Presenter.View != nullptr)
		{
			RemoveView(Presenter.View);
			ReleaseView(Presenter);
		}

		auto InputType = UHCInputManager_AS::Get().GetInputType();
		TSubclassOf<UHCViewBase_AS> WidgetType = nullptr;
		if (InputType == EInputType::PC || InputType == EInputType::LinkXR)
		{
			if (Presenter.ViewPCType == nullptr)
				return;

			WidgetType = Presenter.ViewPCType;
		}
		else
		{
			if (Presenter.ViewVRType == nullptr)
				return;

			WidgetType = Presenter.ViewVRType;
		}

		if (WidgetType != nullptr)
		{
			auto Widget = WidgetBlueprint::CreateWidget(WidgetType, Gameplay::GetPlayerController(0));
			RootViews.Add(Cast<UHCViewBase_AS>(Widget));
			Presenter.View = Cast<UHCViewBase_AS>(Widget);
			Presenter.View.SetPresenter(Presenter);
		}
		else
		{
			PrintWarning(f"{Presenter}不支持交互类型:{InputType}");
		}
	}

	UFUNCTION()
	void AddView(UHCViewBase_AS View)
	{
		auto InputType = UHCInputManager_AS::Get().GetInputType();
		if (InputType == EInputType::VR)
		{
			auto HCChar = Cast<ACharacter>(Gameplay::GetPlayerCharacter(0));
			if (HCChar != nullptr)
			{
				auto VrContainer = Cast<AHCVrUiContainer_AS>(SpawnActor(GetVrUiContainerType()));
				VrContainer.SetUI(View, View.VrBindParams);
				AllVrUiBind.Add(View, VrContainer);
				View.OnShow();
			}
		}
		else
		{
			UCanvasPanel UiRoot = nullptr;
			if (InputType == EInputType::PC)
			{
				if (PCRootUI != nullptr)
				{
					UiRoot = PCRootUI.Root;
				}
			}
			else if (InputType == EInputType::LinkXR)
			{
				auto HCChar = Cast<ACharacter>(Gameplay::GetPlayerCharacter(0));
				if (HCChar != nullptr)
				{
					//UiRoot = HCChar.GetLinkXRUiRoot();
				}
			}

			if (UiRoot == nullptr)
			{
				PrintWarning(f"UiRoot == nullptr, InputType:{InputType}");
				View.AddToViewport();
				View.OnShow();
				return;
			}

			UiRoot.AddChild(View);
			auto Slot = WidgetLayout::SlotAsCanvasSlot(View);
			if (Slot == nullptr)
			{
				Print("Slot == nullptr", 10, FLinearColor::Red);
			}
			Slot.SetLayout(View.PcLayout);
			View.OnShow();
		}

		View.CreateType = InputType;
	}

	UFUNCTION()
	void RemoveView(UHCViewBase_AS View)
	{
		RemoveViewInner(View, false);
	}

	void RemoveViewInner(UHCViewBase_AS View, bool bForce)
	{
		if (View.bDelayClose && !View.IsReadyToClose() && !bForce)
		{
			auto Info = Cast<UViewDelayCloseInfo>(NewObject(nullptr, UViewDelayCloseInfo::StaticClass()));
			Info.DelayTime = 0;
			Info.View = View;
			AllDelayCloseView.Add(Info);
			View.OnWillClose();
			return;
		}

		RootViews.Remove(Cast<UHCViewBase_AS>(View));
		auto InputType = View.CreateType;
		if (InputType == EInputType::PC)
		{
			View.RemoveFromParent();
		}
		else if (InputType == EInputType::LinkXR)
		{
			View.RemoveFromParent();
		}
		else if (InputType == EInputType::VR)
		{
			AHCVrUiContainer_AS VrContainer;
			if (AllVrUiBind.Find(View, VrContainer))
			{
				AllVrUiBind.Remove(View);
				VrContainer.DestroyActor();
			}
		}
		else
		{
			PrintWarning(f"不支持的交互类型:{InputType}");
		}
	}

	UFUNCTION()
	void ReleaseView(UHCPresenterBase_AS Presenter)
	{
		Presenter.View = nullptr;
	}

	UFUNCTION()
	void Tick(float DeltaTime)
	{
		int Idx = AllDelayCloseView.Num() - 1;
		for (; Idx >= 0; --Idx)
		{
			auto& Info = AllDelayCloseView[Idx];
			if (Info.View == nullptr)
			{
				AllDelayCloseView.RemoveSwap(Info);
			}

			Info.DelayTime += DeltaTime;
			if (Info.DelayTime >= 3 || Info.View.IsReadyToClose()) // 最多允许3秒延迟关闭
			{
				RemoveViewInner(Info.View, true);
				AllDelayCloseView.RemoveSwap(Info);
			}
		}
	}

	// 获取VR界面容器
	TSubclassOf<AHCVrUiContainer_AS> GetVrUiContainerType()
	{
		TSubclassOf<AHCVrUiContainer_AS> Type = nullptr;
		if (bMouseInputInVR)
		{
			//Type = UHCGameInstanceSubsystem_AS::Get().DataRegister.VRViewContainerTestType;
		}
		else
		{
			//Type = UHCGameInstanceSubsystem_AS::Get().DataRegister.VRViewContainerType;
		}

		if (Type == nullptr)
		{
			Type = AHCVrUiContainer_AS::StaticClass();
		}

		return Type;
	}

	void SetMouseInputInVR(bool bEnable)
	{
		bMouseInputInVR = bEnable;
	}

	// 下面的方法可能用不到吧，先不实现了

	UFUNCTION()
	void SetViewBehind(UHCViewBase_AS View, UHCViewBase_AS Other)
	{
		// @todo
		PrintError("todo");
	}

	UFUNCTION()
	void SetViewOverlay(UHCViewBase_AS View, UHCViewBase_AS Other)
	{
		// @todo
		PrintError("todo");
	}

	UFUNCTION()
	void SetViewAsTop(UHCViewBase_AS View)
	{
		// @todo
		PrintError("todo");
	}

	UFUNCTION()
	void SetViewAsBottom(UHCViewBase_AS View)
	{
		// @todo
		PrintError("todo");
	}

	bool IsRootView(UHCViewBase_AS View)
	{
		return RootViews.Contains(View);
	}
};