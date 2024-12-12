// 可包装一个UObject参数的函数对象
namespace ObjFunctor
{
	// 创建一个UObject参数的函数对象。需要防止GC。
	UObjFunctor Make(UObject Outer, UObject Value)
	{
		auto Functor = Cast<UObjFunctor>(NewObject(Outer, UObjFunctor::StaticClass(), NAME_None, true));
		Functor.SetValue(Value);
		return Functor;
	}
}

event void FObjectFunctorCallback(UObject Value);

// 可包装一个UObject参数的函数对象
class UObjFunctor : UObject
{
	UPROPERTY()
	private UObject Value;
	FObjectFunctorCallback Callback;

	void SetValue(UObject InValue)
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