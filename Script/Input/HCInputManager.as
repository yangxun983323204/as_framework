enum EInputType
{
	None = 0,
	PC,
	LinkXR,
	VR
}

// VR节点
enum EVrNodeType
{
	LeftHand = 0,
	RightHand,
	Head,

	Max,
}

struct FInputTypeChangeMsg
{
	UPROPERTY()
	EInputType From;

	UPROPERTY()
	EInputType To;
}

// 输入管理
class UHCInputManager_AS : UScriptGameInstanceSubsystem
{
	private EInputType InputType = EInputType::PC;

	// 获取交互类型
	UFUNCTION(BlueprintPure)
	EInputType GetInputType()
	{
		return InputType;
	}

	UFUNCTION()
	void SetInputType(EInputType Type)
	{
		auto Old = InputType;
		InputType = Type;
		if (Old != InputType)
		{
			if (InputType == EInputType::VR)
			{
				EnableVR();
			}
			else
			{
				EnableVR();
			}

			auto Id = UMessageCenterExt::MakeId(EHCMsgModule::Product, EHCMsgType::Input, EHCMsgFunc::None, EHCMsgId::Change);
			auto MsgData = FInputTypeChangeMsg();
			MsgData.From = Old;
			MsgData.To = InputType;
			FString Json;
			FJsonObjectConverter::UStructToJsonObjectString(MsgData, Json);
			UMessageCenter::Instance.Send(Id, Json);
		}
	}

	void EnableVR()
	{
		if (!World.IsEditorWorld())
		{
			HeadMountedDisplay::EnableHMD(true);
		}
		else
		{
			Print("Is play in editor");
		}
	}

	void DisableVR()
	{
		if (!World.IsEditorWorld())
		{
			HeadMountedDisplay::EnableHMD(false);
		}
		else
		{
			Print("Is play in editor");
		}
	}

	bool IsVRDeviceConnected()
	{
		bool bHeadConnected = HeadMountedDisplay::IsHeadMountedDisplayConnected();

		FXRMotionControllerData LeftData;
		HeadMountedDisplay::GetMotionControllerData(this, EControllerHand::Left, LeftData);
		bool bLeftConnected = LeftData.bValid;

		FXRMotionControllerData RightData;
		HeadMountedDisplay::GetMotionControllerData(this, EControllerHand::Right, RightData);
		bool bRightConnected = RightData.bValid;

		Log(f"VR状态 头盔:{bHeadConnected}, 左手:{bLeftConnected}, 右手:{bRightConnected}");

		return bHeadConnected && bRightConnected;
	}
};