// PC模式的视距、视角控制
class UPcViewController_AS : UActorComponent
{
	// 视距变化速度
	UPROPERTY(EditAnywhere)
	float ZoomSpeed = 1000;

	// 第三人称视距范围
	UPROPERTY(EditAnywhere)
	FVector2f ThirdViewRange = FVector2f(100, 300);

	// 第三人称向第一人称滑动时，最大的视角偏移
	UPROPERTY(EditAnywhere)
	FVector ZoomToFirstOffset = FVector(0, 0, 60);

	// 当发生第一\三人称视色切换时的事件，参数为是否是第三人称
	UPROPERTY()
	FActionBool OnViewTypeChangeEvent;

	UPROPERTY(NotVisible)
	USpringArmComponent ThirdCameraSpringArm;
	UPROPERTY(NotVisible)
	UCameraComponent ThirdCamera;
	UPROPERTY(NotVisible)
	UCameraComponent FirstCamera;

	// 当前的第三人称视距
	float ThirdSpringLength = ThirdViewRange.Y;
	FVector ThirdSpringOffset = FVector::ZeroVector;
	bool bEnable = false;

	ACharacter GetOwnerCharacter()
	{
		return Cast<ACharacter>(GetOwner());
	}

	UFUNCTION()
	void SetEnable(bool bInEnable)
	{
		if (bEnable == bInEnable)
			return;

		bEnable = bInEnable;
		if (!bEnable)
		{
			FirstCamera.SetActive(false);
			FirstCamera.SetHiddenInGame(true);

			ThirdCamera.SetActive(false);
			ThirdCamera.SetHiddenInGame(true);
			ThirdCameraSpringArm.SetActive(false);
		}
		else
		{
			ThirdSpringLength = ThirdViewRange.Y;
			ThirdSpringOffset = FVector::ZeroVector;
			SetViewType(true);
		}
	}

	bool bThird = true;
	void SetViewType(bool bInThird)
	{
		bThird = bInThird;
		auto Character = GetOwnerCharacter();
		if (!bInThird)
		{
			FirstCamera.SetActive(true);
			FirstCamera.SetHiddenInGame(false);

			ThirdCamera.SetActive(false);
			ThirdCamera.SetHiddenInGame(true);
			ThirdCameraSpringArm.SetActive(false);

			Character.bUseControllerRotationPitch = false;
			Character.bUseControllerRotationYaw = true;
			Character.bUseControllerRotationRoll = false;
			Character.CharacterMovement.bOrientRotationToMovement = false;
			Gameplay::GetPlayerController(0).SetbShowMouseCursor(false);
			Widget::SetInputMode_GameOnly(Gameplay::GetPlayerController(0));
		}
		else
		{
			auto Rot = GetOwnerCharacter().GetActorRelativeRotation();
			Rot.Pitch = 0;
			Rot.Roll = 0;
			GetOwnerCharacter().SetActorRelativeRotation(Rot);

			FirstCamera.SetActive(false);
			FirstCamera.SetHiddenInGame(true);

			ThirdCamera.SetActive(true);
			ThirdCamera.SetHiddenInGame(false);
			ThirdCameraSpringArm.TargetArmLength = ThirdSpringLength;
			ThirdCameraSpringArm.TargetOffset = ThirdSpringOffset;
			ThirdCameraSpringArm.SetActive(true);

			Character.bUseControllerRotationPitch = false;
			Character.bUseControllerRotationYaw = false;
			Character.bUseControllerRotationRoll = false;
			Character.CharacterMovement.bOrientRotationToMovement = true;
			Gameplay::GetPlayerController(0).SetbShowMouseCursor(true);
			Widget::SetInputMode_GameAndUIEx(Gameplay::GetPlayerController(0));
		}
		OnViewTypeChangeEvent.ExecuteIfBound(bThird);
	}

	// 设置视距变化量
	UFUNCTION()
	void SetDelta(float InValue)
	{
		if (!bEnable)
			return;

		// 旧的视距占比
		float OldRate = (ThirdSpringLength - ThirdViewRange.X) / (ThirdViewRange.Y - ThirdViewRange.X);
		// 视距
		ThirdSpringLength += InValue * ZoomSpeed * Math::Clamp(OldRate, 0.5f, 1);
		ThirdSpringLength = Math::Clamp(ThirdSpringLength, 0, ThirdViewRange.Y);
		ThirdCameraSpringArm.TargetArmLength = ThirdSpringLength;
		// 视距占比以及偏移
		float Rate = (ThirdSpringLength - ThirdViewRange.X) / (ThirdViewRange.Y - ThirdViewRange.X);
		ThirdSpringOffset = Math::Lerp(ZoomToFirstOffset, FVector::ZeroVector, Rate);
		ThirdCameraSpringArm.TargetOffset = ThirdSpringOffset;

		if (bThird && ThirdSpringLength < ThirdViewRange.X)
		{
			SetViewType(false);
		}
		else if (!bThird && ThirdSpringLength > ThirdViewRange.X)
		{
			SetViewType(true);
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (bEnable && !bThird)
		{
			auto Rot = FirstCamera.GetWorldRotation();
			Rot.Pitch = GetOwnerCharacter().ControlRotation.Pitch;
			FirstCamera.SetWorldRotation(Rot);
		}
	}
};