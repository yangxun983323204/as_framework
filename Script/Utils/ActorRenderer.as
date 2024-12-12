// 3D物体2D UI图片渲染，ShowFlags无法访问到，因此需使用子类蓝图
class AActorUiRenderer_AS : ASceneCapture2D
{
	// 被渲染的目标
	UPROPERTY(BlueprintHidden)
	private AActor Target = nullptr;

	// 被渲染的目标的背景
	UPROPERTY(BlueprintHidden)
	private AActor Background = nullptr;

	private float Distance = 0;

	private FVector Offset = FVector::ZeroVector;
	private float OffsetPitch = 0;
	private float Yaw = 0;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		SetResolution(1024);
		this.CaptureComponent2D.PrimitiveRenderMode = ESceneCapturePrimitiveRenderMode::PRM_UseShowOnlyList;
		this.CaptureComponent2D.FOVAngle = 60;
		this.CaptureComponent2D.CaptureSource = ESceneCaptureSource::SCS_SceneColorHDR; // SceneColor(HDR) in RGB, Inv Opacity in A
	}

	void SetResolution(int Size)
	{
		this.CaptureComponent2D.TextureTarget = Rendering::CreateRenderTarget2D(Size, Size);
	}

	UFUNCTION()
	void SetTarget(AActor InTarget, AActor& OutOldTarget)
	{
		if (InTarget == Target)
			return;

		OutOldTarget = Target;
		Target = InTarget;

		if (OutOldTarget != nullptr)
			OutOldTarget.AttachToActor(nullptr);

		this.CaptureComponent2D.ShowOnlyActors.Remove(OutOldTarget);
		if (Target != nullptr)
		{
			Target.AttachToActor(this);
			this.CaptureComponent2D.ShowOnlyActors.Add(Target);
			CalcTargetDistance();
			Applay();
		}
	}

	UFUNCTION(BlueprintPure)
	AActor GetTarget()
	{
		return Target;
	}

	UFUNCTION()
	void SetBackground(AActor InBackground, AActor& OutOldBackground)
	{
		if (InBackground == Background)
			return;

		OutOldBackground = Background;
		Background = InBackground;

		if (OutOldBackground != nullptr)
			OutOldBackground.AttachToActor(nullptr);

		this.CaptureComponent2D.ShowOnlyActors.Remove(OutOldBackground);
		if (Background != nullptr)
		{
			Background.AttachToActor(this);
			this.CaptureComponent2D.ShowOnlyActors.Add(Background);
			Applay();
		}
	}

	UFUNCTION(BlueprintPure)
	AActor GetBackground()
	{
		return Background;
	}

	UFUNCTION(BlueprintPure)
	float GetTargetDistance()
	{
		return Distance;
	}

	UFUNCTION()
	float SetTargetDistance(float Dis)
	{
		Distance = Dis;
		Applay();
		return GetTargetDistance();
	}

	UFUNCTION()
	float SetTargetDistanceDelta(float Dis)
	{
		Distance += Dis;
		Applay();
		return GetTargetDistance();
	}

	UFUNCTION()
	void SetYaw(float Angle)
	{
		Yaw = Angle;
		Applay();
	}

	UFUNCTION()
	void SetYawDelta(float Angle)
	{
		Yaw += Angle;
		Applay();
	}

	// 获取渲染目标纹理
	UFUNCTION()
	UTextureRenderTarget2D GetRenderTarget()
	{
		return this.CaptureComponent2D.TextureTarget;
	}

	UFUNCTION(BlueprintPure)
	FVector GetOffset()
	{
		return Offset;
	}

	UFUNCTION()
	void SetOffset(FVector InOffset)
	{
		Offset = InOffset;
		Applay();
	}

	UFUNCTION(BlueprintPure)
	float GetOffsetPitch()
	{
		return OffsetPitch;
	}

	UFUNCTION()
	void SetOffsetPitch(float InOffsetPitch)
	{
		OffsetPitch = InOffsetPitch;
		Applay();
	}

	void CalcTargetDistance()
	{
		FVector Origin;
		FVector Box;
		Target.GetActorBounds(false, Origin, Box, true);
		float Size = Math::Max(Box.X, Box.Z);
		auto Fov = this.CaptureComponent2D.FOVAngle;
		Distance = Size / Math::Tan(Fov / 2.0f) * 1.2f;
	}

	void Applay()
	{
		if (Target != nullptr)
		{
			Target.SetActorRelativeLocation(FVector(Distance, 0, 0) + Offset);
			Target.SetActorRotation(FRotator(OffsetPitch, 180 + Yaw, 0));
		}

		if (Background != nullptr)
		{
			Background.SetActorRelativeLocation(FVector(Distance, 0, 0) + Offset);
			Background.SetActorRotation(FRotator(OffsetPitch, 180 + Yaw, 0));
		}
	}
};