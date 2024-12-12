#include "YxThreadHelper.h"

#include "Async/Async.h"
#include "Windows/WindowsPlatformTLS.h"

UYxThreadHelper* UYxThreadHelper::Inst = nullptr;

void UYxThreadHelper::Initialize(FSubsystemCollectionBase& Collection)
{
    Inst = this;
    Super::Initialize(Collection);
    MainThreadId =  FPlatformTLS::GetCurrentThreadId();
}

void UYxThreadHelper::Deinitialize()
{
    Super::Deinitialize();
    if(Inst == this)
    {
        Inst = nullptr;
    }
}

void UYxThreadHelper::ExecuteOnMain(FYxMainThreadDelegate InAction)
{
    if(MainThreadId == FPlatformTLS::GetCurrentThreadId())
    {
        auto _ =InAction.ExecuteIfBound();
    }
    else
    {
        AsyncTask(ENamedThreads::GameThread, [InAction]()
        {
            auto _ = InAction.ExecuteIfBound();
        });
    }
}
