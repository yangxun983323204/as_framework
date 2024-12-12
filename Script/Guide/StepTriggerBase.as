struct FAreaTriggerSetting
{
	// 是否启用
	UPROPERTY()
	bool bEnable = false;
	// 是否反向
	UPROPERTY()
	bool bNeg = false;
}

class AStepTriggerBase : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	// 启用的消息监听
	UPROPERTY(DefaultComponent)
	UMsgRecComponent EnableMsgRec;
	default EnableMsgRec.InstanceId = 0;

	// 禁用的消息监听
	UPROPERTY(DefaultComponent)
	UMsgRecComponent DisableMsgRec;
	default DisableMsgRec.InstanceId = 1;

	// 显示的消息监听
	UPROPERTY(DefaultComponent)
	UMsgRecComponent ShowMsgRec;
	default ShowMsgRec.InstanceId = 2;

	// 隐藏的消息监听
	UPROPERTY(DefaultComponent)
	UMsgRecComponent HideMsgRec;
	default HideMsgRec.InstanceId = 3;

	// 触发显示的区域
	UPROPERTY(DefaultComponent, Attach = Root)
	USphereComponent TriggerShowArea;
	default TriggerShowArea.SphereRadius = 20;

	// 触发隐藏的区域
	UPROPERTY(DefaultComponent, Attach = Root)
	USphereComponent TriggerHideArea;
	default TriggerHideArea.SphereRadius = 20;

	// 触发显示的区域的行为设置
	UPROPERTY(EditAnywhere)
	FAreaTriggerSetting AreaShowSetting;

	// 触发隐藏的区域的行为设置
	UPROPERTY(EditAnywhere)
	FAreaTriggerSetting AreaHideSetting;

	// 是否启用
	UPROPERTY(EditAnywhere)
	bool bSelfEnable = false;

	// 自动显示
	UPROPERTY(EditAnywhere)
	bool bAutoShow = false;

	// 自动显示的延迟
	UPROPERTY(EditAnywhere)
	float AutoActiveDelay = 0.001;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (bAutoShow)
		{
			System::SetTimer(this, n"DelayShow", AutoActiveDelay, false);
		}

		EnableMsgRec.OnRecEvent.AddUFunction(this, n"OnMsgTriggerEnable");
		DisableMsgRec.OnRecEvent.AddUFunction(this, n"OnMsgTriggerDisable");

		ShowMsgRec.OnRecEvent.AddUFunction(this, n"OnMsgTriggerShow");
		HideMsgRec.OnRecEvent.AddUFunction(this, n"OnMsgTriggerHide");

		TriggerShowArea.OnComponentBeginOverlap.AddUFunction(this, n"OnBeginOverlap");
		TriggerShowArea.OnComponentEndOverlap.AddUFunction(this, n"OnEndOverlap");

		TriggerHideArea.OnComponentBeginOverlap.AddUFunction(this, n"OnBeginOverlap");
		TriggerHideArea.OnComponentEndOverlap.AddUFunction(this, n"OnEndOverlap");
	}

	UFUNCTION()
	private void OnMsgTriggerEnable(int Value)
	{
		SetEnable(true);
	}

	UFUNCTION()
	private void OnMsgTriggerDisable(int Value)
	{
		SetEnable(false);
	}

	UFUNCTION()
	private void OnMsgTriggerShow(int Value)
	{
		SetVisiable(true);
	}

	UFUNCTION()
	private void OnMsgTriggerHide(int Value)
	{
		SetVisiable(false);
	}

	UFUNCTION()
	private void OnBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
						UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep,
						FHitResult&in SweepResult)
	{
		if (!bSelfEnable)
			return;

		if (OtherActor != S::GGPC(0).ControlledPawn)
			return;

		if (OverlappedComponent == TriggerShowArea)
			OnTriggerShowArea(true);
		else if (OverlappedComponent == TriggerHideArea)
			OnTriggerHideArea(true);
	}

	UFUNCTION()
	private void OnEndOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
					  UPrimitiveComponent OtherComp, int OtherBodyIndex)
	{
		if (!bSelfEnable)
			return;

		if (OtherActor != S::GGPC(0).ControlledPawn)
			return;

		if (OverlappedComponent == TriggerShowArea)
			OnTriggerShowArea(false);
		else if (OverlappedComponent == TriggerHideArea)
			OnTriggerHideArea(false);
	}

	private void OnTriggerShowArea(bool bEnter)
	{
		if (!AreaShowSetting.bEnable)
			return;

		if (bEnter == !AreaShowSetting.bNeg)
			SetVisiable(true);
	}

	private void OnTriggerHideArea(bool bEnter)
	{
		if (!AreaHideSetting.bEnable)
			return;

		if (bEnter == !AreaShowSetting.bNeg)
			SetVisiable(false);
	}

	UFUNCTION()
	private void DelayShow()
	{
		SetEnable(true);
		SetVisiable(true);
	}

	UFUNCTION(BlueprintEvent)
	void SetEnable(bool bEnable)
	{
		bSelfEnable = bEnable;
		if (!bEnable)
		{
			SetVisiable(false);
		}
	}

	UFUNCTION(BlueprintEvent)
	void SetVisiable(bool bVal)
	{
	}
};