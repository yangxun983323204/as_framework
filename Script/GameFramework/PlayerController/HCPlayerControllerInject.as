namespace HCPlayerController
{
	UFUNCTION()
	void RequireLock(bool bLock)
	{
		auto Controller = Gameplay::GetPlayerController(0);
		auto Input = UHCPlayerControllerInject_AS::Get(Controller);
		if (Input != nullptr)
		{
			Input.RequireLock(bLock);
		}
	}

	UFUNCTION(BlueprintPure)
	bool IsLocked()
	{
		auto Controller = Gameplay::GetPlayerController(0);
		auto Input = UHCPlayerControllerInject_AS::Get(Controller);
		if (Input != nullptr)
		{
			return Input.IsLocked();
		}
		else
		{
			return false;
		}
	}
}

namespace HCPlayerControllerInject
{
	UFUNCTION()
	void Do(APlayerController Controller)
	{
		if (!System::IsServer() || System::IsStandalone())
		{
			auto Inst = UHCPlayerControllerInject_AS::GetOrCreate(Controller);
			auto InputWrapper = UHCInputWrapper_AS::GetOrCreate(Controller);
			Inst.InputCpt = InputWrapper;
		}
		if (System::IsServer())
		{
			//auto TaskController = UHCPlayerTaskContrller::GetOrCreate(Controller);
			//TaskController.SetIsReplicated(true);
		}
	}
}

class UHCPlayerControllerInject_AS : UActorComponent
{
	// 是否锁定输入（触发检查时需锁定输入）
	UPROPERTY()
	private bool bLockInput = false;
	private int LockCount = 0;

	UPROPERTY()
	private APlayerController Target;

	UPROPERTY()
	UHCInputWrapper_AS InputCpt;

