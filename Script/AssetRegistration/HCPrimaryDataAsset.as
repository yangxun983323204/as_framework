// 主资源引用
class UHCPrimaryDataAsset_AS : UPrimaryDataAsset
{
	// PC界面容器类型
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	TSubclassOf<UHCUiRootWidget> PcViewRootWidget;

	// VR界面容器类型
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	TSubclassOf<AHCVrUiContainer_AS> VRViewContainerType;

	// VR界面容器测试类型(支持鼠标点击)
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	TSubclassOf<AHCVrUiContainer_AS> VRViewContainerTestType;

	// 界面控制器类型
	UPROPERTY(EditAnywhere)
	UHCPresenterCollection_AS PresenterRegister;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	TMap<FName, TSubclassOf<UObject>> ExtraTypes;

	// 查找界面控制器类型（主要是AS类型找蓝图子类型）
	TSubclassOf<UHCPresenterBase_AS>
	FindPresenterType(TSubclassOf<UHCPresenterBase_AS> InType)
	{
		for (auto Type : PresenterRegister.Presenters)
		{
			if (Type.Get().IsChildOf(InType.Get()))
			{
				return Type;
			}
		}

		auto ErrorMsg = f"未向`DA_HCPresenterCollection`中注册界面控制器类型{InType.Get()}";
		Print(ErrorMsg, 5.f, FLinearColor::Red);
		Error(ErrorMsg);
		return nullptr;
	}
};