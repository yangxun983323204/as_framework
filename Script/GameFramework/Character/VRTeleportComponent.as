// VR的抛物线传送功能组件
class UVRTeleportComponent : UActorComponent
{
	// 对粒子组件的引用
	UPROPERTY(NotEditable)
	UNiagaraComponent TeleportTraceFx;

	UPROPERTY()
	UNiagaraSystem TeleportTraceFxAsset;

	// 落点actor类型
	UPROPERTY()
	TSubclassOf<AActor> PlacementClass;

	// 落点actor
	UPROPERTY(NotVisible)
	private AActor PlacementActor;

	private bool bIsTracing = false;
	private bool bIsValidTeleportLocation = false;
	private FVector ProjectedTeleportLocation = FVector::ZeroVector;

	private TArray<FVector> TeleportTracePathPositions;

	// 抛物线的起始节点
	UPROPERTY(NotVisible)
	private USceneComponent StartNode;

	// 设置抛物线的起始点关联的场景组件
	UFUNCTION()
	void SetBindNode(USceneComponent SceneCpt)
	{
		StartNode = SceneCpt;
		TeleportTraceFx = Cast<UNiagaraComponent>(Owner.CreateComponent(UNiagaraComponent::StaticClass(), n"TeleportTraceFx"));
		TeleportTraceFx.SetAsset(TeleportTraceFxAsset);
		TeleportTraceFx.SetVisibility(false);
	}

	// 开启抛物线追踪
	UFUNCTION()
	void StartTeleportTrace()
	{
		if (bIsTracing)
			return;

		bIsTracing = true;
		bIsValidTeleportLocation = false;
		TeleportTraceFx.SetVisibility(true);
		PlacementActor = SpawnActor(PlacementClass);
		PlacementActor.RootComponent.SetVisibility(false);
	}

	// 关闭抛物线追踪
	UFUNCTION()
	void EndTeleportTrace()
	{
		if (!bIsTracing)
			return;

		bIsTracing = false;
		PlacementActor.DestroyActor();
		TeleportTraceFx.SetVisibility(false);
	}

	UFUNCTION(BlueprintPure)
	bool GetIsTracing()
	{
		return bIsTracing;
	}

	/**
	 * 获取当前的抛物线落点位置
	 * @return 是否允许传送
	 */
	UFUNCTION(BlueprintPure)
	bool TryGetTeleportLocation(FVector& OutLocation)
	{
		if (!bIsTracing)
			return false;

		OutLocation = ProjectedTeleportLocation;
		return bIsValidTeleportLocation;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		if (bIsTracing)
			TeleportTrace();
	}

	private void TeleportTrace()
	{
		float LocalTeleportLaunchSpeed = 650.0f;
		float LocalTeleportProjectileRadius = 3.6f;
		float LocalNavMeshCellHeight = 8;

		FVector StartPos = StartNode.GetWorldLocation();
		FVector ForwardVector = StartNode.GetForwardVector();

		FHitResult Hit;
		FVector _;
		TArray<EObjectTypeQuery> QueryTypes;
		QueryTypes.Add(EObjectTypeQuery::WorldStatic);
		TArray<AActor> ActorsToIgnore;
		FVector LaunchVelocity = FVector(LocalTeleportLaunchSpeed) * ForwardVector;
		Gameplay::Blueprint_PredictProjectilePath_ByObjectType(Hit, TeleportTracePathPositions, _, StartPos, LaunchVelocity, true, LocalTeleportProjectileRadius, QueryTypes, false, ActorsToIgnore, EDrawDebugTrace::None, 0);
		TeleportTracePathPositions.Insert(StartPos);
		FVector TmpProjectedLocation;
		bool bReachable = UNavigationSystemV1::ProjectPointToNavigation(Hit.Location, TmpProjectedLocation, nullptr, nullptr);
		ProjectedTeleportLocation = FVector(TmpProjectedLocation.X, TmpProjectedLocation.Y, TmpProjectedLocation.Z - LocalNavMeshCellHeight);
		if (!bReachable)
		{
			// @fixed 如果导航不可达，再判断高度和倾斜度
			if (Math::RadiansToDegrees(FVector::UpVector.AngularDistance(Hit.Normal)) < 20)
			{
				auto Pawn = S::GGPC(0).ControlledPawn;
				if (Math::Abs(Hit.Location.Z - Pawn.GetActorLocation().Z + 90) < 20)
				{
					bReachable = true;
					ProjectedTeleportLocation = Hit.Location;
				}
			}
		}
		if (bReachable != bIsValidTeleportLocation)
		{
			bIsValidTeleportLocation = bReachable;
			PlacementActor.RootComponent.SetVisibility(bIsValidTeleportLocation);
		}

		PlacementActor.SetActorLocation(ProjectedTeleportLocation);
		NiagaraDataInterfaceArray::SetNiagaraArrayVector(TeleportTraceFx, n"User.PointArray", TeleportTracePathPositions);
	}
};