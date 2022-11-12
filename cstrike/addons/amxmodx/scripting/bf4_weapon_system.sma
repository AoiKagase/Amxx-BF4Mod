#include <amxmodx>
#include <bf4const>
#include <bf4weapons>

#define PLUGIN 	"[BF4] Weapon System"
#define VERSION "0.1"
#define AUTHOR	"Aoi.Kagase"

enum WPN_CLASS
{
	PRIMARY,
	SECONDARY,
	MELEE,
	GRENADE,
	EQUIP,
}

new Array:gWeaponList[BF4_WEAPON_TEAM][BF4_WEAPON_CLASS];
new gUseWeapons[MAX_PLAYERS + 1][WPN_CLASS];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for(new i = BF4_WPN_TEAM_NONE; i < BF4_WPN_TEAM_MAX; i++)
	{
		for(new n = BF4_WPN_CLASS_PISTOL; n < BF4_WPN_CLASS_MAX; n++)
		{
		    gWeaponList[i][n] = ArrayCreate();
		}
	}
}

public plugin_natives()
{
	register_library("bf4_weapons_natives");
	register_native("BF4RegisterWeapons", "_native_register_weapons");
	register_native("BF4GetWeaponsCount", "_native_get_weapons_count");
	register_native("BF4GetWeaponsList", "_native_get_weapons_count");
}

public _native_register_weapons(iPlugin, iParams)
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