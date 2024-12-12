// 投票
struct FVote
{
	private TMap<FString, bool> Map;

	void Vote(FString Name, bool bVal)
	{
		Map.FindOrAdd(Name) = bVal;
	}

	bool GetVote(FString Name, bool Default)
	{
		bool Val;
		if (!Map.Find(Name, Val))
		{
			Val = Default;
		}
		
		return Val;
	}

	bool IsAllTrue()
	{
		for (auto KV : Map)
		{
			if (KV.Value == false)
				return false;
		}

		return true;
	}

	bool IsAllFalse()
	{
		for (auto KV : Map)
		{
			if (KV.Value == true)
				return false;
		}

		return true;
	}

	bool HasTrue()
	{
		for (auto KV : Map)
		{
			if (KV.Value == true)
				return true;
		}

		return false;
	}

	bool HasFalse()
	{
		for (auto KV : Map)
		{
			if (KV.Value == false)
				return true;
		}

		return false;
	}

	void Clear()
	{
		Map.Empty();
	}
};