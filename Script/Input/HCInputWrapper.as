enum EHCInputState
{
	Begin,
	End,
}

// Key事件
event void FHCInputKeyDelegate(EHCInputState State);
// 轴事件
event void FHCInputAxisDelegate(float32 Value);
// 2d轴事件
event void FHCInputAxis2DDelegate(FVector Value);

// pc、vr、linkXR三种输入模式的处理
class UHCInputWrapper_AS : UActorComponent
{
	UPROPERTY(EditAnywhere)
	bool bDebug = false;

	// 动作绑定-点击
	UPROPERTY(EditAnywhere)
	FName ActionBinding_Trigger = n"HCActionTrigger";

	// 动作绑定-传送
	UPROPERTY(EditAnywhere)
	FName ActionBinding_Teleport = n"HCActionTeleport";

	// 动作绑定-冲刺
	UPROPERTY(EditAnywhere)
	FName ActionBinding_Sprint = n"DoSprint";

	// 轴绑定-横向移动
	UPROPERTY(EditAnywhere)
	FName AxisBinding_MoveX = n"HCAxisMoveX";

	// 轴绑定-前向移动
	UPROPERTY(EditAnywhere)
	FName AxisBinding_MoveY = n"HCAxisMoveY";

	// 轴绑定-转身
	UPROPERTY(EditAnywhere)
	FName AxisBinding_Turn = n"HCAxisTurn_X";

	// 轴绑定-视距
	UPROPERTY(EditAnywhere)
	FName AxisBinding_ViewDis = n"HCAxisViewDis";

	// 点击事件
	UPROPERTY()
	FHCInputKeyDelegate TriggerEventDispatcher;
	// 传送事件
	UPROPERTY()
	FHCInputKeyDelegate TeleportEventDispatcher;
	// 冲刺事件
	UPROPERTY()
	FHCInputKeyDelegate SprintEventDispatcher;
	// 横向移动事件
	UPROPERTY()
	FHCInputAxisDelegate MoveXEventDispatcher;
	// 前向移动事件
	UPROPERTY()
	FHCInputAxisDelegate MoveYEventDispatcher;
	// 转身事件
	UPROPERTY()
	FHCInputAxisDelegate TurnEventDispatcher;
	// 看事件
	UPROPERTY()
	FHCInputAxis2DDelegate LookEventDispatcher;
	// 视距变化事件
	UPROPERTY()
	FHCInputAxisDelegate ViewDisEventDispatcher;

	UPROPERTY()
	private FInputActionHandlerDynamicSignature TriggerPressedCallback;

	UPROPERTY()
	private FInputActionHandlerDynamicSignature TriggerReleasedCallback;

	UPROPERTY()
	private FInputActionHandlerDynamicSignature TeleportPressedCallback;

	UPROPERTY()
	private FInputActionHandlerDynamicSignature TeleportReleasedCallback;

	UPROPERTY()
	private FInputActionHandlerDynamicSignature SprintPressedCallback;

	UPROPERTY()
	private FInputActionHandlerDynamicSignature SprintReleasedCallback;

	UPROPERTY()
	private FInputAxisHandlerDynamicSignature MoveXCallback;

	UPROPERTY()
	private FInputAxisHandlerDynamicSignature MoveYCallback;

	UPROPERTY()
	private FInputAxisHandlerDynamicSignature TurnCallback;

	UPROPERTY()
	private FInputVectorAxisHandlerDynamicSignature LookCallback;

	UPROPERTY()
	private FInputAxisHandlerDynamicSignature ViewDisCallback;

