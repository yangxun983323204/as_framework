delegate void FTimerForTicksDelegate();

// 可等待指定帧的定时器
namespace TimerForTicks
{
	UTimerForTicks Make(UObject Outer, uint WaitTicks)
	{
		auto Inst = Cast<UTimerForTicks>(NewObject(Outer, UTimerForTicks::StaticClass()));
		Inst.Set(WaitTicks);
		Inst.AddToRoot();
		return Inst;
	}
}

// 可等待指定帧的定时器
class UTimerForTicks : UObject
{
	FTimerForTicksDelegate Callback;
	private uint WaitTicks;
	private uint CurrTicks = 0;

	void Set(int InWaitTicks)
	{
		WaitTicks = InWaitTicks;
        CurrTicks = 0;
		System::SetTimerForNextTick(this, "TimerTick");
	}

	UFUNCTION()
	void TimerTick()
	{
		++CurrTicks;
		if (CurrTicks < WaitTicks)
			System::SetTimerForNextTick(this, "TimerTick");
		else
		{
			Callback.ExecuteIfBound();
            this.RemoveFromRoot();
		}
	}
};