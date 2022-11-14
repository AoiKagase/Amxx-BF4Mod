#if defined _bf4_weapons_natives_included
    #endinput
#endif
#define _bf4_weapons_natives_included
#if AMXX_VERSION_NUM >= 175
	#pragma reqlib bf4_weapons_natives
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib bf4_weapons_natives
	#endif
#else
	#pragma library bf4_weapons_natives
#endif
#include <bf4const>

// enum BF4_WEAPON_CLASS
// {
// 	BF4_WPN_CLASS_NONE,
// 	BF4_WPN_CLASS_PISTOL,
// 	BF4_WPN_CLASS_SMG,
// 	BF4_WPN_CLASS_LMG,
// 	BF4_WPN_CLASS_SHOTGUN,
// 	BF4_WPN_CLASS_AR,
// 	BF4_WPN_CLASS_SNIPER,
// 	BF4_WPN_CLASS_DMR,
// 	BF4_WPN_CLASS_GRENADE,
// 	BF4_WPN_CLASS_KNIFE,
// 	BF4_WPN_CLASS_C4,
// 	BF4_WPN_CLASS_MAX,
// }

// enum BF4_WEAPON_HAS_CLASS(<<= 1)
// {
// 	BF4_WPN_HAS_NONE		= 0,
// 	BF4_WPN_HAS_ASSAULT		= 1,
// 	BF4_WPN_HAS_RECON,
// 	BF4_WPN_HAS_SUPPORT,
// 	BF4_WPN_HAS_ENGINEER,
// 	BF4_WPN_HAS_SELECTABLE,
// 	BF4_WPN_HAS_REQUIRE,
// }

enum _:BF4_WEAPON_DATA
{
	BF4_TEAM:TEAM,
	BF4_CLASS:HASCLASS,
	BF4_WEAPONCLASS:WPNCLASS,
	CSWM_ID,
	Ammo:AMMO_ID,
	NAME[64],
	ITEM[33],
}

native BF4RegisterWeapon(const BF4_TEAM:team, const BF4_CLASS:has_class, const BF4_WEAPONCLASS:wpn_class, const CSWM_id, const Ammo:AMMO_id, const name[33], const item[33]);
native BF4HaveThisWeapon(id, wpnindex);
native BF4SelectWeaponMenu(id);