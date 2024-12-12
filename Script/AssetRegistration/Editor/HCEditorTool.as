// 编辑器工具
namespace HCEditorTool_AS
{
	UFUNCTION()
	void CollectPresenter()
	{
		FString RegPath = "/foo/DA_HCPresenterCollection.DA_HCPresenterCollection";
		auto Obj = LoadObject(nullptr, RegPath);
		auto Reg = Cast<UHCPresenterCollection_AS>(Obj);

		TArray<UObject> Presenters;
		auto ClassName = UHCPresenterBase_AS::StaticClass();
		AssetRegistry::GetBlueprintCDOsByParentClass(ClassName, Presenters);
		Reg.Presenters.Empty();
		for (auto P : Presenters)
		{
			Reg.Presenters.AddUnique(P.ClassPrivate);
		}
	}
};