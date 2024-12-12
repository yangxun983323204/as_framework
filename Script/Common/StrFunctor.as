// 可包装一个FString参数的函数对象
namespace StrFunctor
{
	// 创建一个int参数的函数对象。需要防止GC。
	UStrFunctor Make(UObject Outer, FString Value)
	{
		auto Functor = Cast<UStrFunctor>(NewObject(Outer, UStrFunctor::StaticClass(), NAME_None, true));
		Functor.SetValue(Value);
		return Functor;
	}
}

event void FStrFunctorCallback(FString Value);

// 可包装一个FString参数的函数对象
class UStrFunctor : UObject
{
	private FString Value;
	FStrFunctorCallback Callback;

	void SetValue(FString InValue)
	{
		Value = InValue;
	}

	// 要绑定的方法名称
	UFUNCTION(BlueprintPure)
	FName Func()
	{
		return n"Proxy";
	}

	// 转发
	UFUNCTION()
	private void Proxy()
	{
		Callback.Broadcast(Value);
	}
};