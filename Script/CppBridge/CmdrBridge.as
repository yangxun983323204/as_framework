delegate bool FBridgeFunc(FString JsonParams);

// 便于c++调用as的方法
class UCmdrBridge_AS : UScriptBridgeBase
{
	private FString LastLoadLevel;
	FMultiActionString OnLevelInitedEvent;

	private TMap<FString, FBridgeFunc> ScriptFunMap;
	private TMap<UClass, UObject> TypeInstances;

	UFUNCTION(BlueprintOverride)
	bool ScriptOverrideGameModeClass(TSubclassOf<AGameModeBase> InGameModeClass,
									 TSubclassOf<AGameModeBase>& OutGameModeClass, FString MapName,
									 FString Options, FString Portal)
	{
		LastLoadLevel = MapName;
		System::SetTimerForNextTick(this, "OnLevelInited");

		Print(f"In:{InGameModeClass.Get()}, map:{MapName}, opt:{Options}, portal:{Portal}");
		if (System::IsDedicatedServer())
		{
		}
		else if (System::IsStandalone())
		{
		}
		return false;
	}

	UFUNCTION()
	private void OnLevelInited()
	{
		OnLevelInitedEvent.Broadcast(LastLoadLevel);
	}

	// 注册给c++调用的方法
	void Reg(FString InName, FBridgeFunc InFunc)
	{
		ScriptFunMap.Add(InName, InFunc);
	}

	// 注册给c++调用的方法, Func需符合FBridgeFunc的定义。注意，这样注册产生的uobject不会释放
	void RegWithClass(UClass InClass, FString FuncName, FName ImplName)
	{
		auto Inst = TypeInstances.FindOrAdd(InClass, NewObject(this, InClass));
		FBridgeFunc Action;
		Action.BindUFunction(Inst, ImplName);
		Reg(FuncName, Action);
	}

	// 移除给c++调用的方法
	void UnReg(FString InName)
	{
		ScriptFunMap.Remove(InName);
	}

	//=====================================================================================

	// 初始注册指定的所有方法供c++调用
	void InitAllFunctions()
	{
		//RegWithClass(UOverrideBack::StaticClass(), "Back", n"ImplBack");
	}

	// c++调用
	UFUNCTION(BlueprintOverride)
	bool Handle(FString InName, FString JsonParams)
	{
		FBridgeFunc Func;
		if (!ScriptFunMap.Find(InName, Func))
		{
			Warning(f"脚本层未注册{InName}方法给c++");
			return false;
		}

		bool b = Func.ExecuteIfBound(JsonParams);
		Print(f"c++调用脚本{InName}方法，返回值：{b}");
		return b;
	}
};