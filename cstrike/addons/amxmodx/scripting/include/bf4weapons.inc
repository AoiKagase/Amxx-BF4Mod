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

#define USP_MAX_SPEED 				250.0
#define USP_DAMAGE 					34.0
#define USP_DAMAGE_SIL 				30.0
#define USP_RANGE_MODIFER 			0.79

#define MP5N_MAX_SPEED				250.0
#define MP5N_DAMAGE					26.0
#define MP5N_RANGE_MODIFER			0.84
#define MP5N_ACCURACY_DIVISOR		220.1

#define SG552_MAX_SPEED				235.0
#define SG552_MAX_SPEED_ZOOM		200.0
#define SG552_DAMAGE				33.0
#define SG552_RANGE_MODIFER			0.955
#define SG552_ACCURACY_DEVISOR		220.0

#define AK47_MAX_SPEED				221.0
#define AK47_DAMAGE					36.0
#define AK47_RANGE_MODIFIER			0.98
#define AK47_ACCURACY_DIVISOR		200.0

#define AUG_MAX_SPEED				240.0
#define AUG_DAMAGE					32.0
#define AUG_RANGE_MODIFER			0.96
#define AUG_ACCURACY_DIVISOR 		215.0

#define AWP_MAX_SPEED				210.0
#define AWP_MAX_SPEED_ZOOM			150.0
#define AWP_DAMAGE					115.0
#define AWP_RANGE_MODIFER			0.99

#define C4_MAX_SPEED				250.0
#define C4_ARMING_ON_TIME			3.0

#define DEAGLE_MAX_SPEED			250.0
#define DEAGLE_DAMAGE				54.0
#define DEAGLE_RANGE_MODIFER		0.81

#define FLASHBANG_MAX_SPEED			250.0
#define FLASHBANG_MAX_SPEED_SHIELD	180.0

#define G3SG1_MAX_SPEED				210.0
#define G3SG1_MAX_SPEED_ZOOM		150.0
#define G3SG1_DAMAGE				80.0
#define G3SG1_RANGE_MODIFER			0.98

#define GLOCK18_MAX_SPEED			250.0
#define GLOCK18_DAMAGE				25.0
#define GLOCK18_RANGE_MODIFER		0.75

#define HEGRENADE_MAX_SPEED			250.0
#define HEGRENADE_MAX_SPEED_SHIELD	180.0

#define KNIFE_BODYHIT_VOLUME		128.0
#define KNIFE_WALLHIT_VOLUME		512.0
#define KNIFE_MAX_SPEED				250.0
#define KNIFE_MAX_SPEED_SHIELD		180.0
#define KNIFE_STAB_DAMAGE			65.0
#define KNIFE_SWING_DAMAGE			15.0
#define KNIFE_SWING_DAMAGE_FAST		20.0
#define KNIFE_STAB_DISTANCE			32.0
#define KNIFE_SWING_DISTANCE		48.0

#define M249_MAX_SPEED				220.0
#define M249_DAMAGE					32.0
#define M249_RANGE_MODIFER			0.97
#define M249_ACCURACY_DIVISOR 		175.0

#define M3_MAX_SPEED				230.0
#define M3_DAMAGE					20.0

#define M4A1_MAX_SPEED				230.0
#define M4A1_DAMAGE					32.0
#define M4A1_DAMAGE_SIL				33.0
#define M4A1_RANGE_MODIFER			0.97
#define M4A1_RANGE_MODIFER_SIL		0.95
#define M4A1_ACCURACY_DIVISOR		220.0

#define MAC10_MAX_SPEED				250.0
#define MAC10_DAMAGE				29.0
#define MAC10_RANGE_MODIFER			0.82
#define MAC10_ACCURACY_DIVISOR		200.0

#define P228_MAX_SPEED				250.0
#define P228_DAMAGE					32.0
#define P228_RANGE_MODIFER			0.8

#define P90_MAX_SPEED				245.0
#define P90_DAMAGE					21.0
#define P90_RANGE_MODIFER			0.885
#define P90_ACCURACY_DIVISOR		175.0

#define SCOUT_MAX_SPEED				260.0
#define SCOUT_MAX_SPEED_ZOOM 		220.0
#define SCOUT_DAMAGE				75.0
#define SCOUT_RANGE_MODIFER			0.98

#define SGRENADE_MAX_SPEED			250.0
#define SGRENADE_MAX_SPEED_SHIELD	180.0

#define TMP_MAX_SPEED				250.0
#define TMP_DAMAGE					20.0
#define TMP_RANGE_MODIFER			0.85
#define TMP_ACCURACY_DIVISOR		200.0

#define XM1014_MAX_SPEED			240.0
#define XM1014_DAMAGE				20.0

#define ELITE_MAX_SPEED				250.0
#define ELITE_DAMAGE				36.0
#define ELITE_RANGE_MODIFER			0.75

#define FIVESEVEN_MAX_SPEED			250.0
#define FIVESEVEN_DAMAGE			20.0
#define FIVESEVEN_RANGE_MODIFER		0.885

#define UMP45_MAX_SPEED				250.0
#define UMP45_DAMAGE				30.0
#define UMP45_RANGE_MODIFER			0.82
#define UMP45_RELOAD_TIME			3.5
#define UMP45_ACCURACY_DIVISOR		210.0

#define SG550_MAX_SPEED				210.0
#define SG550_MAX_SPEED_ZOOM		150.0
#define SG550_DAMAGE				70.0
#define SG550_RANGE_MODIFER			0.98

#define GALIL_MAX_SPEED				240.0
#define GALIL_DAMAGE				30.0
#define GALIL_RANGE_MODIFER			0.98
#define GALIL_RELOAD_TIME			2.45
#define GALIL_ACCURACY_DIVISOR		200.0

#define FAMAS_MAX_SPEED				240.0
#define FAMAS_RELOAD_TIME			3.3
#define FAMAS_DAMAGE				30.0
#define FAMAS_DAMAGE_BURST			34.0
#define FAMAS_RANGE_MODIFER			0.96
#define FAMAS_ACCURACY_DIVISOR		215.0

native BF4RegisterWeapon	(const BF4_TEAM:team, const BF4_CLASS:has_class, const BF4_WEAPONCLASS:wpn_class, const CSWM_id, const name[33], const item[33], const AMMO_id, const ammoname[33] );
native BF4HaveThisWeapon	(const id, const wpnindex);
native BF4SelectWeaponMenu	(const id);
native BF4_WEAPONCLASS:BF4WeaponNameToClass(const id, const weaponname[]);
