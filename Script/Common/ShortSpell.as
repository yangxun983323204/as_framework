// 常用函数短拼写
namespace S
{
	// FText::FromString
	FText TFS(FString Str)
	{
		return FText::FromString(Str);
	}

	// FText::FromName
	FText TFN(FName Name)
	{
		return FText::FromName(Name);
	}

	// Name from FString
	FName NFS(FString Str)
	{
		return FName(Str);
	}

	// Gameplay::GetPlayerController
	APlayerController GGPC(int Index)
	{
		return Gameplay::GetPlayerController(Index);
	}

	// WidgetBlueprint::CreateWidget
	UUserWidget WBCW(TSubclassOf<UUserWidget> Type, APlayerController OwnPlayer)
	{
		return WidgetBlueprint::CreateWidget(Type, OwnPlayer);
	}
}