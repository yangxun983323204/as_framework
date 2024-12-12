/// 多播委托，作为参数时蓝图不可见

event void FMultiAction();
event void FMultiActionInt(int Value);
event void FMultiActionBool(bool bValue);
event void FMultiActionString(FString Value);

/// 单播委托，作为参数时蓝图可见

delegate void FAction();
delegate void FActionInt(int Value);
delegate void FActionIntInt(int Value, int Value2);
delegate void FActionBool(bool bValue);
delegate void FActionString(FString Value);
delegate void FActionBoolInt(bool bValue, int IntValue);
delegate void FActionBoolString(bool bValue, FString StrValue);
delegate void FActionBoolIntString(bool bValue, int IntValue, FString StrValue);

delegate bool FFuncRetBool();
delegate int FFuncRetInt();