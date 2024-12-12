class UHCToastViewPC_AS : UHCToastViewBase_AS
{
	UPROPERTY(meta = (Bindwidget))
	UTextBlock Content;

	void SetShowText(FText InText) override
	{
        Content.Text = InText;
	}
};