	UPROPERTY()
	private APlayerController PlayerController;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		PlayerController = Cast<APlayerController>(GetOwner());
		BindInput();
	}

	// 建立输入绑定
	UFUNCTION()
	private void BindInput()
	{
		// nDisplay模式下增强输入失效, 但是可以使用传统输入绑定
		auto InputCpt = UInputComponent::Get(PlayerController);

		TriggerPressedCallback.BindUFunction(this, n"OnTriggerPressed");
		TriggerReleasedCallback.BindUFunction(this, n"OnTriggerReleased");
		InputCpt.BindAction(ActionBinding_Trigger, EInputEvent::IE_Pressed, TriggerPressedCallback);
		InputCpt.BindAction(ActionBinding_Trigger, EInputEvent::IE_Released, TriggerReleasedCallback);

		TeleportPressedCallback.BindUFunction(this, n"OnTeleportPressed");
		TeleportReleasedCallback.BindUFunction(this, n"OnTeleportReleased");
		InputCpt.BindAction(ActionBinding_Teleport, EInputEvent::IE_Pressed, TeleportPressedCallback);
		InputCpt.BindAction(ActionBinding_Teleport, EInputEvent::IE_Released, TeleportReleasedCallback);

		SprintPressedCallback.BindUFunction(this, n"OnSprintPressed");
		SprintReleasedCallback.BindUFunction(this, n"OnSprintReleased");
		InputCpt.BindAction(ActionBinding_Sprint, EInputEvent::IE_Pressed, SprintPressedCallback);
		InputCpt.BindAction(ActionBinding_Sprint, EInputEvent::IE_Released, SprintReleasedCallback);

		MoveXCallback.BindUFunction(this, n"OnMoveX");
		MoveYCallback.BindUFunction(this, n"OnMoveY");
		TurnCallback.BindUFunction(this, n"OnTurn");
		InputCpt.BindAxis(AxisBinding_MoveX, MoveXCallback);
		InputCpt.BindAxis(AxisBinding_MoveY, MoveYCallback);
		InputCpt.BindAxis(AxisBinding_Turn, TurnCallback);

		LookCallback.BindUFunction(this, n"OnLook");
		InputCpt.BindVectorAxis(EKeys::Mouse2D, LookCallback);

		ViewDisCallback.BindUFunction(this, n"OnViewDisChanged");
		InputCpt.BindAxis(AxisBinding_ViewDis, ViewDisCallback);
	}

	UFUNCTION()
	private void OnTriggerPressed(FKey Key)
	{
		if (bDebug)
			Print(f"OnTriggerPressed {Key}");

		if (TriggerEventDispatcher.IsBound())
			TriggerEventDispatcher.Broadcast(EHCInputState::Begin);
	}

	UFUNCTION()
	private void OnTriggerReleased(FKey Key)
	{
		if (bDebug)
			Print(f"OnTriggerReleased {Key}");

		if (TriggerEventDispatcher.IsBound())
			TriggerEventDispatcher.Broadcast(EHCInputState::End);
	}

	UFUNCTION()
	private void OnTeleportPressed(FKey Key)
	{
		if (bDebug)
			Print(f"OnTeleportPressed {Key}");

		if (TeleportEventDispatcher.IsBound())
			TeleportEventDispatcher.Broadcast(EHCInputState::Begin);
	}

	UFUNCTION()
	private void OnTeleportReleased(FKey Key)
	{
		if (bDebug)
			Print(f"OnTeleportReleased {Key}");

		if (TeleportEventDispatcher.IsBound())
			TeleportEventDispatcher.Broadcast(EHCInputState::End);
	}

	UFUNCTION()
	private void OnSprintPressed(FKey Key)
	{
		if (bDebug)
			Print(f"OnSprintPressed {Key}");

		if (SprintEventDispatcher.IsBound())
			SprintEventDispatcher.Broadcast(EHCInputState::Begin);
	}

	UFUNCTION()
	private void OnSprintReleased(FKey Key)
	{
		if (bDebug)
			Print(f"OnSprintReleased {Key}");

		if (SprintEventDispatcher.IsBound())
			SprintEventDispatcher.Broadcast(EHCInputState::End);
	}

	UFUNCTION()
	private void OnMoveX(float32 AxisValue)
	{
		if (Math::Abs(AxisValue) != 0.0f)
		{
			if (bDebug)
				Print(f"OnMoveX {AxisValue}");

			if (MoveXEventDispatcher.IsBound())
				MoveXEventDispatcher.Broadcast(AxisValue);
		}
	}

	UFUNCTION()
	private void OnMoveY(float32 AxisValue)
	{
		if (Math::Abs(AxisValue) != 0.0f)
		{
			if (bDebug)
				Print(f"OnMoveY {AxisValue}");

			if (MoveYEventDispatcher.IsBound())
				MoveYEventDispatcher.Broadcast(AxisValue);
		}
	}

	UFUNCTION()
	private void OnTurn(float32 AxisValue)
	{
		if (Math::Abs(AxisValue) > 0.5f)
		{
			if (bDebug)
				Print(f"OnTurn {AxisValue}");

			if (TurnEventDispatcher.IsBound())
				TurnEventDispatcher.Broadcast(AxisValue);
		}
	}

	UFUNCTION()
	private void OnLook(FVector AxisValue)
	{
		if (AxisValue.SizeSquared() != 0.0f)
		{
			if (bDebug)
				Print(f"OnLook {AxisValue}");

			if (LookEventDispatcher.IsBound())
				LookEventDispatcher.Broadcast(AxisValue);
		}
	}

	UFUNCTION()
	private void OnViewDisChanged(float32 AxisValue)
	{
		if (Math::Abs(AxisValue) != 0.0f)
		{
			if (bDebug)
				Print(f"OnViewDisChanged {AxisValue}");

			if (ViewDisEventDispatcher.IsBound())
				ViewDisEventDispatcher.Broadcast(AxisValue);
		}
	}
};