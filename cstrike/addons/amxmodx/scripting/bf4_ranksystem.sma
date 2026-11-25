//
// Standalone BF4 progression; historical addon gameplay by Aoi.Kagase.
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

#include <sqlx>
#include <nvault>
#include <reapi>
#include <bf4objectives>
#include <bf4const>
#include <bf4natives>
#include <bf4weapons>
#include <bf4classes>
#include <cswm>

#define UnitsToMeters(%1)	(%1*0.0254)
#define BF4_VAULT			"BF4Ranks"
#define	MAX_LENGTH			128
#define MAX_ERR_LENGTH		512
#define MAX_QUERY_LENGTH	2048
#define PLUGIN "BF4 Standalone Rank System"
#define VERSION "2.0.0"
#define AUTHOR				"Aoi.Kagase"
enum _:E_BF4_RANK_CVARS
{
	E_CV_REWARD,
	E_CV_HEALTHKIT_COST,
	E_CV_HEALTHKIT_AMOUNT,
	E_CV_AMMOBOX_COST,
	E_CV_AMMOBOX_AMOUNT,
	Float:E_CV_HEALTHKIT_INTERVAL,
	Float:E_CV_AMMOBOX_INTERVAL,
};

enum _:E_BF4_TYPE
{
	TYPE_RIBBON = 0,
	TYPE_MEDAL,
	TYPE_MAX
};

enum _:AwardDefinitionData
{
	AWARD_TYPE,
	AWARD_ID,
	AWARD_DISPLAY_NAME[32],
	AWARD_SPRITE_NAME[32],
	AWARD_REQUIRED_COUNT,
	AWARD_XP_REWARD,
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
	E_HEALTH_KIT = 0,
	E_AMMO_BOX,
	E_REVIVAL_KIT,
};

enum _:E_SAVIOR
{
	Float:SV_TIME,
	SV_TARGET,
};

#define ITEM_OWNER pev_iuser1
#define ITEM_TEAM  pev_iuser2

// new const ENT_MODELS[E_BF4_OBJECT_MENU][] =
// {
// 	"models/bf4_ranks/medkit.mdl",
// 	"models/bf4_ranks/ammobox.mdl",
// 	"",
// };

// new const ENT_CLASS[E_BF4_OBJECT_MENU][]=
// {
// 	"bf4_healthkit",
// 	"bf4_ammobox",
// 	"",
// };

new const TASK_AWARD = 1122100;
new const TASK_HUD_SPR = 1122200;
new const TASK_ROUND_READY = 1122300;
new const TASK_SPAWN = 1122400;

new const g_awardEventXP[E_BF4_RANK] = {
	25,	 // MARKSMAN
	25,	 // HEADSHOT
	0,	 // HANDGUN,
	0,	 // ASSAULT RIFLE
	0,	 // SNIPER RIFLE
	0,	 // LMG
	0,	 // DMR
	0,	 // SMG
	0,	 // SHOTGUN
	0,	 // MELEE
	0,	 // KILL ASSIST (0 - 100)
	25,	 // AVENGER
	25,	 // SAVIOR
	0,	 // MVP
	15,	 // MEDIKIT
	15,	 // AMMO SUPLY
	70,	 // Revive
	400, // CTF Capture
	0,	 // CTF Win
	0,
};

new const g_ribbonDefinitions[E_BF4_RANK][AwardDefinitionData] = {
	{TYPE_RIBBON, BF4_RNK_MARKSMAN, "MARKSMAN RIBBON", "rbn_marksman", 1, 200},
	{TYPE_RIBBON, BF4_RNK_HEADSHOT, "HEADSHOT RIBBON", "rbn_headshot", 3, 200},
	{TYPE_RIBBON, BF4_RNK_PISTOL, "HANDGUN RIBBON", "rbn_handgun", 4, 200},
	{TYPE_RIBBON, BF4_RNK_ASSAULT, "ASSAULT RIFLE RIBBON", "rbn_assault", 6, 200},
	// {TYPE_RIBBON, BF4_RNK_RBN_CARBIN, "CARBIN RIBBON", 		"rbn_carbin",	6,	200},
	{TYPE_RIBBON, BF4_RNK_SNIPER, "SNIPER RIFLE RIBBON", "rbn_sniper", 6, 200},
	{TYPE_RIBBON, BF4_RNK_LMG, "LMG RIBBON", "rbn_lmg", 6, 200},
	{TYPE_RIBBON, BF4_RNK_DMR, "DMR RIBBON", "rbn_dmr", 6, 200},
	// {TYPE_RIBBON, BF4_RBN_PDW, 	"PDW RIBBON", 			"rbn_pdw",		6,	200},
	{TYPE_RIBBON, BF4_RNK_SMG, "SMG RIBBON", "rbn_pdw", 6, 200},
	{TYPE_RIBBON, BF4_RNK_SHOTGUN, "SHOTGUN RIBBON", "rbn_shotgun", 6, 200},
	{TYPE_RIBBON, BF4_RNK_MELEE, "MELEE RIBBON", "rbn_melee", 4, 200},
	{TYPE_RIBBON, BF4_RNK_ASSIST, "KILL ASSIST RIBBON", "rbn_assist", 5, 200},
	{TYPE_RIBBON, BF4_RNK_AVENGER, "AVENGER RIBBON", "rbn_avenger", 2, 200},
	{TYPE_RIBBON, BF4_RNK_SAVIOR, "SAVIOR RIBBON", "rbn_savior", 2, 200},
	{TYPE_RIBBON, BF4_RNK_MVP, "MVP RIBBON", "rbn_mvp", 1, 200},
	{TYPE_RIBBON, BF4_RNK_MEDIKIT, "MEDIKIT RIBBON", "rbn_medikit", 8, 200},
	{TYPE_RIBBON, BF4_RNK_AMMOBOX, "AMMO RIBBON", "rbn_ammo", 8, 200},
	{TYPE_RIBBON, BF4_RNK_REVIVE, "DEFIBRILLATOR RIBBON", "rbn_revive", 5, 200},
	{TYPE_RIBBON, BF4_RNK_CTF_CAP, "FLAG CAPTURE RIBBON", "rbn_ctf1", 2, 200},
	{TYPE_RIBBON, BF4_RNK_CTF_WIN, "CTF RIBBON", "rbn_ctf2", 1, 1500},
	{} //MAX
};

