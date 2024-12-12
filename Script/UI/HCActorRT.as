// 由于外包美术打光不规范，亮度靠后处理调的，因此需要渲染两张图，
// 一张是最终色调映射后的，一张是有alpha通道的。

// 物体渲染到纹理。此组件依赖Mat_Capture2D_TwoPass_Inst材质
class UHCActorRT : UUserWidget
{
	UPROPERTY(meta = (BindWidget))
	UImage Content;

	int RX = 1024;
	int RY = 1024;

	UPROPERTY(BlueprintReadOnly)
	AAdvSceneCapture2D Capture2D;

	UPROPERTY(BlueprintReadOnly)
	AAdvSceneCapture2D Capture2DAlphaInv;

	void SetResolution(int SizeX, int SizeY)
	{
		RX = SizeX;
		RY = SizeY;
	}

	UFUNCTION(BlueprintOverride)
	void OnInitialized()
	{
		TSubclassOf<AActor> Type = nullptr;//HC::Inst().DataRegister.ExtraTypes[n"AdvSceneCapture2D"];

		Capture2D = Cast<AAdvSceneCapture2D>(SpawnActor(Type));
		Capture2D.SetResolution(RX, RY);
		Capture2D.SetCaptureSource(ESceneCaptureSource::SCS_FinalToneCurveHDR);

		Capture2DAlphaInv = Cast<AAdvSceneCapture2D>(SpawnActor(Type));
		Capture2DAlphaInv.SetResolution(RX, RY);

		auto OriginMat = Cast<UMaterialInstance>(Content.GetBrush().ResourceObject);
		auto CopyMat = Material::CreateDynamicMaterialInstance(OriginMat);
		CopyMat.SetTextureParameterValue(n"MainTex", Capture2D.GetRenderTarget());
		CopyMat.SetTextureParameterValue(n"AlphaInvTex", Capture2DAlphaInv.GetRenderTarget());
		Content.SetBrushFromMaterial(CopyMat);
	}

	UFUNCTION(BlueprintOverride)
	void Destruct()
	{
		if (Capture2D != nullptr)
		{
			Capture2D.DestroyActor();
		}

		if (Capture2DAlphaInv != nullptr)
		{
			Capture2DAlphaInv.DestroyActor();
		}
	}

	void SetView(FVector Point, FRotator Pose, float Distance)
	{
		FVector Offset = Pose.ForwardVector * Distance;
		FVector Origin = Point + Offset;

		if (Capture2D != nullptr)
			Capture2D.SetActorLocationAndRotation(Origin, (Pose.ForwardVector * -1).Rotation());
		else
			Print("Capture2D==nullptr");

		if (Capture2DAlphaInv != nullptr)
			Capture2DAlphaInv.SetActorLocationAndRotation(Origin, (Pose.ForwardVector * -1).Rotation());
		else
			Print("Capture2DAlphaInv==nullptr");
	}

	void EstimateView(FRotator RefPose, float DistanceScale = 1, float HeightOffsetRate = 0)
	{
		if (Capture2D == nullptr)
		{
			Print("Capture2D==nullptr");
			return;
		}

		if (Capture2D.CaptureComponent2D.ShowOnlyActors.Num() <= 0)
			return;

		float Weight = 1.0f / Capture2D.CaptureComponent2D.ShowOnlyActors.Num();
		FBox TotalBox = FBox();
		FRotator TotalRot = FRotator();

		int Idx = 0;
		for (auto Actor : Capture2D.CaptureComponent2D.ShowOnlyActors)
		{
			FVector Origin;
			FVector Ext;
			Actor.Get().GetActorBounds(true, Origin, Ext, true);
			FBox Box = FBox::BuildAABB(Origin, Ext);
			if (Idx == 0)
			{
				TotalBox = Box;
				TotalRot = Actor.Get().ActorTransform.TransformRotation(RefPose) * Weight;
			}
			else
			{
				TotalBox += Box;
				TotalRot += Actor.Get().ActorTransform.TransformRotation(RefPose) * Weight;
			}
		}

		auto HeightOffset = FVector(0, 0, TotalBox.Extent.Z * 2 * HeightOffsetRate);
		auto Point = TotalBox.GetCenter() + HeightOffset;
		auto HalfFovRad = Math::DegreesToRadians(Capture2D.CaptureComponent2D.FOVAngle) / 2;
		auto Distance = TotalBox.GetExtent().Size() / Math::Tan(HalfFovRad);
		SetView(Point, TotalRot, Distance * DistanceScale);
	}

	void Add(AActor Actor)
	{
		if (Capture2D != nullptr)
			Capture2D.CaptureComponent2D.ShowOnlyActors.AddUnique(Actor);
		else
			Print("Capture2D==nullptr");

		if (Capture2DAlphaInv != nullptr)
			Capture2DAlphaInv.CaptureComponent2D.ShowOnlyActors.AddUnique(Actor);
		else
			Print("Capture2DAlphaInv==nullptr");
	}

	void Remove(AActor Actor)
	{
		if (Capture2D != nullptr)
			Capture2D.CaptureComponent2D.ShowOnlyActors.Remove(Actor);
		else
			Print("Capture2D==nullptr");

		if (Capture2DAlphaInv != nullptr)
			Capture2DAlphaInv.CaptureComponent2D.ShowOnlyActors.Remove(Actor);
		else
			Print("Capture2DAlphaInv==nullptr");
	}

	void Clear()
	{
		if (Capture2D != nullptr)
			Capture2D.CaptureComponent2D.ShowOnlyActors.Empty();
		else
			Print("Capture2D==nullptr");

		if (Capture2DAlphaInv != nullptr)
			Capture2DAlphaInv.CaptureComponent2D.ShowOnlyActors.Empty();
		else
			Print("Capture2DAlphaInv==nullptr");
	}
};