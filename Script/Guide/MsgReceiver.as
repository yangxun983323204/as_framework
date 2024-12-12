enum EMsgRecMatchType
{
	FullMatch,
	StartWith,
	EndWith,
	Contains,
	Any,
	None,
}

class UMsgRecComponent : UActorComponent
{
	UPROPERTY()
	EHCMsgModule MsgModule = EHCMsgModule::Product;

	UPROPERTY()
	EHCMsgType MsgType = EHCMsgType::None;

	UPROPERTY()
	EHCMsgFunc MsgFunc = EHCMsgFunc::None;

	UPROPERTY()
	EHCMsgId MsgId = EHCMsgId::None;

	UPROPERTY()
	FString MsgContent;

	int InstanceId;

	FMultiActionInt OnRecEvent;

	UPROPERTY()
	EMsgRecMatchType MsgMatchType = EMsgRecMatchType::FullMatch;

	private FMessageDelegate MsgDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int Msg = UMessageCenterExt::MakeId(MsgModule, MsgType, MsgFunc, MsgId);

		MsgDelegate.BindUFunction(this, n"OnRecMsg");
		UMessageCenter::Instance.Listen(MsgDelegate, Msg);
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		int Msg = UMessageCenterExt::MakeId(MsgModule, MsgType, MsgFunc, MsgId);
		if (UMessageCenter::Instance != nullptr)
			UMessageCenter::Instance.UnListen(MsgDelegate, Msg);
	}

	UFUNCTION()
	private void OnRecMsg(int Id, FString Args)
	{
		switch (MsgMatchType)
		{
			case EMsgRecMatchType::FullMatch:
				if (Args != MsgContent)
					return;
				break;
			case EMsgRecMatchType::StartWith:
				if (!Args.StartsWith(MsgContent))
					return;
				break;
			case EMsgRecMatchType::EndWith:
				if (!Args.EndsWith(MsgContent))
					return;
				break;
			case EMsgRecMatchType::Contains:
				if (!Args.Contains(MsgContent))
					return;
				break;
			case EMsgRecMatchType::Any:
				break;
			case EMsgRecMatchType::None:
				return;
		}
		OnRecEvent.Broadcast(InstanceId);
	}
};