new const g_medalDefinitions[E_BF4_RANK][AwardDefinitionData] = {
	{TYPE_MEDAL, BF4_RNK_MARKSMAN, "MARKSMAN MEDAL", "mdl_marksman", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_HEADSHOT, "HEADSHOT MEDAL", "mdl_headshot", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_PISTOL, "HANDGUN MEDAL", "mdl_handgun", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_ASSAULT, "ASSAULT RIFLE MEDAL", "mdl_assault", 50, 5000},
	// {BF4_RNK_CARBIN, "CARBIN MEDAL", 		"mdl_carbin",	50,	0},
	{TYPE_MEDAL, BF4_RNK_SNIPER, "SNIPER RIFLE MEDAL", "mdl_sniper", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_LMG, "LMG MEDAL", "mdl_lmg", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_DMR, "DMR MEDAL", "mdl_dmr", 50, 5000},
	// {BF4_RNK_PDW, 	"PDW MEDAL", 			"mdl_pdw",		50,	0},
	{TYPE_MEDAL, BF4_RNK_SMG, "SMG MEDAL", "mdl_pdw", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_SHOTGUN, "SHOTGUN MEDAL", "mdl_shotgun", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_MELEE, "MELEE MEDAL", "mdl_melee", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_ASSIST, "KILL ASSIST MEDAL", "mdl_assist", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_AVENGER, "AVENGER MEDAL", "mdl_avenger", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_SAVIOR, "SAVIOR MEDAL", "mdl_savior", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_MVP, "MVP MEDAL", "mdl_mvp", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_MEDIKIT, "MEDIKIT MEDAL", "mdl_medikit", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_AMMOBOX, "AMMO MEDAL", "mdl_ammo", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_REVIVE, "DEFIBRILLATOR MEDAL", "mdl_revive", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_CTF_CAP, "FLAG CAPTURE MEDAL", "mdl_ctf1", 50, 5000},
	{TYPE_MEDAL, BF4_RNK_CTF_WIN, "CTF MEDAL", "mdl_ctf2", 50, 5000},
	{} //MAX
};

const CSW_BF4_WEAPONS = (~(1 << CSW_VEST));
const CSW_BF4_PISTOLS =
	(1 << CSW_P228 | 1 << CSW_ELITE | 1 << CSW_FIVESEVEN | 1 << CSW_USP | 1 << CSW_GLOCK18 | 1 << CSW_DEAGLE);
const CSW_BF4_SHOTGUNS = (1 << CSW_M3 | 1 << CSW_XM1014);
const CSW_BF4_SMGS = (1 << CSW_MAC10 | 1 << CSW_UMP45 | 1 << CSW_MP5NAVY | 1 << CSW_TMP | 1 << CSW_P90);
const CSW_BF4_ASSAULTS =
	(1 << CSW_M4A1 | 1 << CSW_AUG | 1 << CSW_GALIL | 1 << CSW_FAMAS | 1 << CSW_AK47 | 1 << CSW_SG552);
const CSW_BF4_SNIPERS = (1 << CSW_SCOUT | 1 << CSW_AWP);
const CSW_BF4_DMRS = (1 << CSW_G3SG1 | 1 << CSW_SG550);
const CSW_BF4_LMGS = (1 << CSW_M249);
const CSW_BF4_GRENADES = (1 << CSW_HEGRENADE | 1 << CSW_SMOKEGRENADE | 1 << CSW_FLASHBANG);
const CSW_BF4_ARMORS = (1 << CSW_VEST | 1 << CSW_VESTHELM);
const CSW_BF4_GUNS = (CSW_BF4_PISTOLS | CSW_BF4_SHOTGUNS | CSW_BF4_SMGS | CSW_BF4_ASSAULTS | CSW_BF4_SNIPERS |
					  CSW_BF4_DMRS | CSW_BF4_LMGS);

