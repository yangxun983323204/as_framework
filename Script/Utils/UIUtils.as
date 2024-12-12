namespace UIUtils_AS
{
	UFUNCTION()
	FVector2D SetImageWidthKeepAspect(UImage Image, float Width, FVector2D OverrideRawSize = FVector2D::ZeroVector)
	{
		auto RawSize = GetImageRawSize(Image, OverrideRawSize);
		auto DstSize = SetWidthKeepAspect(RawSize, Width);
		auto Brush = Image.Brush;
		Brush.ImageSize = DstSize;
		Image.Brush = Brush;
		return DstSize;
	}

	UFUNCTION()
	FVector2D SetWidthKeepAspect(FVector2D Size, float Width)
	{
		float Scale = Width / Size.X;
		float Y = Scale * Size.Y;
		return FVector2D(Width, Y);
	}

	UFUNCTION()
	FVector2D SetImageHeightKeepAspect(UImage Image, float Height, FVector2D OverrideRawSize = FVector2D::ZeroVector)
	{
		auto RawSize = GetImageRawSize(Image, OverrideRawSize);
		auto DstSize = SetHeightKeepAspect(RawSize, Height);
		auto Brush = Image.Brush;
		Brush.ImageSize = DstSize;
		Image.Brush = Brush;
		return DstSize;
	}

	void SetImageSize(UImage Image, FVector2D Size)
	{
		auto Brush = Image.Brush;
		Brush.ImageSize = Size;
		Image.Brush = Brush;
	}

	void SetCanvasPanelSlotSize(UCanvasPanelSlot Slot, FVector2D Size)
	{
		Slot.Offsets = FMargin(0,0,Size.X, Size.Y);
	}

	UFUNCTION()
	FVector2D SetHeightKeepAspect(FVector2D Size, float Height)
	{
		float Scale = Height / Size.Y;
		float X = Scale * Size.X;
		return FVector2D(X, Height);
	}

	FVector2D GetImageRawSize(UImage Image, FVector2D OverrideRawSize = FVector2D::ZeroVector)
	{
		if (OverrideRawSize != FVector2D::ZeroVector)
			return OverrideRawSize;

		auto Tex = Cast<UTexture2D>(Image.Brush.ResourceObject);
		if (Tex != nullptr)
		{
			auto X = Tex.Blueprint_GetSizeX();
			auto Y = Tex.Blueprint_GetSizeY();

			return FVector2D(X, Y);
		}
		else
		{
			return FVector2D::ZeroVector;
		}
	}

	// 最大容纳
	FVector2D ContainKeepAspect(FVector2D Container, FVector2D Size)
	{
		auto S0 = Container.X / Container.Y;
		auto S1 = Size.X / Size.Y;
		if (S0 > S1)
			return SetHeightKeepAspect(Size, Container.Y);
		else
			return SetWidthKeepAspect(Size, Container.X);
	}

	// 最小填充
	FVector2D FillKeepAspect(FVector2D Container, FVector2D Size)
	{
		auto S0 = Container.X / Container.Y;
		auto S1 = Size.X / Size.Y;
		if (S0 < S1)
			return SetHeightKeepAspect(Size, Container.Y);
		else
			return SetWidthKeepAspect(Size, Container.X);
	}
}