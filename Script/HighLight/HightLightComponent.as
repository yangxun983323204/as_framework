// 高亮组件
class UHightLightComponent_AS : UActorComponent
{
	UPROPERTY()
	int CustomDepthStencilValue = 128;

	FMessageDelegate TestHighLightOpenDelegate;
	FMessageDelegate TestHighLightCloseDelegate;

	int Msg_TestHighLightOpen;
	int Msg_TestHighLightClose;

	// 临时使用的图元组件数组
	UPROPERTY(NotVisible)
	TArray<UPrimitiveComponent> TmpPrimitiveCpts;

	// 图元组件数组
	UPROPERTY(NotVisible)
	TArray<UPrimitiveComponent> PrimitiveCpts;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// 初始就获取到所有的图元组件
		PrimitiveCpts.Empty();
		GetAllPrimitive(GetOwner(), PrimitiveCpts);

		Msg_TestHighLightOpen = UMessageCenterExt::MakeId(EHCMsgModule::Test, EHCMsgType::HighLight, EHCMsgFunc::None, EHCMsgId::Open);
		Msg_TestHighLightClose = UMessageCenterExt::MakeId(EHCMsgModule::Test, EHCMsgType::HighLight, EHCMsgFunc::None, EHCMsgId::Close);
		TestHighLightOpenDelegate.BindUFunction(this, n"OnTestHighLightOpen");
		TestHighLightCloseDelegate.BindUFunction(this, n"OnTestHighLightClose");

		UMessageCenter::Instance.Listen(TestHighLightOpenDelegate, Msg_TestHighLightOpen);
		UMessageCenter::Instance.Listen(TestHighLightCloseDelegate, Msg_TestHighLightClose);
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		UMessageCenter::Instance.UnListen(TestHighLightOpenDelegate, Msg_TestHighLightOpen);
		UMessageCenter::Instance.UnListen(TestHighLightCloseDelegate, Msg_TestHighLightClose);
	}

	// 启禁用高亮
	UFUNCTION()
	void SetHighLight(bool bEnable)
	{
		for (auto Cpt : PrimitiveCpts)
		{
			Cpt.SetRenderCustomDepth(bEnable);
			Cpt.SetCustomDepthStencilValue(CustomDepthStencilValue);
		}
	}

	// 获取actor上所有的图元组件，包括子actor的
	UFUNCTION()
	void GetAllPrimitive(AActor Root, TArray<UPrimitiveComponent>& OutPrimitives)
	{
		TmpPrimitiveCpts.Empty();
		Root.GetComponentsByClass(UPrimitiveComponent::StaticClass(), TmpPrimitiveCpts);
		OutPrimitives.Append(TmpPrimitiveCpts);
		// 子物体
		TArray<AActor> Actors;
		Root.GetAllChildActors(Actors, true);
		for (AActor CA : Actors)
		{
			GetAllPrimitive(CA, OutPrimitives);
		}
	}

	UFUNCTION()
	void OnTestHighLightOpen(int Id, FString Data)
	{
		SetHighLight(true);
	}

	UFUNCTION()
	void OnTestHighLightClose(int Id, FString Data)
	{
		SetHighLight(false);
	}
};