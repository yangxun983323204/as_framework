// 消息提示小组件
class UHCToastPresenter_AS : UHCPresenterBase_AS
{
	FTimerHandle TimerHandle;

	UHCToastViewBase_AS GetTypedView()
	{
		return Cast<UHCToastViewBase_AS>(View);
	}

    void OnOpened() override
	{
		Super::OnOpened();
        //OnTimeEnd();
	}

	UFUNCTION()
	void ShowText(FText Text, float DurationSec = 2)
	{
		GetTypedView().SetShowText(Text);
		GetTypedView().SetVisibility(ESlateVisibility::HitTestInvisible);
		TimerHandle = System::SetTimer(this, n"OnTimeEnd", DurationSec, false);
	}

	UFUNCTION()
	void OnTimeEnd()
	{
		GetTypedView().SetShowText(FText::FromString(""));
		GetTypedView().SetVisibility(ESlateVisibility::Collapsed);
	}
};