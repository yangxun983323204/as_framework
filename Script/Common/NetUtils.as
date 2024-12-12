namespace NetUtils
{
	bool IsLocalPlayer(APawn InPawn)
	{
		if (System::IsDedicatedServer())
			return false;

		if (System::IsStandalone())
			return true;

		return InPawn.LocalRole == ENetRole::ROLE_AutonomousProxy;
	}
}