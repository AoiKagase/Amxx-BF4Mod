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

native BF4RegisterWeapon	(const BF4_TEAM:team, const BF4_CLASS:has_class, const BF4_WEAPONCLASS:wpn_class, const CSWM_id, const name[33], const item[33], const AMMO_id, const ammoname[33] );
native BF4HaveThisWeapon	(const id, const wpnindex);
native BF4SelectWeaponMenu	(const id);
native BF4_WEAPONCLASS:BF4WeaponNameToClass(const id, const weaponname[]);
