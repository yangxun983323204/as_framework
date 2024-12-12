// VR模式下UI的3D渲染和位置绑定容器
class AHCVrUiContainer_AS : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USceneComponent ScaleNode;

	UPROPERTY(DefaultComponent, Attach = ScaleNode)
	UWidgetComponent UiWidget;

	private UUserWidget TargetWidget;
	private FVrUiBindParams BindParams;

	private float Scale = 0.17;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ScaleNode.SetRelativeScale3D(FVector(Scale, Scale, Scale));
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		UpdateRotation(DeltaSeconds);
	}

	// 设置要显示的界面
	UFUNCTION()
	void SetUI(UUserWidget View, FVrUiBindParams Params)
	{
		TargetWidget = View;
		BindParams = Params;
		UiWidget.SetWidget(View);
		UiWidget.SetDrawSize(Params.Size);
		UiWidget.SetPivot(Params.Pivot);

		auto HCChar = Cast<ACharacter>(Gameplay::GetPlayerCharacter(0));
		if (HCChar != nullptr)
		{
			USceneComponent SceneCpt = nullptr;//HCChar.GetVRNode(EVrNodeType(Params.Type));
			if (SceneCpt != nullptr)
			{
				AttachToComponent(SceneCpt);
			}
			if (Params.Type == EVrUiBindType::Head)
			{
				ScaleNode.SetRelativeRotation(FRotator(0, 180, 0));
			}
		}

		Root.SetRelativeTransform(Params.LocalTransform);
	}

	// 更新UI面向
	void UpdateRotation(float DeltaSeconds)
	{
		// @todo 有点复杂，先不实现了
		if (BindParams.bLockAngleX && BindParams.bLockAngleY && BindParams.bLockAngleZ)
		{
			return;
		}
	}
};