// VR激光笔
class UVRLaserComponent : UActorComponent
{
	UPROPERTY()
	bool bActive = true;

	// 对粒子组件的引用
	UPROPERTY(NotEditable)
	UNiagaraComponent LaserTraceFx;

	UPROPERTY()
	UNiagaraSystem LaserTraceFxAsset;

	// 3d ui交互组件
	UPROPERTY(NotEditable)
	UWidgetInteractionComponent WidgetInteraction;

	// 对碰撞点的引用
	UPROPERTY(NotEditable)
	UStaticMeshComponent Cursor;

	UPROPERTY()
	UStaticMesh CursorMesh;

	UPROPERTY()
	UMaterial CursorMaterial;

	UPROPERTY()
	float CursorScale = 0.1f;

	// 激光线的起始节点
	UPROPERTY(NotVisible)
	private USceneComponent StartNode;

	private bool bHit = false;

	// 设置激光线的起始点关联的场景组件
	UFUNCTION()
	void SetBindNode(USceneComponent SceneCpt, FName InName)
	{
		StartNode = SceneCpt;
		LaserTraceFx = Cast<UNiagaraComponent>(Owner.CreateComponent(UNiagaraComponent::StaticClass(), FName("LaserTraceFx" + InName)));
		LaserTraceFx.SetAsset(LaserTraceFxAsset);
		LaserTraceFx.SetVisibility(false);

		WidgetInteraction = Cast<UWidgetInteractionComponent>(Owner.CreateComponent(UWidgetInteractionComponent::StaticClass(), FName("WidgetInteraction" + InName)));
		WidgetInteraction.AttachToComponent(StartNode);

		Cursor = Cast<UStaticMeshComponent>(Owner.CreateComponent(UStaticMeshComponent::StaticClass(), FName("Cursor" + InName)));
		Cursor.SetStaticMesh(CursorMesh);
		Cursor.SetMaterial(0, CursorMaterial);
		Cursor.SetRelativeScale3D(FVector(CursorScale));
		Cursor.SetVisibility(false);
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (!bActive)
		{
			if (LaserTraceFx.GetbVisible())
				LaserTraceFx.SetVisibility(false);

			if (Cursor.GetbVisible())
				Cursor.SetVisibility(false);

			return;
		}

		bHit = WidgetInteraction.IsOverHitTestVisibleWidget();
		if (!bHit)
		{
			LaserTraceFx.SetVisibility(false);
			Cursor.SetVisibility(false);
		}
		else
		{
			LaserTraceFx.SetVisibility(true);
			auto ImpactPoint = WidgetInteraction.GetLastHitResult().ImpactPoint;
			Cursor.SetVisibility(true);
			Cursor.SetWorldLocation(ImpactPoint);
			NiagaraDataInterfaceArray::SetNiagaraArrayVectorValue(LaserTraceFx, n"User.PointArray", 0, WidgetInteraction.GetWorldLocation(), false);
			NiagaraDataInterfaceArray::SetNiagaraArrayVectorValue(LaserTraceFx, n"User.PointArray", 1, ImpactPoint, false);
		}
	}

	float PressTime = 0;
	// 模拟左键按下
	UFUNCTION()
	void SimMouseLeftPress()
	{
		if (!bActive)
			return;

		PressTime = System::GetGameTimeInSeconds();
		WidgetInteraction.PressPointerKey(EKeys::LeftMouseButton);
	}

	// 模拟左键抬起
	UFUNCTION()
	void SimMouseLeftRelease()
	{
		if (!bActive)
			return;

		auto ReleaseTime = System::GetGameTimeInSeconds();
		bool bClicked = (ReleaseTime - PressTime) < 0.3f;
		PressTime = ReleaseTime;
		WidgetInteraction.ReleasePointerKey(EKeys::LeftMouseButton);
		if(HCPlayerController::IsLocked())
		{
			return;// 输入锁定时只允许点击UI
		}
		// 把点击事件传递到3D物体上
		if (bClicked && !WidgetInteraction.IsOverHitTestVisibleWidget())
		{
			auto Start = StartNode.GetWorldLocation();
			auto End = Start + StartNode.ForwardVector * 10000;
			TArray<AActor> IgnoreActors;
			IgnoreActors.Add(GetOwner());
			FHitResult HitResult;
			bool bHitSomething = System::LineTraceSingle(Start, End, ETraceTypeQuery::Visibility, true, IgnoreActors, EDrawDebugTrace::ForDuration, HitResult, true);
			if (bHitSomething)
			{
				AActor HitActor = HitResult.GetActor();
				if (HitActor.ClassPrivate.IsChildOf(ACharacter::StaticClass()))
				{
					HitActor.OnClicked.Broadcast(HitActor, EKeys::LeftMouseButton);
				}
			}
		}
	}
};