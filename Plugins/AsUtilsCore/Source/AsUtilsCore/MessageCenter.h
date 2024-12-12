#pragma once

#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "MessageCenter.generated.h"

USTRUCT()
struct FMessage
{
	GENERATED_BODY()
public:
	UPROPERTY()
	int32 Id=0;
	UPROPERTY()
	FString Args;
};

DECLARE_DYNAMIC_DELEGATE_TwoParams(FMessageDelegate, int32, Id, FString, Args);

USTRUCT()
struct FTypedCallback
{
	GENERATED_BODY()
public:
	int32 Id=0;
	UPROPERTY()
	TArray<FMessageDelegate> Callbacks;
};

USTRUCT()
struct FTypedCallbackDelay
{
	GENERATED_BODY()
public:
	int32 Id=0;
	UPROPERTY()
	FMessageDelegate Callback;
	// -1为移除，+1为添加
	int8 DelayType;
};

/**
 *
 */
UCLASS()
class ASUTILSCORE_API UMessageCenter : public UGameInstanceSubsystem
{
	GENERATED_BODY()

public:
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;
	virtual void Deinitialize() override;

public:

	UFUNCTION(BlueprintCallable, BlueprintPure)
	static UMessageCenter* GetInstance();

	UFUNCTION(BlueprintCallable)
	void Send(int32 Id, FString Args);

	UFUNCTION(BlueprintCallable)
	void Listen(UPARAM(DisplayName="Event") FMessageDelegate Delegate, int32 Id);

	UFUNCTION(BlueprintCallable)
	void UnListen(UPARAM(DisplayName="Event") FMessageDelegate Delegate, int32 Id);

	UFUNCTION(BlueprintCallable)
	void ListenGlobal(UPARAM(DisplayName="Event") FMessageDelegate Delegate);

	UFUNCTION(BlueprintCallable)
	void UnListenGlobal(UPARAM(DisplayName="Event") FMessageDelegate Delegate);

private:
	bool Tick(float DeltaSeconds);

	void EnqueueMsg(FMessage Msg);
	void DequeueMsg(FMessage& OutMsg);

	FTickerDelegate TickDelegate;
	FDelegateHandle TickDelegateHandle;

	UPROPERTY()
	TMap<int32, FTypedCallback> Listeners;
	UPROPERTY()
	TArray<FTypedCallbackDelay> DelayCallbacks;
	bool bIsExecuteListeners = false;

	UPROPERTY()
	FTypedCallback GlobalListeners;
	UPROPERTY()
	TArray<FTypedCallbackDelay> DelayGlobalCallbacks;
	bool bIsExecuteGlobalListeners = false;

	UPROPERTY()
	TArray<FMessage> MessageQueue;
	UPROPERTY()
	TArray<FMessage> MessageQueue2;

	static UMessageCenter* Inst;

	FCriticalSection Mutex;
};