	UFUNCTION()
	void RequireLock(bool bLock)
	{
		if (bLock)
			++LockCount;
		else
			--LockCount;
		LockCount = Math::Clamp(LockCount, 0, 100000);
		bLockInput = LockCount > 0;
		Target.bEnableClickEvents = !bLockInput;
		Target.bEnableMouseOverEvents = !bLockInput;

		if (bLockInput)
		{
			int Msg = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::Lock);
			UMessageCenter::Instance.Send(Msg, "");
		}
		else
		{
			int Msg = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::UnLock);
			UMessageCenter::Instance.Send(Msg, "");
		}
	}

	UFUNCTION(BlueprintPure)
	bool IsLocked()
	{
		return LockCount > 0;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Target = Cast<APlayerController>(GetOwner());
		if (InputCpt != nullptr)
		{
			InputCpt.TriggerEventDispatcher.AddUFunction(this, n"OnInputTrigger");
			InputCpt.TeleportEventDispatcher.AddUFunction(this, n"OnInputTeleport");
			InputCpt.MoveXEventDispatcher.AddUFunction(this, n"OnInputMoveX");
			InputCpt.MoveYEventDispatcher.AddUFunction(this, n"OnInputMoveY");
			InputCpt.TurnEventDispatcher.AddUFunction(this, n"OnInputTurn");
			InputCpt.LookEventDispatcher.AddUFunction(this, n"OnLook");
			InputCpt.SprintEventDispatcher.AddUFunction(this, n"OnSprint");
			InputCpt.ViewDisEventDispatcher.AddUFunction(this, n"OnViewDisChanged");
		}
		Target.bEnableClickEvents = true;
	}

	UFUNCTION()
	private void OnInputTrigger(EHCInputState State)
	{
		if (bLockInput && UHCInputManager_AS::Get().GetInputType() == EInputType::PC) // 在VR下，点击还是需要传递的。
			return;

		auto Char = Cast<ACharacter>(Target.ControlledPawn);
		if (Char == nullptr)
			return;

		switch (State)
		{
			case EHCInputState::Begin:
				//Char.TriggerPress();
				break;
			case EHCInputState::End:
				//Char.TriggerRelease();
				break;
		}
	}

	UFUNCTION()
	private void OnInputMoveX(float32 Value)
	{
		if (bLockInput)
			return;

		auto InputType = UHCInputManager_AS::Get().GetInputType();
		if (InputType == EInputType::PC)
		{
			FVector Right;
			auto PCViewController = UPcViewController_AS::Get(Target.ControlledPawn);
			if (PCViewController != nullptr && PCViewController.bThird)
			{
				auto ControlRot = Target.ControlledPawn.GetControlRotation();
				ControlRot.Pitch = 0;
				Right = ControlRot.GetRightVector();
			}
			else
			{
				Right = Target.ControlledPawn.GetActorRightVector();
			}
			Target.ControlledPawn.AddMovementInput(Right, Value);
		}
	}

	UFUNCTION()
	private void OnInputMoveY(float32 Value)
	{
		if (bLockInput)
			return;

		auto InputType = UHCInputManager_AS::Get().GetInputType();
		if (InputType == EInputType::PC)
		{
			FVector Forward;
			auto PCViewController = UPcViewController_AS::Get(Target.ControlledPawn);
			if (PCViewController != nullptr && PCViewController.bThird)
			{
				auto ControlRot = Target.ControlledPawn.GetControlRotation();
				ControlRot.Roll = 0;
				ControlRot.Pitch = 0;
				Forward = ControlRot.GetForwardVector();
			}
			else
			{
				Forward = Target.ControlledPawn.GetActorForwardVector();
			}
			Target.ControlledPawn.AddMovementInput(Forward, Value);
		}
	}

	// 转身事件间隔
	UPROPERTY()
	float TurnInterval = 0.5;

	float LastTurnTime = 0;

	UFUNCTION()
	private void OnInputTurn(float32 Value)
	{
		if (bLockInput)
			return;

		auto Char = Cast<ACharacter>(Target.ControlledPawn);
		if (Char == nullptr)
			return;

		if (UHCInputManager_AS::Get().GetInputType() == EInputType::PC)
		{
			Char.AddControllerYawInput(Value);
		}
		else
		{
			if ((System::GetGameTimeInSeconds() - LastTurnTime) > TurnInterval)
			{
				LastTurnTime = System::GetGameTimeInSeconds();
				//Char.VrTurn(Value);
			}
		}
	}

	UFUNCTION()
	private void OnLook(FVector Value)
	{
		if (bLockInput)
			return;

		auto Char = Cast<ACharacter>(Target.ControlledPawn);
		if (Char == nullptr)
			return;
		if (UHCInputManager_AS::Get().GetInputType() == EInputType::PC)
		{
			Char.AddControllerYawInput(Value.X);
			Char.AddControllerPitchInput(-Value.Y);
		}
	}

	UFUNCTION()
	private void OnInputTeleport(EHCInputState State)
	{
		if (bLockInput)
			return;

		auto Char = Cast<ACharacter>(Target.ControlledPawn);
		if (Char == nullptr)
			return;

		if (UHCInputManager_AS::Get().GetInputType() == EInputType::PC)
			return;

		if (State == EHCInputState::Begin)
		{
			//Char.TeleportStartTrace();
		}
		else if (State == EHCInputState::End)
		{
			//Char.TeleportEnd();
		}
	}

	UFUNCTION()
	private void OnSprint(EHCInputState State)
	{
		if (bLockInput)
			return;

		auto Char = Cast<ACharacter>(Target.ControlledPawn);
		if (Char == nullptr)
			return;

		if (State == EHCInputState::Begin)
		{
			//Char.OnSprint(true);
		}
		else if (State == EHCInputState::End)
		{
			//Char.OnSprint(false);
		}
	}

	UFUNCTION()
	private void OnViewDisChanged(float32 Value)
	{
		if (bLockInput)
			return;

		if (UHCInputManager_AS::Get().GetInputType() != EInputType::PC)
			return;

		auto ViewController = UPcViewController_AS::Get(Target.ControlledPawn);
		if (ViewController == nullptr)
			return;

		ViewController.SetDelta(-Math::Sign(Value) * Gameplay::GetWorldDeltaSeconds());
	}
};