
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

#define PLUGIN 				"[BF4] Pickup Weapons"
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

public plugin_init()
{
	register_plugin		(PLUGIN, VERSION, AUTHOR, "github.com/AoiKagase", "BF4 Ribbon");
	create_cvar			(PLUGIN, VERSION, FCVAR_SERVER|FCVAR_SPONLY);

 	RegisterHam			(Ham_Touch,			"weaponbox",			"BF4TouchWeaponBox", 0);
}


// new const m_rgAmmo = 73;
public BF4TouchWeaponBox(iWpnBox, iToucher)
{
	if (is_user_alive(iToucher))
	{
		new iPWeapon = cs_get_weapon_id(cs_get_user_weapon_entity(iToucher));
		new iDWeapon = cs_get_weapon_id(GetWeaponBoxWeaponType(iWpnBox));

		if (iPWeapon == iDWeapon)
		{
//			new ammo = get_member(iBoxWeapon, m_Weapon_iClip);
			new ammo = GetAmmoBox(iWpnBox);
			if (ammo)
			{
				// ExecuteHam(Ham_GiveAmmo, this, amount, "type", max);
				ExecuteHamB(Ham_GiveAmmo, iToucher, ammo, g_szAmmoNames[CSW_AMMO_ID[iDWeapon][AmmoId]], CSW_AMMO_ID[iDWeapon][MaxAmmo]);
				emit_sound(iToucher, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				new flags;
				pev(iWpnBox, pev_flags, flags);
				set_pev(iWpnBox, pev_flags, flags | FL_KILLME);
			}
		}
	}
}

GetWeaponBoxWeaponType(iEnt) 
{ 
    for(new i, iWeapon; i < MAX_ITEM_TYPES; i++)
    {
        iWeapon = get_member(iEnt, m_WeaponBox_rgpPlayerItems, i);
        if(!is_nullent(iWeapon))
            return iWeapon;
    }
    return NULLENT;
} 

GetAmmoBox(iEnt)
{
    for(new i, iAmmo; i < MAX_ITEM_TYPES; i++)
    {
        iAmmo = get_member(iEnt, m_WeaponBox_rgAmmo, i);
        if(!is_nullent(iAmmo))
            return iAmmo;
    }
    return NULLENT;
}