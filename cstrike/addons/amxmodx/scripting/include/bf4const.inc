#if defined _bf4_const_included
    #endinput
#endif

#define _bf4_const_included

#include <cstrike>

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

enum _:E_AMMO_IDS
{
	ammo_none,
	ammo_338magnum = 1,
	ammo_762nato,
	ammo_556natobox,
	ammo_556nato,
	ammo_buckshot,
	ammo_45acp,
	ammo_57mm,
	ammo_50ae,
	ammo_357sig,
	ammo_9mm
};
// AMMOID, MAXBPAMMO
new const CSW_AMMO_ID[CSW_P90 + 1][2] =
{
	{ -1, -1},			// CSW_NONE
	{  9, 52},			// CSW_P228
	{ -1, -1},			// CSW_GLOCK Unused by game, See CSW_GLOCK18.
	{  2, 90},			// CSW_SCOUT
	{ 12,  1},			// CSW_HEGRENADE
	{  5, 32},			// CSW_XM1014
	{ 14,  1},			// CSW_C4
	{  6,100},			// CSW_MAC10
	{  4, 90},			// CSW_AUG
	{ 13,  1},			// CSW_SMOKEGRENADE
	{ 10,120},			// CSW_ELITE
	{  7,100}, 			// CSW_FIVESEVEN
	{  6,100}, 			// CSW_UMP45
	{  4, 90}, 			// CSW_SG550
	{  4, 90}, 			// CSW_GALIL
	{  4, 90}, 			// CSW_FAMAS
	{  6,100}, 			// CSW_USP
	{ 10,120}, 			// CSW_GLOCK18
	{  1, 30}, 			// CSW_AWP
	{ 10,120}, 			// CSW_MP5NAVY
	{  3,200}, 			// CSW_M249
	{  5, 32}, 			// CSW_M3
	{  4, 90}, 			// CSW_M4A1
	{ 10,120}, 			// CSW_TMP
	{  2, 90}, 			// CSW_G3SG1
	{ 11,  2}, 			// CSW_FLASHBANG
	{  8, 35}, 			// CSW_DEAGLE
	{  4, 90}, 			// CSW_SG552
	{  2, 90}, 			// CSW_AK47
	{ -1, -1}, 			// CSW_KNIFE
	{  7,100} 			// CSW_P90
};


new const g_szAmmoNames[E_AMMO_IDS][] = {
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
	"9mm"
};

