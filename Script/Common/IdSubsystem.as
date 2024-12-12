class UIdSubsystem : UScriptGameInstanceSubsystem
{
	private int GenIntIdIdx = 0;
	private int64 GenLongIdIdx = 0;

	int GenIntId()
	{
		auto Val = GenIntIdIdx;
		++GenIntIdIdx;
		return Val;
	}

    int64 GenLongId()
	{
		auto Val = GenLongIdIdx;
		++GenLongIdIdx;
		return Val;
	}
};