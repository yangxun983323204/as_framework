// 消息发送器，用来在Editor中发测试消息
class AMessageSender_AS : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	// 消息模块
	UPROPERTY(EditAnywhere)
	EHCMsgModule Module = EHCMsgModule::Product;

	// 消息类型
	UPROPERTY(EditAnywhere)
	EHCMsgType MsgType = EHCMsgType::None;

	// 消息功能
	UPROPERTY(EditAnywhere)
	EHCMsgFunc MsgFunc = EHCMsgFunc::None;

	// 消息行为
	UPROPERTY(EditAnywhere)
	EHCMsgId MsgId = EHCMsgId::None;

	// 消息负载数据
	UPROPERTY(EditAnywhere)
	FString MsgData;

	// 是否观察所有消息
	UPROPERTY(EditAnywhere)
	bool bObserveMsg = false;

	FMessageDelegate GlobalMsgDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		GlobalMsgDelegate.BindUFunction(this, n"GlobalMsgRec");
		UMessageCenter::Instance.ListenGlobal(GlobalMsgDelegate);
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		if (UMessageCenter::Instance != nullptr)
		{
			UMessageCenter::Instance.UnListenGlobal(GlobalMsgDelegate);
		}
	}

	UFUNCTION(CallInEditor)
	void Send()
	{
		int Msg = UMessageCenterExt::MakeId(Module, MsgType, MsgFunc, MsgId);
		UMessageCenter::Instance.Send(Msg, MsgData);
	}

	UFUNCTION()
	void GlobalMsgRec(int Id, FString Data)
	{
		if (!bObserveMsg)
			return;

		EHCMsgModule HCMsgModule = EHCMsgModule::Product;
		EHCMsgType HCMsgType = EHCMsgType::None;
		EHCMsgFunc HCMsgFunc = EHCMsgFunc::None;
		EHCMsgId HCMsgId = EHCMsgId::None;

		if (!HCMsgUtils::ParseMsg(Id, HCMsgModule, HCMsgType, HCMsgFunc, HCMsgId))
		{
			Print(f"观察到非模块消息, {Id}");
		}
		else
		{
			Print(f"观察到模块消息, {HCMsgModule}, {HCMsgType}, {HCMsgFunc}, {HCMsgId}");
		}
	}
};