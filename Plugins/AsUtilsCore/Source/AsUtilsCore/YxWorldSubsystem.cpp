
#include "YxWorldSubsystem.h"

FString UYxWorldSubsystem::AddRef(UObject* UObj)
{
    FString Guid{};
    if (TryFindRefGuid(UObj, Guid))
    {
        return Guid;
    }

    Guid = FGuid::NewGuid().ToString();
    ObjectsRef.Add(Guid, UObj);
    return Guid;
}

bool UYxWorldSubsystem::RemoveRef(FString& Guid)
{
    if (ObjectsRef.Contains(Guid))
    {
        ObjectsRef.Remove(Guid);
        return true;
    }

    return false;
}

bool UYxWorldSubsystem::TryGetUObject(FString& Guid, UObject*& OutObj)
{
    if (ObjectsRef.Contains(Guid))
    {
        OutObj = ObjectsRef[Guid];
        return true;
    }

    return false;
}

bool UYxWorldSubsystem::TryFindRefGuid(UObject* UObj, FString& OutGuid)
{
    if (!UObj)
    {
        UE_LOG(LogTemp, Error, TEXT("TryFindRefGuid传入nullptr!"))
        return false;
    }

    for (auto KV : ObjectsRef)
    {
        if (KV.Value == UObj)
        {
            OutGuid = KV.Key;
            return true;
        }
    }

    return false;
}

void UYxWorldSubsystem::Deinitialize()
{
    Super::Deinitialize();
    ObjectsRef.Empty();
}
