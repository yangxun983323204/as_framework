event void FCheckBoxCheckedEvent(int Index, UCheckBox Item);

enum ECheckBoxGroupNotifyMode
{
	None,
	Normal,
	Force,
}

class UHCCheckBoxGroup_AS : UObject
{
	// 某个钩选框被选中的事件
	FCheckBoxCheckedEvent CheckedEvent;

	UPROPERTY()
	private TArray<UCheckBox> Items;
	UPROPERTY()
	private TMap<UCheckBox, UBool2ObjFunctor> Functors;
	UPROPERTY()
	private bool bAllowNoChecked = false;

	UFUNCTION()
	void Add(UCheckBox Item)
	{
		bool bAdd = Items.AddUnique(Item);
		if (bAdd)
		{
			auto Functor = Bool2ObjFunctor::Make(nullptr, Item);
			Functor.Callback.AddUFunction(this, n"OnItemStateChanged");
			Item.OnCheckStateChanged.AddUFunction(Functor, Functor.Func());
			Functors.Add(Item, Functor);
		}
		EnsureCheckState(-1);
	}

	UFUNCTION()
	void Remove(UCheckBox Item)
	{
		if (Items.Contains(Item))
		{
			auto Functor = Functors[Item];
			Item.OnCheckStateChanged.Unbind(Functor, Functor.Func());
			Items.Remove(Item);
			Functors.Remove(Item);
		}
		EnsureCheckState(-1);
	}

	UFUNCTION()
	void Clear()
	{
		Items.Empty();
	}

	// 确保选中一项
	UFUNCTION()
	void EnsureCheckState(int ForceSelectIndex = -1)
	{
		if (Items.Num() <= 0)
			return;

		bool bNeedForce = ForceSelectIndex >= 0 && ForceSelectIndex < Items.Num();
		if (bNeedForce)
		{
			SetItemState(Items[ForceSelectIndex], true, ECheckBoxGroupNotifyMode::Normal);
		}
		else
		{
			int CheckedIdx = -1;
			for (int I = 0; I < Items.Num(); ++I)
			{
				if (CheckedIdx != -1)
				{
					SetItemState(Items[I], false, ECheckBoxGroupNotifyMode::None);
				}
				else if (Items[I].IsChecked())
					CheckedIdx = I;
			}

			if (CheckedIdx == -1)
				SetItemState(Items[0], true, ECheckBoxGroupNotifyMode::Normal);
		}
	}

	UFUNCTION()
	void ForceSelect(int Index)
	{
		if (Items.Num() <= 0)
			return;
		
		SetItemState(Items[Index], true, ECheckBoxGroupNotifyMode::Force);
	}

	UFUNCTION()
	private void OnItemStateChanged(UObject InItem)
	{
		auto TargetItem = Cast<UCheckBox>(InItem);
		if (!TargetItem.IsChecked())
		{
			HandleItemUnChecked(TargetItem);
		}
		else
		{
			HandleItemChecked(TargetItem);
		}
	}

	private void HandleItemUnChecked(UCheckBox Item)
	{
		bool bHasOtherSelect = false;
		for (int I = 0; I < Items.Num(); ++I)
		{
			auto El = Items[I];
			if (El.IsChecked())
			{
				bHasOtherSelect = true;
				break;
			}
		}
		if (!bHasOtherSelect && !bAllowNoChecked)
		{
			// 如果此项是唯一一个之前的选中项，不允许它取消
			Item.SetIsChecked(true);
		}
	}

	private void HandleItemChecked(UCheckBox Item)
	{
		for (int I = 0; I < Items.Num(); ++I)
		{
			auto El = Items[I];
			if (El.IsChecked() && El != Item)
			{
				SetItemState(El, false, ECheckBoxGroupNotifyMode::Normal);
			}
		}

		int Idx = Items.FindIndex(Item);
		CheckedEvent.Broadcast(Idx, Item);
	}

	private void SetItemState(UCheckBox Item, bool bChecked, ECheckBoxGroupNotifyMode NotifyMode)
	{
		bool bOld = Item.IsChecked();
		if (bOld == bChecked && !(NotifyMode == ECheckBoxGroupNotifyMode::Force))
			return;

		Item.SetIsChecked(bChecked);
		if (NotifyMode != ECheckBoxGroupNotifyMode::None)
			Item.OnCheckStateChanged.Broadcast(bChecked);
	}
};