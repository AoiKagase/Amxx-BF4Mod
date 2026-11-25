#if defined _bf4_core_rules_included
#endinput
#endif
#define _bf4_core_rules_included
#include <bf4const>

stock bool:CoreClientSlot(id, maximum = 32)
{
	return id > 0 && id <= maximum;
}

stock bool:CoreIndex(index, count)
{
	return index >= 0 && index < count;
}

stock bool:CoreMenuItem(item, count)
{
	return CoreIndex(item, count);
}

stock CoreNextSession(current)
{
	return current <= 0 || current == 2147483647 ? 1 : current + 1;
}

stock bool:CoreClassValid(BF4_CLASS:value)
{
	return value == BF4_CLASS_ASSAULT || value == BF4_CLASS_RECON || value == BF4_CLASS_SUPPORT ||
		   value == BF4_CLASS_ENGINEER;
}

stock bool:CoreTeamValid(BF4_TEAM:value)
{
	return value == BF4_TEAM_RU || value == BF4_TEAM_US;
}

stock bool:CoreWeaponAllowed(BF4_CLASS:mask, BF4_TEAM:weaponTeam, BF4_CLASS:playerClass, BF4_TEAM:playerTeam)
{
	return CoreClassValid(playerClass) && CoreTeamValid(playerTeam) &&
		   (_:mask & _:playerClass) != 0 &&
		   (weaponTeam == BF4_TEAM_BOTH || weaponTeam == playerTeam);
}

stock bool:CoreCustomWeapon(cswm, csx)
{
	return cswm >= 0 && csx >= 0;
}

stock bool:CoreOwnedMenu(bool:owned, stored, callback, storedSession, currentSession)
{
	return owned && stored == callback && storedSession != 0 && storedSession == currentSession;
}

stock bool:CoreWeaponMetadata(BF4_TEAM:team, BF4_CLASS:classes, BF4_WEAPONCLASS:weaponClass, cswm, ammo, clip, reserve)
{
	return team >= BF4_TEAM_RU && team <= BF4_TEAM_BOTH &&
		   (_:classes & 15) != 0 &&
		   (_:classes & ~63) == 0 &&
		   weaponClass > BF4_WEAPONCLASS_NONE && weaponClass <= BF4_WEAPONCLASS_EXTRA && cswm >= -1 && ammo >= 0 &&
		   clip >= 0 && reserve >= 0;
}

stock bool:CoreGunDamage(attacker, inflictor, damageBits, bulletBit)
{
	return attacker == inflictor && (damageBits & bulletBit) != 0;
}

stock bool:CoreKeyEqual(const left[], const right[])
{
	new i;
	while (left[i] && right[i])
	{
		if (left[i] != right[i])
			return false;
		i++;
	}
	return left[i] == right[i];
}