new g_activeAwardDisplay[MAX_PLAYERS + 1][AwardDefinitionData];
new g_cvars[E_BF4_RANK_CVARS];
new Float:g_assist[MAX_PLAYERS + 1][MAX_PLAYERS + 1]; //damage[Attacker][Victim]
new g_savior[MAX_PLAYERS + 1][E_SAVIOR];
new g_avenger[MAX_PLAYERS + 1];
new g_maxPlayers;

new g_MsgIds[BF4_MSGID];
new g_isAwardDisplayActive[MAX_PLAYERS + 1];

new g_awardEventCounts[MAX_PLAYERS + 1][E_BF4_RANK];
new g_earnedRibbonCounts[MAX_PLAYERS + 1][E_BF4_RANK];
new g_sound[][] = {"bf4_ranks/GetAwardWave.wav", "bf4_ranks/GetMedalWave.wav"};
new g_sync_obj;

new Array:g_awardDisplayQueue[MAX_PLAYERS + 1];

new bool:g_awardSprite[TYPE_MAX][BF4_RNK_MAX];
new g_ChatPrefix[MAX_NAME_LENGTH];
new g_ready_players;
new bool:g_roundready;
new gObjectItem[MAX_PLAYERS + 1];
new g_xp[MAX_PLAYERS + 1];
new bool:g_playerReady[MAX_PLAYERS + 1];
new bool:g_isImportInProgress;
#include <bf4/progression_config>
#include <bf4/progression_core>
#include <bf4/progression_storage>
#include <bf4/progression_import>
#include <bf4/progression_hud>

public plugin_precache()
{
	ConfigLoad();

	// for(new i = 0; i <= _:E_AMMO_BOX; i++)
	// 	precache_model(ENT_MODELS[i]);

	for (new i = 0; i < TYPE_MAX; i++)
	{
		for (new n = 0; n < BF4_RNK_MAX; n++)
		{
			new path[128], descriptor[128];
			formatex(path, charsmax(path), "sprites/bf4_ranks/%s/%s.spr",
					 i == TYPE_RIBBON ? "ribbons" : "medals",
					 i == TYPE_RIBBON ? g_ribbonDefinitions[n][AWARD_SPRITE_NAME]
									  : g_medalDefinitions[n][AWARD_SPRITE_NAME]);
			formatex(descriptor, charsmax(descriptor), "sprites/bf4_ranks/%s/%s.txt",
					 i == TYPE_RIBBON ? "ribbons" : "medals",
					 i == TYPE_RIBBON ? g_ribbonDefinitions[n][AWARD_SPRITE_NAME]
									  : g_medalDefinitions[n][AWARD_SPRITE_NAME]);
			if (file_exists(path) && file_exists(descriptor))
			{
				precache_generic(path);
				precache_generic(descriptor);
				g_awardSprite[i][n] = true;
			}
			else
				log_amx("Award sprite unavailable; text/audio retained: %s", path);
		}
		precache_sound(g_sound[i]);
	}
	// precache_sound("items/gunpickup2.wav");
	// precache_sound("items/ammopickup2.wav");
	// precache_sound("items/medshot4.wav");
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR, "github.com/AoiKagase", "BF4 Ribbon");
	create_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY);
	bind_pcvar_num(create_cvar("bf4_spawn_reward", "1600"), g_cvars[E_CV_REWARD]);
	bind_pcvar_num(create_cvar("bf4_ammobox_cost", "2000"), g_cvars[E_CV_AMMOBOX_COST]);
	bind_pcvar_float(create_cvar("bf4_ammobox_interval", "0.5"), g_cvars[E_CV_AMMOBOX_INTERVAL]);
	bind_pcvar_num(create_cvar("bf4_ammobox_amount", "30"), g_cvars[E_CV_AMMOBOX_AMOUNT]);

	// register_clcmd		("say /bf4", "BF4ObjectMenu");
	// register_clcmd		("bf4menu", "BF4ObjectMenu");

	RegisterHamPlayer(Ham_TakeDamage, "BF4TakeDamage", 0);
	RegisterHamPlayer(Ham_Spawn, "BF4PlayerSpawnPost", 1);

	register_event_ex("CurWeapon", "Event_CurWeapon", RegisterEvent_Single | RegisterEvent_OnlyAlive,
					  "1=1");
	register_event_ex("DeathMsg", "BF4DeathMsg", RegisterEvent_Global);
	// register_event_ex	("TeamInfo", 		"BF4JoinTeam", 			RegisterEvent_Global);

	// RegisterHam(Ham_Think, ENT_CLASS_BREAKABLE, "BF4ObjectThink");

	g_MsgIds[MSGID_WEAPON_LIST] = get_user_msgid("WeaponList");
	g_MsgIds[MSGID_SET_FOV] = get_user_msgid("SetFOV");
	g_MsgIds[MSGID_CUR_WEAPON] = get_user_msgid("CurWeapon");
	g_MsgIds[MSGID_HIDE_WEAPON] = get_user_msgid("HideWeapon");

	g_maxPlayers = get_maxplayers();
	for (new i = 1; i <= g_maxPlayers; i++)
		g_awardDisplayQueue[i] = ArrayCreate(AwardDefinitionData);

	g_sync_obj = CreateHudSyncObj();

	StoreInit();
	register_concmd("bf4_import_progression", "ImportCommand", ADMIN_RCON, "<filename.tsv> (server console only)");
	set_task_ex(5.0, "StoreTick", 912400, _, _, SetTask_Repeat);
	set_task_ex(1.0, "ProgressionHUD", 912401, _, _, SetTask_Repeat);
	new commands[384], command[64], remaining[384];
	ConfigString("XP_COMMANDS", commands, charsmax(commands), "say /xp, say_team /xp, say /level, say_team /level");
	while (commands[0])
	{
		strtok(commands, command, charsmax(command), remaining, charsmax(remaining), ',');
		trim(command);
		if (command[0])
			register_clcmd(command, "ProgressionXPCommand");
		copy(commands, charsmax(commands), remaining);
	}
	register_logevent("ProgressionPlantedLog", 3, "2=Planted_The_Bomb");
	register_logevent("ProgressionDefusedLog", 3, "2=Defused_The_Bomb");
	set_task_ex(1.0, "CheckRoundStart", TASK_ROUND_READY, _, _, SetTask_Repeat);

	// registered func_breakable
	//	gEntItem = engfunc(EngFunc_AllocString, ENT_CLASS_BREAKABLE);

	// gSubMenuCallback = menu_makecallback("bf4_object_menu_callback");
	RegisterHookChain(RG_RoundEnd, "RoundEnd", 0);
}

