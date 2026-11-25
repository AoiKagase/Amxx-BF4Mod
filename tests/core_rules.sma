#pragma semicolon 1
native check(value, code);
#include <bf4/core_rules>
public main()
{
	check(CoreClientSlot(1) && CoreClientSlot(32) && !CoreClientSlot(0) && !CoreClientSlot(33), 1);
	check(CoreIndex(0, 1) && !CoreIndex(-1, 1) && !CoreIndex(1, 1), 2);
	check(!CoreMenuItem(-3, 4) && !CoreMenuItem(-2, 4) && !CoreMenuItem(-1, 4), 3);
	check(CoreMenuItem(0, 4) && CoreMenuItem(3, 4) && !CoreMenuItem(4, 4), 4);
	check(CoreNextSession(0) == 1 && CoreNextSession(5) == 6 && CoreNextSession(2147483647) == 1, 5);
	check(CoreOwnedMenu(true, 0, 0, 1, 1), 6); // Handle zero is valid.
	check(!CoreOwnedMenu(false, 0, 0, 1, 1) && !CoreOwnedMenu(true, 0, 0, 1, 2), 7);
	check(!CoreOwnedMenu(true, 0, 1, 1, 1) && !CoreOwnedMenu(true, 0, 0, 0, 0), 8);
	check(CoreClassValid(BF4_CLASS_ASSAULT) && CoreClassValid(BF4_CLASS_ENGINEER), 9);
	check(!CoreClassValid(BF4_CLASS_NONE) && !CoreClassValid(BF4_CLASS_ASSAULT | BF4_CLASS_RECON), 10);
	check(CoreWeaponAllowed(BF4_CLASS_ASSAULT | BF4_CLASS_RECON, BF4_TEAM_BOTH, BF4_CLASS_RECON, BF4_TEAM_RU), 11);
	check(!CoreWeaponAllowed(BF4_CLASS_ASSAULT, BF4_TEAM_BOTH, BF4_CLASS_RECON, BF4_TEAM_RU), 12);
	check(!CoreWeaponAllowed(BF4_CLASS_RECON, BF4_TEAM_US, BF4_CLASS_RECON, BF4_TEAM_RU), 13);
	check(!CoreWeaponAllowed(BF4_CLASS_ASSAULT, BF4_TEAM_BOTH, BF4_CLASS_NONE, BF4_TEAM_RU), 14);
	check(!CoreWeaponAllowed(BF4_CLASS_ASSAULT, BF4_TEAM_BOTH, BF4_CLASS_ASSAULT, BF4_TEAM_NONE), 15);
	check(CoreCustomWeapon(0, 0) && CoreCustomWeapon(4, 6) && !CoreCustomWeapon(-1, 0) && !CoreCustomWeapon(0, -1), 16);
	check(
		CoreWeaponMetadata(BF4_TEAM_BOTH, BF4_CLASS_RECON | BF4_CLASS_SELECTABLE, BF4_WEAPONCLASS_SNIPERS, 0, 0, 0, 0),
		17);
	check(!CoreWeaponMetadata(BF4_TEAM_NONE, BF4_CLASS_RECON, BF4_WEAPONCLASS_SNIPERS, 0, 0, 0, 0), 18);
	check(!CoreWeaponMetadata(BF4_TEAM_BOTH, BF4_CLASS_SELECTABLE, BF4_WEAPONCLASS_SNIPERS, 0, 0, 0, 0), 19);
	check(!CoreWeaponMetadata(BF4_TEAM_BOTH, BF4_CLASS_RECON, BF4_WEAPONCLASS_NONE, 0, 0, 0, 0), 20);
	check(!CoreWeaponMetadata(BF4_TEAM_BOTH, BF4_CLASS_RECON, BF4_WEAPONCLASS_SNIPERS, -2, 0, 0, 0), 21);
	check(!CoreWeaponMetadata(BF4_TEAM_BOTH, BF4_CLASS_RECON, BF4_WEAPONCLASS_SNIPERS, 0, -1, 0, 0), 22);
	check(!CoreWeaponMetadata(BF4_TEAM_BOTH, BF4_CLASS_RECON, BF4_WEAPONCLASS_SNIPERS, 0, 0, -1, 0), 23);
	check(CoreGunDamage(1, 1, 2, 2) && !CoreGunDamage(1, 40, 2, 2) && !CoreGunDamage(1, 1, 64, 2), 24);
	check(!CoreKeyEqual("weapon:defibrillator", "weapon:briefcase"), 25); // Both use engine ITEM knife.
	check(!CoreKeyEqual("weapon:claymore", "classic:c4"), 26); // Shared engine ITEM c4 is legal.
	check(CoreKeyEqual("weapon:claymore", "weapon:claymore"), 27);	// Duplicate stable key is rejected.
	return 27;
}
