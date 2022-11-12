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

enum _:BF4_WEAPON_CLASS
{
	BF4_WPN_CLASS_PISTOL,
	BF4_WPN_CLASS_SMG,
	BF4_WPN_CLASS_LMG,
	BF4_WPN_CLASS_AR,
	BF4_WPN_CLASS_SNIPER,
	BF4_WPN_CLASS_EQUIP,
	BF4_WPN_CLASS_MAX,
}

enum _:BF4_WEAPON_TEAM
{
	BF4_WPN_TEAM_NONE,
	BF4_WPN_TEAM_US,
	BF4_WPN_TEAM_RU,
	BF4_WPN_TEAM_BOTH,
	BF4_WPN_TEAM_MAX,
}

native BF4RegisterWeapons(BF4_WEAPON_TEAM:team, BF4_WEAPON_CLASS:class, weapon);