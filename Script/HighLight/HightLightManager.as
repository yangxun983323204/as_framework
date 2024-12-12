class UHightLightManager_AS : UObject
{

	FMessageDelegate InputLockEventDelegate;
	FMessageDelegate InputUnLockEventDelegate;

	void Init()
	{
		int Msg = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::Lock);
		InputLockEventDelegate.BindUFunction(this, n"OnInputLock");
		UMessageCenter::Instance.Listen(InputLockEventDelegate, Msg);

		int Msg2 = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::UnLock);
		InputUnLockEventDelegate.BindUFunction(this, n"OnInputUnLock");
		UMessageCenter::Instance.Listen(InputUnLockEventDelegate, Msg2);
	}

	void DeInit()
	{
		if (UMessageCenter::Instance != nullptr)
		{
			int Msg = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::Lock);
			UMessageCenter::Instance.UnListen(InputLockEventDelegate, Msg);

			int Msg2 = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::UnLock);
			UMessageCenter::Instance.UnListen(InputUnLockEventDelegate, Msg2);
		}
	}

	UFUNCTION()
	private void OnInputLock(int Id, FString Args)
	{
		TArray<AActor> PostActors;
		Gameplay::GetAllActorsOfClass(APostProcessVolume::StaticClass(), PostActors);
		for (auto A : PostActors)
		{
			auto PostActor = Cast<APostProcessVolume>(A);
			// 主关卡的后处理是程序侧放置的，不是美术资产里的
			if (PostActor.Tags.Contains(n"cmdr-outline"))
			{
				PostActor.SetbEnabled(false);
				Print(f"{PostActor} SetbEnabled false");
			}
		}
	}

	UFUNCTION()
	private void OnInputUnLock(int Id, FString Args)
	{
		TArray<AActor> PostActors;
		Gameplay::GetAllActorsOfClass(APostProcessVolume::StaticClass(), PostActors);
		for (auto A : PostActors)
		{
			auto PostActor = Cast<APostProcessVolume>(A);
			if (PostActor.Tags.Contains(n"cmdr-outline"))
			{
				PostActor.SetbEnabled(true);
				Print(f"{PostActor} SetbEnabled true");
			}
		}
	}
};