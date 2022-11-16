#if defined _bf4_const_included
    #endinput
#endif

#define _bf4_const_included

#include <cstrike>
#include <cswm_const>

enum _:E_BF4_RANK
{
	BF4_RNK_MARKSMAN 	= 0,
	BF4_RNK_HEADSHOT,
	BF4_RNK_PISTOL	,
	BF4_RNK_ASSAULT ,
	// BF4_RNK_CARBIN	, // M4A1 only...
	BF4_RNK_SNIPER	,
	BF4_RNK_LMG		,
	BF4_RNK_DMR		,
	// BF4_RNK_PDW 	, // P90 only...
	BF4_RNK_SMG		, // PDW Alternative
	BF4_RNK_SHOTGUN	,
	BF4_RNK_MELEE	,
	BF4_RNK_ASSIST	,
	BF4_RNK_AVENGER	,
	BF4_RNK_SAVIOR	,
	BF4_RNK_MVP		,
	BF4_RNK_MEDIKIT	,
	BF4_RNK_AMMOBOX	,
	BF4_RNK_REVIVE	, 
	BF4_RNK_CTF_CAP	,
	BF4_RNK_CTF_WIN	,
	BF4_RNK_MAX
};

enum BF4_CLASS (<<= 1)
{
	BF4_CLASS_NONE		= 0,
	BF4_CLASS_ASSAULT	= 1,
	BF4_CLASS_RECON,
	BF4_CLASS_SUPPORT,
	BF4_CLASS_ENGINEER,
	// NOT SELECT
	BF4_CLASS_SELECTABLE,
	BF4_CLASS_REQUIRE,
}

enum BF4_WEAPONCLASS
{
	BF4_WEAPONCLASS_NONE,
	BF4_WEAPONCLASS_PISTOLS,
	BF4_WEAPONCLASS_ASSAULTS,
//	BF4_WEAPONCLASS_CARBINS,
	BF4_WEAPONCLASS_SNIPERS,
//	BF4_WEAPONCLASS_PDWS,
	BF4_WEAPONCLASS_LMGS,	
	BF4_WEAPONCLASS_DMRS,
	BF4_WEAPONCLASS_SMGS,
	BF4_WEAPONCLASS_SHOTGUNS,
	BF4_WEAPONCLASS_MELEE,
	BF4_WEAPONCLASS_GRENADE,
	BF4_WEAPONCLASS_EQUIP,
	BF4_WEAPONCLASS_EXTRA,
};

enum BF4_TEAM
{
	BF4_TEAM_NONE,
	BF4_TEAM_RU,
	BF4_TEAM_US,
	BF4_TEAM_BOTH,
	BF4_TEAM_MAX,
}

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


