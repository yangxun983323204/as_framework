class UHCPresenterCollection_AS : UDataAsset
{
    // 界面控制器类型
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	TArray<TSubclassOf<UHCPresenterBase_AS>> Presenters;
};