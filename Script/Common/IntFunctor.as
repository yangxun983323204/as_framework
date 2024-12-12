// 可包装一个int参数的函数对象
namespace IntFunctor
{
	// 创建一个int参数的函数对象。需要防止GC。
	UIntFunctor Make(UObject Outer, int Value)
	{
		auto Functor = Cast<UIntFunctor>(NewObject(Outer, UIntFunctor::StaticClass(), NAME_None, true));
		Functor.SetValue(Value);
		return Functor;
	}
}

event void FIntFunctorCallback(int Value);

// 可包装一个int参数的函数对象
class UIntFunctor : UObject
{
	private int Value;
	FIntFunctorCallback Callback;

	void SetValue(int InValue)
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