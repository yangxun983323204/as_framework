#pragma once

#include "CoreMinimal.h"
#include "ObjectTrace.h"
#include "YxWorldSubsystem.generated.h"

/**
 *
 */
UCLASS()
class ASUTILSCORE_API UYxWorldSubsystem : public UWorldSubsystem
{
    GENERATED_BODY()
public:
    /** 为UObject添加引用，防止垃圾回收 */
    UFUNCTION(BlueprintCallable)
    FString AddRef(UObject* UObj);

    /** 从此对象中移除对指定guid的UObject的引用 */
    UFUNCTION(BlueprintCallable)
    bool RemoveRef(FString& Guid);

    /** 尝试获取指定guid的uobject */
    UFUNCTION(BlueprintCallable)
    bool TryGetUObject(FString& Guid, UObject*& OutObj);

    /** 尝试查找对象引用的guid */
    UFUNCTION(BlueprintCallable)
    bool TryFindRefGuid(UObject* UObj, FString& OutGuid);

    virtual void Deinitialize() override;

private:
    UPROPERTY(VisibleAnywhere)
    TMap<FString, UObject*> ObjectsRef;
};