public plugin_natives()
{
	register_library("bf4_ranksystem_natives");
	register_native("BF4TriggerGetRibbon", "_native_bf4_trigger_get_ribbon");
	register_library("bf4_progression_v2");
	register_native("BF4ProgressionReadyV2", "NativeProgressionReady");
	register_native("BF4GetXPV2", "NativeProgressionXP");
	register_native("BF4GiveXPV2", "NativeProgressionGive");
	register_native("BF4GetLevelV2", "NativeProgressionLevel");
	register_native("BF4GetRankV2", "NativeProgressionRank");
	register_native("BF4GetPlayerKeyV2", "NativeProgressionKey");
	register_native("BF4TriggerGetRibbonV2", "NativeProgressionAward");
}

public _native_bf4_trigger_get_ribbon(iPlugin, iParams)
{
	new id = get_param(1);
	new ribbon = get_param(2);
	new strCaption[64];

	get_string(3, strCaption, charsmax(strCaption));

	return ProgressionRecordAward(id, ribbon, strCaption);
}

ProgressionObjectiveTeamWin(team)
{
	new iPlayers[MAX_PLAYERS];
	new pnum;
	switch (team)
	{
		case CS_TEAM_T:
			get_players_ex(iPlayers, pnum, GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "Terrorist");
		case CS_TEAM_CT:
			get_players_ex(iPlayers, pnum, GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "CT");
	}

	for (new i = 0; i < pnum; i++)
	{
		ProgressionRecordAward(iPlayers[i], BF4_RNK_CTF_WIN);
	}
}

///
/// Independent objective-mode events. Saved award identifiers stay unchanged.
///
public BF4ObjectiveCaptured(id, point, team)
{
	if (get_playersnum() < g_ready_players || id < 1 || id > 32 || point < 0 || point >= 7 ||
		(team != 1 && team != 2) || !is_user_alive(id) || get_member(id, m_iTeam) != team)
		return PLUGIN_CONTINUE;

	ProgressionRecordAward(id, BF4_RNK_CTF_CAP, "Flag Capture points.");
	return PLUGIN_CONTINUE;
}

public BF4ObjectiveMatchEnded(mode, winner)
{
	if (get_playersnum() < g_ready_players || (mode != 1 && mode != 2) || (winner != 1 && winner != 2))
		return PLUGIN_CONTINUE;

	ProgressionObjectiveTeamWin(winner);
	return PLUGIN_CONTINUE;
}

///
/// END objective-mode events.
///

public RoundEnd(WinStatus:status, ScenarioEventEndRound:event, Float:tmDelay)
{
	if (g_saveInterval == 2)
		for (new id = 1; id <= g_maxPlayers; id++)
			if (g_playerReady[id])
				StoreFlush(g_playerRecordIndex[id]);

	if (event == ROUND_GAME_COMMENCE)
	{
		if (!g_roundready)
		{
			set_member_game(m_bGameStarted, false);
			SetHookChainReturn(ATYPE_BOOL, false);
			return HC_SUPERCEDE;
		}
	}

	return HC_CONTINUE;
}

