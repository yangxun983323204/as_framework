namespace HCToast_AS
{
	const FString ToastPresenterClassPath =
		"/CmdrHealthCommission/BluePrints/UI/Toast/BP_HCToastPresenter.BP_HCToastPresenter_C";

	// 消息提示小组件
	UFUNCTION()
	void ShowText(FText Text, float DurationSec = 2)
	{
		UClass Clazz = Cast<UClass>(LoadObject(nullptr, ToastPresenterClassPath));
		if (Clazz == nullptr)
		{
			Error(f"{ToastPresenterClassPath}不是有效的ToastPresenter类路径");
			return;
		}

		auto PresenterMgr = UHCPresenterManager_AS::Get();
		auto Presenter = Cast<UHCToastPresenter_AS>(PresenterMgr.Open(Clazz));
		if (Presenter == nullptr)
		{
			Error(f"{ToastPresenterClassPath}不是有效的ToastPresenter类");
			return;
		}

		Presenter.ShowText(Text, DurationSec);
	}

	// 消息提示小组件
	UFUNCTION()
	void ShowStr(FString Str, float DurationSec = 2)
	{
		ShowText(FText::FromString(Str), DurationSec);
	}
};