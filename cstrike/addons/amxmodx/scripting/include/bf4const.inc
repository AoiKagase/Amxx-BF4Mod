#if defined _bf4_const_included
    #endinput
#endif

#define _bf4_const_included

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
