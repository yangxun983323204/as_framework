class AAdvSceneCapture2D : ASceneCapture2D
{
	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		SetResolution(1024, 1024);
		this.CaptureComponent2D.PrimitiveRenderMode = ESceneCapturePrimitiveRenderMode::PRM_UseShowOnlyList;
		this.CaptureComponent2D.FOVAngle = 60;
		this.CaptureComponent2D.CaptureSource = ESceneCaptureSource::SCS_SceneColorHDR; // SceneColor(HDR) in RGB, Inv Opacity in A
	}

	void SetCaptureSource(ESceneCaptureSource SourceType)
	{
		this.CaptureComponent2D.CaptureSource = SourceType;
	}

	void SetResolution(int SizeX, int SizeY)
	{
		this.CaptureComponent2D.TextureTarget = Rendering::CreateRenderTarget2D(SizeX, SizeY);
	}

	// 获取渲染目标纹理
	UFUNCTION()
	UTextureRenderTarget2D GetRenderTarget()
	{
		return this.CaptureComponent2D.TextureTarget;
	}
};