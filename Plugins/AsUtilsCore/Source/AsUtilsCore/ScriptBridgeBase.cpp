#include "ScriptBridgeBase.h"

#include "Engine/World.h"

UScriptBridgeBase* UScriptBridgeBase::Inst = nullptr;

void UScriptBridgeBase::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
    Inst = this;
}

void UScriptBridgeBase::Deinitialize()
{
    Super::Deinitialize();
    if(Inst == this)
        Inst = nullptr;
}

bool UScriptBridgeBase::HandleS(const FString& Func, const FString& JsonParams)
{
    auto Instance = GetInstance();
    if(Instance == nullptr)
        return false;
    return GetInstance()->Handle(Func, JsonParams);
}

UScriptBridgeBase* UScriptBridgeBase::GetInstance()
{
    return Inst;
}
