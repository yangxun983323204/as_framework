// bool数组
struct FBoolArray_AS
{
	TArray<bool> Values;

	bool IsEmpty()
	{
		return Values.Num() <= 0;
	}

	// 是否全部为指定值
	bool IsAll(bool InVal)
	{
		bool Is = true;
		for (auto El : Values)
		{
			if (El != InVal)
			{
				Is = false;
				break;
			}
		}

		return Is;
	}

	// 左对齐包含
	bool IsContainsLeft(FBoolArray_AS Another)
	{
		if (Values.Num() < Another.Values.Num())
		{
			return false;
		}

		bool bContains = true;
		for (int Idx = 0; Idx < Another.Values.Num(); ++Idx)
		{
			if (Values[Idx] != Another.Values[Idx])
			{
				bContains = false;
				break;
			}
		}

		return bContains;
	}

	bool Get(int Index, bool DefaultVal)
	{
		if (Values.Num() <= Index)
			return DefaultVal;
		else
			return Values[Index];
	}

	void Set(int Index, bool Value, bool FillVal = false)
	{
		int FillCount = Index + 1 - Values.Num();
		for (int I = 0; I < FillCount; ++I)
		{
			Values.Add(FillVal);
		}

		Values[Index] = Value;
	}

	// 保证数量不少于Num,不够的以FillVal填充
	void EnsureNum(int Num, bool FillVal)
	{
		int FillCount = Num - Values.Num();
		for (int I = 0; I < FillCount; ++I)
		{
			Values.Add(FillVal);
		}
	}

	bool IsEquals(FBoolArray_AS Another)
	{
		if (Values.Num() < Another.Values.Num())
		{
			return false;
		}

		bool bEqual = true;
		for (int Idx = 0; Idx < Another.Values.Num(); ++Idx)
		{
			if (Values[Idx] != Another.Values[Idx])
			{
				bEqual = false;
				break;
			}
		}

		return bEqual;
	}

	// 指定的值是否相等
	bool IsValueEquals(FBoolArray_AS Another, bool Value)
	{
		int Count = Math::Max(Values.Num(), Another.Values.Num());
		int SelfCount = Values.Num();
		int AnotherCount = Another.Values.Num();

		bool bEquals = true;
		for (int I = 0; I < Count; ++I)
		{
			bool bA = I < SelfCount ? Values[I] : !Value; // 有值取值，无值取反
			bool bB = I < AnotherCount ? Another.Values[I] : !Value;
			if (bA != bB)
			{
				bEquals = false;
				break;
			}
		}
		return bEquals;
	}

	FString ToString(FString TrueStr, FString FalseStr, FString SeparateStr)
	{
		FString S = "";
		for (auto Val : Values)
		{
			S += Val ? TrueStr : FalseStr;
			S += SeparateStr;
		}
		S.RemoveFromEnd(SeparateStr);
		return S;
	}

	// 将布尔列表中的真值转换为选项列表
	FString ToChoice(FString SeparateStr)
	{
		FString S = "";
		int Idx = 0;
		for (auto Val : Values)
		{
			if (Val)
			{
				S += UFunctionLibraryMath::ToASCII(65 + Idx);
				S += SeparateStr;
			}
			++Idx;
		}
		S.RemoveFromEnd(SeparateStr);
		return S;
	}
}