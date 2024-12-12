#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "DynamicLevelSubsystem.generated.h"

/**
 *
 */
UCLASS(BlueprintType)
class ASUTILSCORE_API UDynamicLevelSubsystem : public UWorldSubsystem
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    void LoadStreamLevel(FName LevelName, bool bMakeVisibleAfterLoad, bool bShouldBlockOnLoad);
};
