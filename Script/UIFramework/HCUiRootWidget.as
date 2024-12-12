// PC和LinkXR模式下的UI挂载面板
class UHCUiRootWidget : UUserWidget
{
	UPROPERTY(meta = (Bindwidget))
	UCanvasPanel Root;
};

// 获取UHCUiRootWidget的子蓝图类型
UFUNCTION(BlueprintPure)
UClass GetHCUiRootWidgetType()
{
	auto TypeObj = LoadObject(nullptr, "/CmdrHealthCommission/BluePrints/UIFramework/WBP_HCUiRootWidget.WBP_HCUiRootWidget_C");
	return Cast<UClass>(TypeObj);
}