// default
class AHCPlayerController_AS : APlayerController
{
	//default CheatClass = UHCCheatManager_AS::StaticClass(); // 设定作弊管理器

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		HCPlayerControllerInject::Do(this);
	}
};