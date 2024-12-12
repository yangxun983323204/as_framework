#pragma once

#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "YxThreadHelper.generated.h"

DECLARE_DYNAMIC_DELEGATE(FYxMainThreadDelegate);

/**
 * 线程助手
 */
UCLASS(BlueprintType)
class ASUTILSCORE_API UYxThreadHelper : public UGameInstanceSubsystem
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintPure)
    static UYxThreadHelper* GetInstance(){return Inst;}

    virtual void Initialize(FSubsystemCollectionBase& Collection) override;

    virtual void Deinitialize() override;

    UFUNCTION(BlueprintCallable)
    void ExecuteOnMain(FYxMainThreadDelegate InAction);

private:
    int MainThreadId;
    static UYxThreadHelper* Inst;
};
