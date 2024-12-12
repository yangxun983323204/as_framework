#include "DynamicLevelSubsystem.h"

#include "Engine/LevelStreamingDynamic.h"

void UDynamicLevelSubsystem::LoadStreamLevel(FName LevelName, bool bMakeVisibleAfterLoad, bool bShouldBlockOnLoad)
{
    ULevelStreamingDynamic* StreamingLevel;
    StreamingLevel = NewObject<ULevelStreamingDynamic>(GWorld, ULevelStreamingDynamic::StaticClass(), NAME_None, RF_Public, NULL);
    StreamingLevel->SetWorldAssetByPackageName(LevelName);
    GetWorld()->AddStreamingLevel(StreamingLevel);
    StreamingLevel->SetShouldBeLoaded(true);
    StreamingLevel->SetShouldBeVisible(bMakeVisibleAfterLoad);
    StreamingLevel->bShouldBlockOnUnload = bShouldBlockOnLoad;
}