public CheckRoundStart()
{
	new players[MAX_PLAYERS], pnum;
	get_players_ex(players, pnum, GetPlayers_ExcludeBots | GetPlayers_ExcludeHLTV);
	if (get_playersnum() < g_ready_players && g_ready_players > 0)
	{
		g_roundready = false;
		set_hudmessage(255, 255, 255, -1.00, -0.74, .effects = 0, .fxtime = 0.01, .holdtime = 1.0, .fadeintime = 0.01,
					   .fadeouttime = 0.2, .channel = 1);
		for (new i = 0; i < pnum; i++)
			ShowSyncHudMsg(players[i], g_sync_obj, "+---  WAITING FOR PLAYERS  ---+^n|         PLAYERS NEEDED:         |^n+---   %2d/%2d PLAYERS READY   ---+", get_playersnum(), g_ready_players);
	}
	else
	{
		if (!g_roundready)
			g_roundready = true;
	}
}

public plugin_end()
{
	StoreClose();
	for (new id = 1; id <= g_maxPlayers; id++)
		ArrayDestroy(g_awardDisplayQueue[id]);
	TrieDestroy(g_settings);
	TrieDestroy(g_rewards);
	ArrayDestroy(g_rankNames);
	ArrayDestroy(g_rankXP);
}

public client_connect(id)
{
	g_playerSessionGeneration[id]++;
	g_playerReady[id] = false;
	g_playerRecordIndex[id] = -1;
	g_xp[id] = 0;
	remove_task(id + TASK_AWARD);
	remove_task(id + TASK_HUD_SPR);
	remove_task(id + TASK_SPAWN);
	remove_task(912500 + id);
	if (g_awardDisplayQueue[id])
		ArrayClear(g_awardDisplayQueue[id]);
	g_isAwardDisplayActive[id] = false;
	g_savior[id][SV_TIME] = 0.0;
	g_savior[id][SV_TARGET] = 0;
	g_avenger[id] = 0;
	for (new i = 1; i <= g_maxPlayers; i++)
	{
		g_assist[id][i] = 0.0;
		g_assist[i][id] = 0.0;
		if (g_avenger[i] == id)
			g_avenger[i] = 0;
		if (g_savior[i][SV_TARGET] == id)
			g_savior[i][SV_TARGET] = 0;
	}
	for (new i; i < BF4_RNK_MAX; i++)
	{
		g_awardEventCounts[id][i] = 0;
		g_earnedRibbonCounts[id][i] = 0;
	}
}

public client_authorized(id)
{
	StoreAttach(id);
	new session[1];
	session[0] = g_playerSessionGeneration[id];
	set_task_ex(1.0, "AwardCheck", id + TASK_AWARD, session, sizeof session, SetTask_Repeat);
}

public client_infochanged(id)
{
	if (g_saveType != 0 || !is_user_connected(id) || g_playerRecordIndex[id] < 0)
		return;
	new name[32], key[65], record[StoreRecord];
	get_user_info(id, "name", name, charsmax(name));
	formatex(key, charsmax(key), "nick:%s", name);
	ArrayGetArray(g_progressionRecords, g_playerRecordIndex[id], record);
	if (equal(key, record[SR_PLAYER_KEY]))
		return;
	if (g_playerReady[id])
	{
		StoreCapture(id);
		StoreFlush(g_playerRecordIndex[id]);
	}
	client_connect(id);
	new session[1];
	session[0] = g_playerSessionGeneration[id];
	set_task_ex(0.1, "ProgressionNameChanged", 912500 + id, session, 1);
}

public ProgressionNameChanged(session[], task)
{
	new id = task - 912500;
	if (!is_user_connected(id) || session[0] != g_playerSessionGeneration[id])
		return;
	StoreAttach(id);
	set_task_ex(1.0, "AwardCheck", id + TASK_AWARD, session, 1, SetTask_Repeat);
}

public client_disconnected(id)
{
	if (g_playerReady[id])
	{
		StoreCapture(id);
		StoreFlush(g_playerRecordIndex[id]);
	}
	g_playerReady[id] = false;
	g_playerRecordIndex[id] = -1;
	g_playerSessionGeneration[id]++;
	remove_task(id + TASK_AWARD);
	remove_task(id + TASK_HUD_SPR);
	remove_task(id + TASK_SPAWN);
	remove_task(912500 + id);
	ArrayClear(g_awardDisplayQueue[id]);
	g_isAwardDisplayActive[id] = false;
}

public ProgressionPlantedLog()
{
	ProgressionPlanted(get_loguser_index());
}
public ProgressionDefusedLog()
{
	ProgressionDefused(get_loguser_index());
}

