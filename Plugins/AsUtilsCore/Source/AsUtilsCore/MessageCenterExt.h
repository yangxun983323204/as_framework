#pragma once

#include "CoreMinimal.h"
#include "UObject/Object.h"
#include "MessageCenterExt.generated.h"

/**
 * 消息中心扩展
 */
UCLASS()
class ASUTILSCORE_API UMessageCenterExt : public UObject
{
    GENERATED_BODY()

public:
    /** 构造一条指挥官消息id */
    UFUNCTION(BlueprintCallable, BlueprintPure)
    static int MakeId(uint8 ModuleId, uint8 TypeId, uint8 FuncId, uint8 MsgId);

    /** 分解一条指挥官消息id */
    UFUNCTION(BlueprintCallable, BlueprintPure)
    static void ParseId(int InCmdrId, uint8& OutModuleId, uint8& OutTypeId, uint8& OutFuncId, uint8& OutMsgId);
};
