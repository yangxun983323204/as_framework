// VR UI追踪的绑定类型
enum EVrUiBindType
{
	LeftHand = 0,
	RightHand,
	Head,
	WorldFix,
}

// VR UI的挂载参数
struct FVrUiBindParams
{
	UPROPERTY()
	EVrUiBindType Type = EVrUiBindType::Head;
	UPROPERTY()
	bool bLockAngleX = true;
	UPROPERTY()
	bool bLockAngleY = true;
	UPROPERTY()
	bool bLockAngleZ = true;
	UPROPERTY()
	FVector2D Size = FVector2D(1920, 1080);
	UPROPERTY()
	FVector2D Pivot = FVector2D(0.5, 0.5);
	UPROPERTY()
	FTransform LocalTransform = FTransform(FVector(200, 0, 0));
}

// 视图基类
class UHCViewBase_AS : UUserWidget
{
	UPROPERTY(BlueprintReadOnly, VisibleInstanceOnly)
	UHCPresenterBase_AS Presenter;

	// 是否是VR模式的UI
	UPROPERTY(BlueprintReadOnly, VisibleAnywhere)
	bool bIsVrUi = false;

	// VR模式的UI挂载参数
	UPROPERTY(EditDefaultsOnly)
	FVrUiBindParams VrBindParams;

	// PC模式的UI布局参数
	UPROPERTY(EditDefaultsOnly)
	FAnchorData PcLayout;

	default PcLayout.Anchors.Maximum = FVector2D::UnitVector;

	// 是否在关闭时延迟，可用于做关闭动画
	UPROPERTY(BlueprintReadOnly, EditDefaultsOnly, VisibleAnywhere)
	bool bDelayClose = false;

	EInputType CreateType;

	// 下面三个重写使UI不透明的部分阻塞事件，不穿透到PlayerController

	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonDoubleClick(FGeometry InMyGeometry, FPointerEvent InMouseEvent)
	{
		return FEventReply::Handled();
	}

	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonUp(FGeometry MyGeometry, FPointerEvent MouseEvent)
	{
		return FEventReply::Handled();
	}

	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonDown(FGeometry MyGeometry, FPointerEvent MouseEvent)
	{
		return FEventReply::Handled();
	}

	// 当关联到界面控制器，此时还不可见
	UFUNCTION()
	void SetPresenter(UHCPresenterBase_AS InPresenter)
	{
		Presenter = InPresenter;
		BP_SetPresenter(InPresenter);
	}

	UFUNCTION(BlueprintEvent)
	void BP_SetPresenter(UHCPresenterBase_AS InPresenter)
	{
		Presenter = InPresenter;
	}

	// 当显示时
	UFUNCTION()
	void OnShow()
	{
		BP_OnShow();
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnShow()
	{}

	// 启用了bDelayClose之后，ui框架用于通知界面即将关闭
	UFUNCTION()
	void OnWillClose()
	{
		BP_OnWillClose();
	}

	UFUNCTION(BlueprintEvent)
	void BP_OnWillClose()
	{}

	// 启用了bDelayClose之后，ui框架用于判断是否延迟完成、可以关闭
	UFUNCTION(BlueprintEvent)
	bool IsReadyToClose()
	{
		return true;
	}
};