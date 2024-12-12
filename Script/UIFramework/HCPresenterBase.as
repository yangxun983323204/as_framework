// 控制器基类
class UHCPresenterBase_AS : UObject
{
	// 是否支持多个实例
	UPROPERTY(EditDefaultsOnly)
	bool bMultiInstance;

	// PC模式下的界面类
	UPROPERTY()
	TSubclassOf<UHCViewBase_AS> ViewPCType;

	// VR模式下的界面类
	UPROPERTY()
	TSubclassOf<UHCViewBase_AS> ViewVRType;

	// 界面实例
	UPROPERTY(BlueprintReadOnly, VisibleInstanceOnly)
	UHCViewBase_AS View;

	// 控制器实例Id
	UPROPERTY(BlueprintReadOnly, VisibleInstanceOnly)
	uint32 InstanceId;

	bool bIsRelased__ = false;

	UFUNCTION(BlueprintPure)
	UHCViewBase_AS GetView()
	{
		return View;
	}

	// 当被创建时
	UFUNCTION()
	void OnCreated()
	{
		BP_OnCreated();
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnCreated()
	{}

	// 当设置初始数据时
	UFUNCTION()
	void OnSetCustomInitData(UObject CustomInitData)
	{
		BP_OnSetCustomInitData(CustomInitData);
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnSetCustomInitData(UObject CustomInitData)
	{}

	// 当即将创建界面
	UFUNCTION()
	void OnWillCreateView()
	{
		BP_OnWillCreateView();
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnWillCreateView()
	{}

	// 当已创建界面，即将显示
	UFUNCTION()
	void OnWillOpen()
	{
		BP_OnWillOpen();
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnWillOpen()
	{}

	// 当显示后
	UFUNCTION()
	void OnOpened()
	{
		BP_OnOpened();
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnOpened()
	{}

	// 当即将关闭
	UFUNCTION()
	void OnWillClose()
	{
		BP_OnWillClose();
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnWillClose()
	{}

	// 当关闭后
	UFUNCTION()
	void OnClosed()
	{
		BP_OnClosed();
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnClosed()
	{}

	UFUNCTION(BlueprintEvent)
	bool OnBack()
	{
		return false;
	}

	UFUNCTION()
	void Close()
	{
		UHCPresenterManager_AS::Get().Close(this);
	}
};