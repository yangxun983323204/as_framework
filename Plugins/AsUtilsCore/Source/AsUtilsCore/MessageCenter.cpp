#include "MessageCenter.h"

UMessageCenter* UMessageCenter::Inst = nullptr;

void UMessageCenter::Initialize(FSubsystemCollectionBase& Collection)
{
	Super::Initialize(Collection);
	Inst = this;
	TickDelegate = FTickerDelegate::CreateUObject(this, &UMessageCenter::Tick);
	TickDelegateHandle = FTicker::GetCoreTicker().AddTicker(TickDelegate);
}

void UMessageCenter::Deinitialize()
{
	Super::Deinitialize();
	Inst = nullptr;
	FTicker::GetCoreTicker().RemoveTicker(TickDelegateHandle);
}

UMessageCenter* UMessageCenter::GetInstance()
{
	return Inst;
}

void UMessageCenter::Send(int32 Id, FString Args)
{
	EnqueueMsg({Id, Args});
}

void UMessageCenter::Listen(UPARAM(DisplayName="Event") FMessageDelegate Delegate, int32 Id)
{
	bool bIsInGameThread = IsInGameThread();
	if (!bIsInGameThread || bIsExecuteListeners)
	{
		auto Item = FTypedCallbackDelay();
		Item.Id = Id;
		Item.Callback = Delegate;
		Item.DelayType = 1;
		{
			FScopeLock Lock(&Mutex);
			DelayCallbacks.Add(Item);
		}
		return;
	}
	
	if(!Listeners.Contains(Id))
	{
		Listeners.Add(Id,{});
	}

	Listeners[Id].Callbacks.AddUnique(Delegate);
}

void UMessageCenter::UnListen(UPARAM(DisplayName="Event") FMessageDelegate Delegate, int32 Id)
{
	bool bIsInGameThread = IsInGameThread();
	if (!bIsInGameThread || bIsExecuteListeners)
	{
		auto Item = FTypedCallbackDelay();
		Item.Id = Id;
		Item.Callback = Delegate;
		Item.DelayType = -1;
		{
			FScopeLock Lock(&Mutex);
			DelayCallbacks.Add(Item);
		}
		return;
	}
	
	if(Listeners.Contains(Id))
	{
		Listeners[Id].Callbacks.Remove(Delegate);
	}
}

void UMessageCenter::ListenGlobal(FMessageDelegate Delegate)
{
	bool bIsInGameThread = IsInGameThread();
	if (!bIsInGameThread || bIsExecuteGlobalListeners)
	{
		auto Item = FTypedCallbackDelay();
		Item.Callback = Delegate;
		Item.DelayType = 1;
		{
			FScopeLock Lock(&Mutex);
			DelayGlobalCallbacks.Add(Item);
		}
		return;
	}
	
	GlobalListeners.Callbacks.AddUnique(Delegate);
}

void UMessageCenter::UnListenGlobal(FMessageDelegate Delegate)
{
	bool bIsInGameThread = IsInGameThread();
	if (!bIsInGameThread || bIsExecuteGlobalListeners)
	{
		auto Item = FTypedCallbackDelay();
		Item.Callback = Delegate;
		Item.DelayType = -1;
		{
			FScopeLock Lock(&Mutex);
			DelayGlobalCallbacks.Add(Item);
		}
		return;
	}
	
	GlobalListeners.Callbacks.Remove(Delegate);
}

bool UMessageCenter::Tick(float DeltaSeconds)
{
	{
		FScopeLock Lock(&Mutex);
		auto Temp = MessageQueue;
		MessageQueue = MessageQueue2;
		MessageQueue2 = Temp;
		MessageQueue2.Empty();
	}
	// 处理子线程产生的的消息注册、移除
	{
		FScopeLock Lock(&Mutex);
		for (auto& I : DelayCallbacks)
		{
			auto Id = I.Id;
			auto Callback = I.Callback;
			if (!Listeners.Contains(Id))
			{
				Listeners.Add(Id,{});
			}
			if (I.DelayType == -1)
				Listeners[Id].Callbacks.Remove(Callback);
			else if(I.DelayType == 1)
				Listeners[Id].Callbacks.AddUnique(Callback);
		}
		DelayCallbacks.Empty();

		for (auto& I : DelayGlobalCallbacks)
		{
			auto Callback = I.Callback;
			if (I.DelayType == -1)
				GlobalListeners.Callbacks.Remove(Callback);
			else if(I.DelayType == 1)
				GlobalListeners.Callbacks.AddUnique(Callback);
		}
		DelayGlobalCallbacks.Empty();
	}
	//

	bIsExecuteListeners = true;
	bIsExecuteGlobalListeners = true;
	while (MessageQueue.Num()!=0)
	{
		FMessage Msg;
		DequeueMsg(Msg);
		if (Listeners.Contains(Msg.Id))
		{
			auto Delegates = Listeners[Msg.Id];
			for (auto I: Delegates.Callbacks)
			{
				I.ExecuteIfBound(Msg.Id, Msg.Args);
			}
		}

		for (auto I:GlobalListeners.Callbacks)
		{
			I.ExecuteIfBound(Msg.Id, Msg.Args);
		}
	}
	bIsExecuteGlobalListeners = false;
	bIsExecuteListeners = false;
	
	return true;
}

void UMessageCenter::EnqueueMsg(FMessage Msg)
{
	{
		FScopeLock Lock(&Mutex);
		MessageQueue2.Add(Msg);
	}
}

void UMessageCenter::DequeueMsg(FMessage& OutMsg)
{
	OutMsg = MessageQueue[0];
	MessageQueue.RemoveAt(0);
}
