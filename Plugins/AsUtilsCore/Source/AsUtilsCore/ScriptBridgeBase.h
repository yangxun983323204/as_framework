#pragma once

#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "ScriptBridgeBase.generated.h"

/**
 *
 */
UCLASS(Abstract, Blueprintable, BlueprintType)
class ASUTILSCORE_API UScriptBridgeBase : public UGameInstanceSubsystem
{
    GENERATED_BODY()

public:
    void Initialize(FSubsystemCollectionBase& Collection) override;
    void Deinitialize() override;

    UFUNCTION(BlueprintCallable)
    static bool HandleS(const FString& Func, const FString& JsonParams);

    static UScriptBridgeBase* GetInstance();

    UFUNCTION(BlueprintImplementableEvent)
    bool Handle(const FString& Func, const FString& JsonParams);

    UFUNCTION(BlueprintImplementableEvent)
    bool ScriptOverrideGameModeClass(TSubclassOf<AGameModeBase> InGameModeClass, TSubclassOf<AGameModeBase>& OutGameModeClass, const FString& MapName, const FString& Options, const FString& Portal);

private:
    static UScriptBridgeBase* Inst;
};
