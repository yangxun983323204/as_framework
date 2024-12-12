// 可接受一个bool参数并可包装一个UObject参数的函数对象
namespace Bool2ObjFunctor
{
	// 创建一个可接受一个bool参数并可包装一个UObject参数的函数对象。需要防止GC。
	UBool2ObjFunctor Make(UObject Outer, UObject Value)
	{
		auto Functor = Cast<UBool2ObjFunctor>(NewObject(Outer, UBool2ObjFunctor::StaticClass(), NAME_None, true));
		Functor.SetValue(Value);
		return Functor;
	}
}

event void FBool2ObjFunctorCallback(UObject Value);

// 可接受一个bool参数并可包装一个UObject参数的函数对象
class UBool2ObjFunctor : UObject
{
	UPROPERTY()
	private UObject Value;
	FBool2ObjFunctorCallback Callback;

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
	private void Proxy(bool bVal)
	{
		Callback.Broadcast(Value);
	}
};