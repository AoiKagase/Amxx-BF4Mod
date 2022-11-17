
//
//=====================================
//  INCLUDE AREA
//=====================================
#pragma compress	1
#pragma tabsize		4

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <reapi>
#include <hamsandwich>
#include <bf4const>
#include <cswm>

#pragma semicolon	1

#define PLUGIN 				"[BF4] Pickup Ammo"
#define VERSION 			"0.01"
#define AUTHOR				"Aoi.Kagase"

new const g_szAmmoNames[Ammo][] = {
	"",
	"338magnum",
	"762nato",
	"556natobox",
	"556nato",
	"buckshot",
	"45acp",
	"57mm",
	"50ae",
	"357sig",
	"9mm",
	"hegrenade",
	"flashbang",
	"smokegrenade",
	"c4",
};

enum CSW_AMMO
{
	Ammo:AmmoId,
	MaxAmmo,
}

// AMMOID, MAXBPAMMO
new const CSW_AMMO_ID[CSW_P90 + 1][CSW_AMMO] =
{
	{ Ammo_None, 			0},			// CSW_NONE
	{ Ammo_357SIG, 			52},		// CSW_P228
	{ Ammo_None, 			0},			// CSW_GLOCK Unused by game, See CSW_GLOCK18.
	{ Ammo_762Nato, 		90},		// CSW_SCOUT
	{ Ammo_HEGRENADE,  		1},			// CSW_HEGRENADE
	{ Ammo_12Gauge, 		32},		// CSW_XM1014
	{ Ammo_C4,  			1},			// CSW_C4
	{ Ammo_45ACP,			100},		// CSW_MAC10
	{ Ammo_556Nato, 		90},		// CSW_AUG
	{ Ammo_SMOKEGRENADE,	1},			// CSW_SMOKEGRENADE
	{ Ammo_9MM,				120},		// CSW_ELITE
	{ Ammo_57MM,			100}, 		// CSW_FIVESEVEN
	{ Ammo_45ACP,			100}, 		// CSW_UMP45
	{ Ammo_556Nato, 		90}, 		// CSW_SG550
	{ Ammo_556Nato, 		90}, 		// CSW_GALIL
	{ Ammo_556Nato, 		90}, 		// CSW_FAMAS
	{ Ammo_45ACP,			100}, 		// CSW_USP
	{ Ammo_9MM,				120}, 		// CSW_GLOCK18
	{ Ammo_338Magnum, 		30}, 		// CSW_AWP
	{ Ammo_9MM,				120}, 		// CSW_MP5NAVY
	{ Ammo_556NatoBox,		200}, 		// CSW_M249
	{ Ammo_12Gauge, 		32}, 		// CSW_M3
	{ Ammo_556Nato, 		90}, 		// CSW_M4A1
	{ Ammo_9MM,				120}, 		// CSW_TMP
	{ Ammo_762Nato, 		90}, 		// CSW_G3SG1
	{ Ammo_FLASHBANG,  		2}, 		// CSW_FLASHBANG
	{ Ammo_50AE, 			35}, 		// CSW_DEAGLE
	{ Ammo_556Nato, 		90}, 		// CSW_SG552
	{ Ammo_762Nato, 		90}, 		// CSW_AK47
	{ Ammo_None, 			0}, 		// CSW_KNIFE
	{ Ammo_57MM,			100} 		// CSW_P90
};

public plugin_init()
{
	register_plugin		(PLUGIN, VERSION, AUTHOR, "github.com/AoiKagase", "BF4 Pickup Ammo");
	create_cvar			(PLUGIN, VERSION, FCVAR_SERVER|FCVAR_SPONLY);

 	RegisterHam			(Ham_Touch,	"weaponbox", "BF4TouchWeaponBox", 0);
}


// new const m_rgAmmo = 73;
public BF4TouchWeaponBox(iWpnBox, iToucher)
{
	if (is_user_alive(iToucher))
	{
		new iPWeapon = cs_get_user_weapon_entity(iToucher);
		// new iDWeapon = cs_get_weapon_id(GetWeaponBoxWeaponType(iWpnBox));
		new bWeaponId;
		new bAmmoName[33], pAmmoName[33];
		new bAmmo, pAmmo;
		GetWeaponBoxInfo(iWpnBox, bWeaponId, bAmmo, bAmmoName, charsmax(bAmmoName));
		GePlayerWeaponInfo(iPWeapon, pAmmo, pAmmoName, charsmax(pAmmoName));

		if (equali(bAmmoName, pAmmoName))
		{
//			new ammo = get_member(iBoxWeapon, m_Weapon_iClip);
			// new ammo = GetAmmoBox(iWpnBox);
			if (bAmmo)
			{
				// ExecuteHam(Ham_GiveAmmo, this, amount, "type", max);
				ExecuteHamB(Ham_GiveAmmo, iToucher, bAmmo, bAmmoName, pAmmo);
				emit_sound(iToucher, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				new flags;
				pev(iWpnBox, pev_flags, flags);
				set_pev(iWpnBox, pev_flags, flags | FL_KILLME);
			}
		}
	}
}

GetWeaponBoxInfo(iEnt, &iWeapon, &irgAmmo, iszAmmo[], length) 
{ 
    for(new i = 0; i < MAX_ITEM_TYPES; i++)
    {
        iWeapon = get_member(iEnt, m_WeaponBox_rgpPlayerItems, i);
        irgAmmo = get_member(iEnt, m_WeaponBox_rgAmmo, i);
		get_member(iEnt, m_WeaponBox_rgiszAmmo, iszAmmo, length, i);
    }
    return;
} 

GePlayerWeaponInfo(iEnt, &iMaxAmmo, szAmmo[], length)
{
	rg_get_iteminfo(iEnt, ItemInfo_pszAmmo1, szAmmo, length);
	iMaxAmmo = rg_get_iteminfo(iEnt, ItemInfo_iMaxAmmo1);
}