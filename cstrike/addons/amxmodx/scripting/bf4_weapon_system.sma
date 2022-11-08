#include <amxmodx>
#include <bf4const>
#include <bf4weapons>

new Array:gWeaponList[CS_TEAMS][E_BF4_CLASS];
new gUseWeapons[BF4_WEAPONCLASS];

public plugin_init()
{
    gWeaponsList = ArrayCreate()
}

public plugin_natives()
{
	register_library("bf4_ranksystem_natives");
	register_native("BF4AddWeapons", "_native_add_weapons");
	register_native("BF4GetWeaponsCount", "_native_get_weapons_count");
	register_native("BF4GetWeaponsList", "_native_get_weapons_count");
}

public _native_add_weapons(iPlugin, iParams)
{

}

public _native_get_weapons_count(iPlugin, iParams)
{
	new id 			= get_param(1);
	new ribbon	 	= get_param(2);
	new strCaption[64];

	get_string(3, strCaption, charsmax(strCaption));

	stock_bf4_trigger_ribbon(id, ribbon, strCaption);
}