public AwardCheck(session[], task)
{
	new id = task - TASK_AWARD;
	if (!is_user_authorized(id) || session[0] != g_playerSessionGeneration[id])
	{
		remove_task(task);
		return PLUGIN_CONTINUE;
	}

	if (get_playersnum() < g_ready_players)
		return PLUGIN_CONTINUE;

	if (!is_user_alive(id))
		return PLUGIN_CONTINUE;

	if (ArraySize(g_awardDisplayQueue[id]) > 0 && !g_isAwardDisplayActive[id])
	{
		new ribbon[AwardDefinitionData];
		ArrayGetArray(g_awardDisplayQueue[id], 0, ribbon, sizeof(ribbon));

		new score[16];
		num_to_str(ribbon[AWARD_XP_REWARD], score, charsmax(score));

		g_isAwardDisplayActive[id] = true;
		g_activeAwardDisplay[id] = ribbon;
		client_cmd(id, "spk %s", g_sound[ribbon[AWARD_TYPE]]);
		if (ribbon[AWARD_TYPE] == TYPE_RIBBON)
			set_hudmessage(255, 255, 255, -1.00, -0.65, .effects = 2, .fxtime = 0.01, .holdtime = 2.5,
						   .fadeintime = 0.01, .fadeouttime = 0.2, .channel = 1);
		else
			set_hudmessage(255, 255, 255, -1.00, -0.74, .effects = 2, .fxtime = 0.01, .holdtime = 2.5,
						   .fadeintime = 0.01, .fadeouttime = 0.2, .channel = 1);

		show_hudmessage(id, ribbon[AWARD_DISPLAY_NAME]);
		Show_Rank_Event(id, ribbon);

		if (ribbon[AWARD_XP_REWARD] > 0)
		{
			if (ribbon[AWARD_TYPE] == TYPE_RIBBON)
				set_hudmessage(255, 255, 255, -1.00, -0.54, .effects = 2, .fxtime = 0.01, .holdtime = 2.5,
							   .fadeintime = 0.01, .fadeouttime = 0.2, .channel = 2);
			else
				set_hudmessage(255, 255, 255, -1.00, -0.40, .effects = 2, .fxtime = 0.01, .holdtime = 2.5,
							   .fadeintime = 0.01, .fadeouttime = 0.2, .channel = 2);

			show_hudmessage(id, score);
		}
		set_task_ex(3.2, "Clear_Rank_Event", id + TASK_HUD_SPR, session, 1);
		ArrayDeleteItem(g_awardDisplayQueue[id], 0);
	}
	return PLUGIN_CONTINUE;
}

public BF4PlayerSpawnPost(id)
{
	for (new i = 1; i <= g_maxPlayers; i++)
	{
		g_assist[id][i] = 0.0;
		g_assist[i][id] = 0.0;
	}

	if (is_user_alive(id))
		cs_set_user_money(id, cs_get_user_money(id) + g_cvars[E_CV_REWARD]);

	new session[1];
	session[0] = g_playerSessionGeneration[id];
	set_task_ex(0.1, "TaskSpawn", id + TASK_SPAWN, session, 1);
	return HAM_IGNORED;
}

public TaskSpawn(session[], taskid)
{
	new id = taskid - TASK_SPAWN;
	if (!is_user_connected(id) || session[0] != g_playerSessionGeneration[id])
		return;
	if (pev_valid(gObjectItem[id]))
	{
		new flags;
		pev(gObjectItem[id], pev_flags, flags);
		set_pev(gObjectItem[id], pev_flags, flags | FL_KILLME);
		dllfunc(DLLFunc_Think, gObjectItem[id]);
		gObjectItem[id] = 0;
	}
}

public BF4TakeDamage(victim, inflictor, attacker, Float:damage, bits)
{
	// Assist Damage.
	if (is_user_connected(attacker))
	{
		if (cs_get_user_team(attacker) != cs_get_user_team(victim))
			g_assist[attacker][victim] += damage;
		// Savior Damage.
		g_savior[attacker][SV_TARGET] = victim;
		g_savior[attacker][SV_TIME] = Float:get_gametime();
	}

	return HAM_IGNORED;
}

public BF4DeathMsg()
{
	if (get_playersnum() < g_ready_players)
		return PLUGIN_CONTINUE;

	new iAttacker = read_data(1);
	new iVictim = read_data(2);
	new isHeadshot = read_data(3);
	new wpnname[MAX_NAME_LENGTH];

	read_data(4, wpnname, charsmax(wpnname));
	if (iVictim < 1 || iVictim > g_maxPlayers || !is_user_connected(iVictim))
		return PLUGIN_CONTINUE;
	if (g_saveInterval == 1 && g_playerReady[iVictim])
		StoreFlush(g_playerRecordIndex[iVictim]);
	if (iAttacker < 1 || iAttacker > g_maxPlayers || !is_user_connected(iAttacker))
		return PLUGIN_CONTINUE;
	if (iAttacker == iVictim)
	{
		ProgressionReward(iVictim, "suicide");
		return PLUGIN_CONTINUE;
	}
	if (get_user_team(iAttacker) == get_user_team(iVictim))
	{
		ProgressionReward(iAttacker, "teamkill");
		return PLUGIN_CONTINUE;
	}
	new weaponReward[32];
	copy(weaponReward, charsmax(weaponReward), wpnname);
	if (equal(weaponReward, "hegrenade"))
		copy(weaponReward, charsmax(weaponReward), "grenade");
	if (g_combined)
	{
		ProgressionReward(iAttacker, "kill");
		if (isHeadshot)
			ProgressionReward(iAttacker, "headshot");
		if (HasReward(weaponReward))
			ProgressionReward(iAttacker, weaponReward);
	}
	else if (HasReward(weaponReward))
		ProgressionReward(iAttacker, weaponReward);
	else if (isHeadshot && HasReward("headshot"))
		ProgressionReward(iAttacker, "headshot");
	else
		ProgressionReward(iAttacker, "kill");
	if (ConfigNumber("NOTIFY_ON_KILL"))
		client_print(iAttacker, print_chat, "[BF4Ranks] XP: %d", g_xp[iAttacker]);
	new BF4_WEAPONCLASS:iWpnClass = BF4WeaponDeathClassV2(iAttacker, iVictim);
	if (iWpnClass == BF4_WEAPONCLASS_NONE)
		iWpnClass = BF4WeaponNameToClass(iAttacker, wpnname);

	if (BF4GetUserTeam(iAttacker) != BF4GetUserTeam(iVictim))
	{
		// AVENGER RIBBON
		RibbonCheckAvenger(iAttacker, iVictim);

		// SAVIOR RIBBON
		RibbonCheckSavior(iAttacker, iVictim, get_gametime());

		// HEADSHOT/MARKSMAN RIBBON
		RibbonCheckHeadshot(iAttacker, iVictim, isHeadshot, iWpnClass);

		// KILL ASSIST RIBBON
		RibbonCheckAssist(iAttacker, iVictim);

		// WEAPON CLASS RIBBON
		RibbonCheckWeaponClass(iAttacker, iWpnClass);
	}
	return PLUGIN_CONTINUE;
}

