event void DragOverEvent(FGeometry MyGeometry, FPointerEvent PointerEvent, UDragDropOperation Operation);

// 可拖拽的组件
class UHCDragableWidget_AS : UUserWidget
{
	UPROPERTY()
	DragOverEvent OnDragOverEvent;

	UFUNCTION(BlueprintOverride)
	FEventReply OnMouseButtonDown(FGeometry MyGeometry, FPointerEvent MouseEvent)
	{
		return Widget::DetectDragIfPressed(MouseEvent, this, EKeys::LeftMouseButton);
	}

	UFUNCTION(BlueprintOverride)
	void OnDragDetected(FGeometry MyGeometry, FPointerEvent PointerEvent, UDragDropOperation& Operation)
	{
		auto DragDrop = Cast<UDragDropOperation>(NewObject(nullptr, UDragDropOperation::StaticClass()));
		Operation = DragDrop;
		Operation.Payload = this;
		// Operation.DefaultDragVisual = this;
	}

	UFUNCTION(BlueprintOverride)
	bool OnDragOver(FGeometry MyGeometry, FPointerEvent PointerEvent, UDragDropOperation Operation)
	{
		if (OnDragOverEvent.IsBound())
		{
			OnDragOverEvent.Broadcast(MyGeometry, PointerEvent, Operation);
			return true;
		}

		return false;
	}
};