stock RibbonCheckAvenger(const iAttacker, const iVictim)
{
	if (g_avenger[iAttacker] == iVictim)
		ProgressionRecordAward(iAttacker, BF4_RNK_AVENGER, "Avenger points.");

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
				ProgressionRecordAward(iAttacker, BF4_RNK_SAVIOR, "Savior points.");
			}
		}
	}
}

stock RibbonCheckWeaponClass(const iAttacker, const BF4_WEAPONCLASS:iWpnClass)
{
	// WEAPON CHECK
	new ranks;
	switch (iWpnClass)
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

	ProgressionRecordAward(iAttacker, ranks);

	return;
}

stock RibbonCheckHeadshot(const iAttacker, const iVictim, const isHeadshot, const BF4_WEAPONCLASS:iWpnClass)
{
	// HEADSHOT RIBBON
	if (isHeadshot)
	{
		ProgressionRecordAward(iAttacker, BF4_RNK_HEADSHOT, "Headshot points.");

		if (iWpnClass == BF4_WEAPONCLASS_SNIPERS)
		{
			new Float:vAttacker[3];
			new Float:vVictim[3];
			pev(iAttacker, pev_origin, vAttacker);
			pev(iVictim, pev_origin, vVictim);
			if (UnitsToMeters(xs_vec_distance(vAttacker, vVictim)) >= 50.0)
			{
				ProgressionRecordAward(iAttacker, BF4_RNK_MARKSMAN, "Marksman points.");
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
	for (new i = 1; i <= g_maxPlayers; i++)
	{
		if (i != iAttacker)
		{
			if (g_assist[i][iVictim] > 0.0)
			{
				set_hudmessage(255, 255, 255, -1.00, -0.25, .effects = 2, .fxtime = 0.01, .holdtime = 2.5,
							   .fadeintime = 0.01, .fadeouttime = 0.2, .channel = 2);
				if (g_assist[i][iVictim] <= 75)
				{
					show_hudmessage(i, "+%d Assist points.", floatround(g_assist[i][iVictim]));
					ProgressionGiveXP(i, floatround(g_assist[i][iVictim]));
				}
				else
				{
					show_hudmessage(i, "+%d Assist points.", RewardValue(i, "kill"));
					ProgressionGiveXP(i, RewardValue(i, "kill"));
				}

				ProgressionRecordAward(i, BF4_RNK_ASSIST);
			}
			g_assist[i][iVictim] = 0.0;
		}
	}
	return HAM_IGNORED;
}

stock Show_Rank_Event(const id, const ribbon[AwardDefinitionData])
{
	if (!g_awardSprite[ribbon[AWARD_TYPE]][ribbon[AWARD_ID]])
		return;
	new clip, ammo;
	new weapon = cs_get_user_weapon(id, clip, ammo);

	switch (weapon)
	{
		case CSW_P228:
			SetMessage_WeaponList(id, 2, Ammo_357SIG, 52, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_SCOUT:
			SetMessage_WeaponList(id, 2, Ammo_762Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_HEGRENADE:
			SetMessage_WeaponList(id, 2, Ammo_HEGRENADE, 1, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_XM1014:
			SetMessage_WeaponList(id, 2, Ammo_12Gauge, 32, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_C4:
			SetMessage_WeaponList(id, 2, Ammo_C4, 1, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_MAC10:
			SetMessage_WeaponList(id, 2, Ammo_45ACP, 100, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_AUG:
			SetMessage_WeaponList(id, 2, Ammo_556Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_SMOKEGRENADE:
			SetMessage_WeaponList(id, 2, Ammo_SMOKEGRENADE, 1, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_ELITE:
			SetMessage_WeaponList(id, 2, Ammo_9MM, 120, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_FIVESEVEN:
			SetMessage_WeaponList(id, 2, Ammo_57MM, 100, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_UMP45:
			SetMessage_WeaponList(id, 2, Ammo_45ACP, 100, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_SG550:
			SetMessage_WeaponList(id, 2, Ammo_556Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_GALIL:
			SetMessage_WeaponList(id, 2, Ammo_556Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_FAMAS:
			SetMessage_WeaponList(id, 2, Ammo_556Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_USP:
			SetMessage_WeaponList(id, 2, Ammo_45ACP, 100, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_GLOCK18:
			SetMessage_WeaponList(id, 2, Ammo_9MM, 120, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_AWP:
			SetMessage_WeaponList(id, 2, Ammo_338Magnum, 30, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_MP5NAVY:
			SetMessage_WeaponList(id, 2, Ammo_9MM, 120, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_M249:
			SetMessage_WeaponList(id, 2, Ammo_556NatoBox, 200, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_M3:
			SetMessage_WeaponList(id, 2, Ammo_12Gauge, 32, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_M4A1:
			SetMessage_WeaponList(id, 2, Ammo_556Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_TMP:
			SetMessage_WeaponList(id, 2, Ammo_9MM, 120, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_G3SG1:
			SetMessage_WeaponList(id, 2, Ammo_762Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_FLASHBANG:
			SetMessage_WeaponList(id, 2, Ammo_FLASHBANG, 2, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_DEAGLE:
			SetMessage_WeaponList(id, 2, Ammo_50AE, 35, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_SG552:
			SetMessage_WeaponList(id, 2, Ammo_556Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_AK47:
			SetMessage_WeaponList(id, 2, Ammo_762Nato, 90, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_KNIFE:
			SetMessage_WeaponList(id, 2, Ammo_None, -1, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		case CSW_P90:
			SetMessage_WeaponList(id, 2, Ammo_57MM, 100, ribbon[AWARD_TYPE], ribbon[AWARD_ID]);
		default:
			return;
	}

	SetMessage_SetFOV(id, 89);
	SetMessage_CurWeapon(id, clip);
	SetMessage_SetFOV(id, 90);
}

stock SetMessage_WeaponList(const id, const pWpnId, const Ammo:pAmmoId, const pAmmoMaxAmount, const type, const ribbon)
{
	message_begin(MSG_ONE, g_MsgIds[MSGID_WEAPON_LIST], .player = id);
	{
		if (type == TYPE_RIBBON)
			write_string(fmt("bf4_ranks/ribbons/%s", g_ribbonDefinitions[ribbon][AWARD_SPRITE_NAME]));
		else
			write_string(fmt("bf4_ranks/medals/%s", g_medalDefinitions[ribbon][AWARD_SPRITE_NAME]));
		write_byte(_:pAmmoId);
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

stock SetMessage_SetFOV(const id, const FOV)
{
	message_begin(MSG_ONE, g_MsgIds[MSGID_SET_FOV], .player = id);
	write_byte(FOV);
	message_end();
}

stock SetMessage_CurWeapon(const id, const ammo)
{
	message_begin(MSG_ONE, g_MsgIds[MSGID_CUR_WEAPON], .player = id);
	write_byte(1);
	write_byte(2);
	write_byte(ammo);
	message_end();
}

stock SetMessage_HideWeapon(const id)
{
	message_begin(MSG_ONE, g_MsgIds[MSGID_HIDE_WEAPON], .player = id);
	write_byte(0);
	message_end();
}

public Clear_Rank_Event(session[], TaskId)
{
	new id = TaskId - TASK_HUD_SPR;
	if (!is_user_connected(id) || session[0] != g_playerSessionGeneration[id])
		return;
	g_isAwardDisplayActive[id] = false;
	SetMessage_HideWeapon(id);
}

public Event_CurWeapon(const id)
{
	if (!g_isAwardDisplayActive[id] || get_ent_data(id, "CBasePlayer", "m_iFOV") != 90)
	{
		new clip, ammo;
		new weapon = cs_get_user_weapon(id, clip, ammo);
		if (weapon == CSW_TMP)
		{
			message_begin(MSG_ONE, g_MsgIds[MSGID_WEAPON_LIST], .player = id);
			{
				write_string("weapon_tmp");
				write_byte(_:Ammo_9MM);
				write_byte(120);
				write_byte(-1);
				write_byte(-1);
				write_byte(0);
				write_byte(0);
				write_byte(CSW_TMP);
				write_byte(0);
			}
			message_end();
			SetMessage_CurWeapon(id, clip);
		}
		return;
	}

	Show_Rank_Event(id, g_activeAwardDisplay[id]);
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

				if (bits & CSW_BF4_PISTOLS)
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

public plugin_cfg()
{
	if (LibraryExists("crxranks", LibType_Library))
		set_fail_state("Disable OciXCrom Rank System (crxranks) before enabling standalone BF4 progression; dual XP writers refused");
}
