#pragma semicolon 1
#pragma tabsize 4

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <reapi>
#include <bf4classes>
#include <bf4/objective_rules>
#include <bf4/objective_config>

#define MAX_OBJECTIVE_SPAWNS 128
#define TASK_OBJECTIVES 913100
#define MATCH_STOPPED 0
#define MATCH_WAITING 1
#define MATCH_RUNNING 2
#define MATCH_PAUSED 3
#define MATCH_ENDED 4

enum _:ObjectiveSpawn
{
	SPAWN_TEAM,
	SPAWN_POINT,
	Float:SPAWN_ORIGIN[3],
	Float:SPAWN_YAW
};

new const POINT_SPRITE[] = "sprites/bf4_ranks/conquest/point.spr";
new const CSGameRules_Members:OBJECTIVE_MEMBERS[] = {m_bMapHasBombTarget, m_bMapHasBombZone, m_bMapHasRescueZone,
	m_bMapHasEscapeZone, m_bMapHasVIPSafetyZone};
new g_mode, g_matchState, g_maxPlayers, g_pointCount, g_spawnCount;
new g_points[OBJ_MAX_POINTS][ObjectivePoint];
new bool:g_pointPresent[OBJ_MAX_POINTS], Float:g_pointOrigin[OBJ_MAX_POINTS][3];
new Float:g_pointRadius[OBJ_MAX_POINTS], g_pointEntity[OBJ_MAX_POINTS];
new bool:g_inside[OBJ_MAX_POINTS][33], bool:g_pointContested[OBJ_MAX_POINTS];
new g_spawns[MAX_OBJECTIVE_SPAWNS][ObjectiveSpawn];
new g_tickets[3], g_startTickets, g_minPlayers;
new Float:g_captureTime, Float:g_respawnDelay, Float:g_bleedInterval, Float:g_timeLimit;
new g_bleedAmount, Float:g_activeTime, Float:g_lastTick, Float:g_bleedElapsed, Float:g_nextHud;
new g_deathTeam[33], Float:g_respawnAt[33], bool:g_isRedeploying[33];
new g_spawnSelection[33], g_deployMenu[33], g_connectionGeneration[33];
new Float:g_deployOrigin[33][3], Float:g_deployYaw[33];
new g_captureForward, g_matchForward, g_hud, g_trace, g_ringSprite;
new bool:g_hasControl, bool:g_layoutReady, bool:g_manuallyStopped, bool:g_hasSprite;
new g_savedObjectives[sizeof OBJECTIVE_MEMBERS], g_freezeCvar, g_savedFreeze;
new g_modeCvar, g_domTicketsCvar, g_cqTicketsCvar, g_captureCvar, g_respawnCvar;
new g_bleedIntervalCvar, g_bleedAmountCvar, g_timeLimitCvar, g_minPlayersCvar;

public plugin_precache()
{
	g_ringSprite = precache_model("sprites/laserbeam.spr"); // Standard CS asset; no CS Flags model dependency.
	g_hasSprite = bool:file_exists(POINT_SPRITE);
	if (g_hasSprite)
		precache_model(POINT_SPRITE);
}

public plugin_natives()
{
	register_library("bf4_objectives_v1");
	register_native("BF4ObjectivesAPIVersion", "NativeAPIVersion");
	register_native("BF4ObjectiveMode", "NativeMode");
	register_native("BF4ObjectivesRunning", "NativeRunning");
	register_native("BF4ObjectiveTickets", "NativeTickets");
}

public plugin_init()
{
	register_plugin("[BF4] Objective Modes", "1.0.0", "BF4RankSystem contributors");
	g_maxPlayers = get_maxplayers();
	g_trace = create_tr2();
	g_hud = CreateHudSyncObj();
	g_captureForward = CreateMultiForward("BF4ObjectiveCaptured", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	g_matchForward = CreateMultiForward("BF4ObjectiveMatchEnded", ET_IGNORE, FP_CELL, FP_CELL);
	g_modeCvar = create_cvar("bf4_objective_mode", "off");
	g_domTicketsCvar = create_cvar("bf4_domination_tickets", "100");
	g_cqTicketsCvar = create_cvar("bf4_conquest_tickets", "400");
	g_captureCvar = create_cvar("bf4_objective_capture_time", "10");
	g_respawnCvar = create_cvar("bf4_objective_respawn_delay", "5");
	g_bleedIntervalCvar = create_cvar("bf4_objective_bleed_interval", "2");
	g_bleedAmountCvar = create_cvar("bf4_objective_bleed_amount", "1");
	g_timeLimitCvar = create_cvar("bf4_objective_time_limit", "0");
	g_minPlayersCvar = create_cvar("bf4_objective_min_players", "2");
	g_freezeCvar = get_cvar_pointer("mp_freezetime");
	AutoExecConfig(true, "objectives", "bf4");
	RegisterHamPlayer(Ham_Killed, "ObjectivePlayerKilledPost", true);
	RegisterHamPlayer(Ham_Spawn, "ObjectivePlayerSpawnPost", true);
	// Block only the original bomb attack, preserving custom weapon_c4 deployments (claymore).
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_c4", "ObjectiveBombPrimaryAttack", false);
	RegisterHookChain(RG_CSGameRules_CheckWinConditions, "ObjectiveCheckWinConditions", false);
	RegisterHookChain(RG_RoundEnd, "ObjectiveRoundEnd", false);
	RegisterHookChain(RG_CSGameRules_RestartRound, "ObjectiveRoundRestarted", true);
	register_clcmd("say /deploy", "ObjectiveDeployMenu");
	register_clcmd("say_team /deploy", "ObjectiveDeployMenu");
	register_concmd("bf4_objective_start", "CommandStart", ADMIN_CFG);
	register_concmd("bf4_objective_stop", "CommandStop", ADMIN_CFG);
	register_concmd("bf4_objective_status", "CommandStatus", ADMIN_CFG);
	register_concmd("bf4_objective_origin", "CommandOrigin", ADMIN_CFG);
	for (new id = 1; id <= g_maxPlayers; id++)
		g_deployMenu[id] = -1;
}

public OnConfigsExecuted()
{
	new mode[24];
	get_pcvar_string(g_modeCvar, mode, charsmax(mode));
	if (equal(mode, "off"))
		return;
	if (equal(mode, "domination"))
		g_mode = OBJ_MODE_DOMINATION;
	else if (equal(mode, "conquest"))
		g_mode = OBJ_MODE_CONQUEST;
	else
	{
		log_amx("Invalid bf4_objective_mode; mode remains stopped.");
		return;
	}
	if (is_plugin_loaded("csflags.amxx", true) != -1 || is_plugin_loaded("csflags") != -1 ||
		is_plugin_loaded("bf4_game_conquest.amxx", true) != -1 || is_plugin_loaded("[BF4] GameRules Conquest") != -1)
	{
		log_amx("Disable CS Flags and the old Conquest prototype before enabling Objective Modes.");
		return;
	}
	g_startTickets = get_pcvar_num(g_mode == OBJ_MODE_DOMINATION ? g_domTicketsCvar : g_cqTicketsCvar);
	g_captureTime = get_pcvar_float(g_captureCvar);
	g_respawnDelay = get_pcvar_float(g_respawnCvar);
	g_bleedInterval = get_pcvar_float(g_bleedIntervalCvar);
	g_bleedAmount = get_pcvar_num(g_bleedAmountCvar);
	g_timeLimit = get_pcvar_float(g_timeLimitCvar) * 60.0;
	g_minPlayers = get_pcvar_num(g_minPlayersCvar);
	if (g_startTickets < 1 || g_startTickets > 100000 || !(g_captureTime >= 1.0 && g_captureTime <= 600.0) ||
		!(g_respawnDelay >= 1.0 && g_respawnDelay <= 120.0) || !(g_bleedInterval >= 0.25 && g_bleedInterval <= 600.0) ||
		g_bleedAmount < 1 || g_bleedAmount > 1000 || !(g_timeLimit >= 0.0 && g_timeLimit <= 86400.0) ||
		g_minPlayers < 2 || g_minPlayers > g_maxPlayers)
	{
		log_amx("Objective setting outside supported range; mode remains stopped.");
		return;
	}
	g_layoutReady = ObjectiveLoadLayout();
	if (!g_layoutReady)
		return;
	ObjectiveCreateMarkers();
	ObjectiveResetMatch();
	set_task(0.25, "ObjectiveTick", TASK_OBJECTIVES, _, _, "b");
}

stock bool:ObjectiveLoadLayout()
{
	new directory[192], map[64], path[256];
	get_configsdir(directory, charsmax(directory));
	get_mapname(map, charsmax(map));
	formatex(path, charsmax(path), "%s/bf4/objectives/%s.ini", directory, map);
	new file = fopen(path, "rt");
	if (!file)
	{
		log_amx("No objective layout: %s. Standard CS rules remain active.", path);
		return false;
	}
	new line[256], row[ObjectiveConfigRow], lineNumber, bool:valid = true;
	while (!feof(file))
	{
		fgets(file, line, charsmax(line));
		lineNumber++;
		new kind = strlen(line) >= charsmax(line) ? -1 : ObjectiveParseLine(line, row);
		if (kind < 0 || (kind > 0 && !ObjectiveAddLayoutRow(kind, row)))
		{
			log_amx("Invalid objective layout %s:%d; entire layout rejected.", path, lineNumber);
			valid = false;
			break;
		}
	}
	fclose(file);
	if (!valid || (g_mode == OBJ_MODE_DOMINATION ? g_pointCount != 3 : g_pointCount < 1))
	{
		log_amx("Domination requires 3 points; Conquest requires 1..7 points. Mode remains stopped.");
		return false;
	}
	for (new i; i < g_spawnCount; i++)
	{
		new reference = g_spawns[i][SPAWN_POINT];
		if (reference && (!g_pointPresent[reference - 1] ||
			get_distance_f(g_spawns[i][SPAWN_ORIGIN], g_pointOrigin[reference - 1]) > g_pointRadius[reference - 1]))
		{
			log_amx("Spawn refers to an absent/distant point; layout rejected.");
			return false;
		}
	}
	if (!ObjectiveCollectMapSpawns())
		return false;
	new bool:baseT, bool:baseCT;
	for (new i; i < g_spawnCount; i++)
	{
		if (g_spawns[i][SPAWN_POINT])
			continue;
		baseT = baseT || g_spawns[i][SPAWN_TEAM] != OBJ_TEAM_CT;
		baseCT = baseCT || g_spawns[i][SPAWN_TEAM] != OBJ_TEAM_T;
	}
	if (!baseT || !baseCT)
		log_amx("Both teams require a base/map spawn; layout rejected.");
	return baseT && baseCT;
}

stock bool:ObjectiveAddLayoutRow(kind, const row[ObjectiveConfigRow])
{
	new point = row[OBJ_CFG_POINT];
	if (kind == OBJ_ROW_POINT)
	{
		if (g_pointPresent[point])
			return false;
		g_pointPresent[point] = true;
		g_pointCount++;
		for (new axis; axis < 3; axis++)
			g_pointOrigin[point][axis] = float(row[OBJ_CFG_X + axis]);
		g_pointRadius[point] = float(row[OBJ_CFG_VALUE]);
		return true;
	}
	if (g_spawnCount >= MAX_OBJECTIVE_SPAWNS)
		return false;
	g_spawns[g_spawnCount][SPAWN_TEAM] = row[OBJ_CFG_TEAM];
	g_spawns[g_spawnCount][SPAWN_POINT] = point + 1;
	for (new axis; axis < 3; axis++)
		g_spawns[g_spawnCount][SPAWN_ORIGIN][axis] = float(row[OBJ_CFG_X + axis]);
	g_spawns[g_spawnCount++][SPAWN_YAW] = float(row[OBJ_CFG_VALUE]);
	return true;
}

stock bool:ObjectiveCollectMapSpawns()
{
	new const classes[][] = {"info_player_deathmatch", "info_player_start"};
	for (new team = OBJ_TEAM_T; team <= OBJ_TEAM_CT; team++)
	{
		new entity;
		while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classes[team - 1])) > 0)
		{
			if (g_spawnCount >= MAX_OBJECTIVE_SPAWNS)
			{
				log_amx("More than 128 combined spawns; layout rejected.");
				return false;
			}
			g_spawns[g_spawnCount][SPAWN_TEAM] = g_mode == OBJ_MODE_DOMINATION ? 0 : team;
			g_spawns[g_spawnCount][SPAWN_POINT] = 0;
			pev(entity, pev_origin, g_spawns[g_spawnCount][SPAWN_ORIGIN]);
			new Float:angles[3];
			pev(entity, pev_angles, angles);
			g_spawns[g_spawnCount++][SPAWN_YAW] = angles[1];
		}
	}
	return true;
}

stock ObjectiveCreateMarkers()
{
	if (!g_hasSprite)
	{
		log_amx("Optional point sprite missing; standard beam rings and HUD remain available.");
		return;
	}
	for (new point; point < OBJ_MAX_POINTS; point++)
	{
		if (!g_pointPresent[point])
			continue;
		new entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"));
		if (!pev_valid(entity))
			continue;
		g_pointEntity[point] = entity;
		set_pev(entity, pev_classname, "bf4_objective_marker");
		engfunc(EngFunc_SetModel, entity, POINT_SPRITE);
		new Float:origin[3];
		for (new axis; axis < 3; axis++)
			origin[axis] = g_pointOrigin[point][axis];
		origin[2] += 48.0;
		engfunc(EngFunc_SetOrigin, entity, origin);
		set_pev(entity, pev_rendermode, kRenderTransAdd);
		set_pev(entity, pev_renderamt, 160.0);
		set_pev(entity, pev_rendercolor, Float:{220.0, 220.0, 220.0});
		set_pev(entity, pev_scale, 0.5);
		set_pev(entity, pev_framerate, 1.0);
		dllfunc(DLLFunc_Spawn, entity);
	}
}

stock ObjectiveAcquireControl()
{
	if (g_hasControl)
		return;
	for (new i; i < sizeof OBJECTIVE_MEMBERS; i++)
		g_savedObjectives[i] = get_member_game(OBJECTIVE_MEMBERS[i]);
	g_savedFreeze = get_pcvar_num(g_freezeCvar);
	set_pcvar_num(g_freezeCvar, 0);
	g_hasControl = true;
	ObjectiveDisableMapObjectives();
}

stock ObjectiveDisableMapObjectives()
{
	for (new i; i < sizeof OBJECTIVE_MEMBERS; i++)
		set_member_game(OBJECTIVE_MEMBERS[i], false);
}

stock ObjectiveReleaseControl()
{
	if (!g_hasControl)
		return;
	for (new i; i < sizeof OBJECTIVE_MEMBERS; i++)
		set_member_game(OBJECTIVE_MEMBERS[i], g_savedObjectives[i]);
	set_pcvar_num(g_freezeCvar, g_savedFreeze);
	g_hasControl = false;
	for (new point; point < OBJ_MAX_POINTS; point++)
		if (pev_valid(g_pointEntity[point]))
			set_pev(g_pointEntity[point], pev_effects, pev(g_pointEntity[point], pev_effects) | EF_NODRAW);
}

stock ObjectiveResetMatch()
{
	ObjectiveAcquireControl();
	g_matchState = MATCH_WAITING;
	g_tickets[OBJ_TEAM_T] = g_startTickets;
	g_tickets[OBJ_TEAM_CT] = g_startTickets;
	g_activeTime = 0.0;
	g_bleedElapsed = 0.0;
	g_lastTick = get_gametime();
	for (new point; point < OBJ_MAX_POINTS; point++)
	{
		g_points[point][OBJ_OWNER] = 0;
		g_points[point][OBJ_PROGRESS] = 0;
		g_pointContested[point] = false;
		if (pev_valid(g_pointEntity[point]))
			set_pev(g_pointEntity[point], pev_effects, pev(g_pointEntity[point], pev_effects) & ~EF_NODRAW);
	}
	for (new id = 1; id <= g_maxPlayers; id++)
		ObjectiveClearPlayer(id);
}

stock ObjectiveClearPlayer(id)
{
	g_deathTeam[id] = 0;
	g_respawnAt[id] = 0.0;
	g_isRedeploying[id] = false;
	g_spawnSelection[id] = 0;
	if (g_deployMenu[id] != -1)
	{
		menu_destroy(g_deployMenu[id]);
		g_deployMenu[id] = -1;
	}
}

public client_putinserver(id)
{
	ObjectiveClearPlayer(id);
	g_connectionGeneration[id] = g_connectionGeneration[id] == 2147483647 ? 1 : g_connectionGeneration[id] + 1;
}

public client_disconnected(id)
{
	if (g_matchState == MATCH_RUNNING || g_matchState == MATCH_PAUSED)
		ObjectiveSpendDebt(id);
	ObjectiveClearPlayer(id);
}

public ObjectivePlayerKilledPost(id)
{
	if ((g_matchState != MATCH_RUNNING && g_matchState != MATCH_PAUSED) || id < 1 || id > g_maxPlayers)
		return;
	new team = get_member(id, m_iTeam);
	if (team != OBJ_TEAM_T && team != OBJ_TEAM_CT)
		return;
	if (!g_deathTeam[id])
		g_deathTeam[id] = team;
	g_respawnAt[id] = g_activeTime + g_respawnDelay;
}

stock ObjectiveSpendDebt(id)
{
	new team = g_deathTeam[id];
	if (team == OBJ_TEAM_T || team == OBJ_TEAM_CT)
		g_tickets[team] = ObjectiveSpend(g_tickets[team], 1);
	g_deathTeam[id] = 0;
}

stock ObjectiveSettleDebt(id, bool:redeploying)
{
	new action = ObjectiveResolveDebt(g_deathTeam[id], bool:is_user_alive(id), redeploying);
	if (action == OBJ_DEBT_SPEND)
		ObjectiveSpendDebt(id);
	else if (action == OBJ_DEBT_CLEAR)
		g_deathTeam[id] = 0;
}

public ObjectivePlayerSpawnPost(id)
{
	if (!g_hasControl || !is_user_alive(id) || (g_matchState != MATCH_RUNNING && g_matchState != MATCH_PAUSED))
		return;
	if (g_isRedeploying[id])
	{
		new Float:angles[3];
		angles[1] = g_deployYaw[id];
		engfunc(EngFunc_SetOrigin, id, g_deployOrigin[id]);
		set_pev(id, pev_angles, angles);
		set_pev(id, pev_v_angle, angles);
		set_pev(id, pev_fixangle, 1);
		set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0});
	}
	// An external resurrection keeps its position and does not spend a ticket.
	ObjectiveSettleDebt(id, g_isRedeploying[id] || (g_deathTeam[id] != 0 && g_deathTeam[id] != get_member(id, m_iTeam)));
}

public ObjectiveCheckWinConditions()
{
	return g_hasControl && (g_matchState == MATCH_RUNNING || g_matchState == MATCH_PAUSED) ? HC_SUPERCEDE : HC_CONTINUE;
}

public ObjectiveBombPrimaryAttack()
{
	if (!g_hasControl)
		return HAM_IGNORED;
	return HAM_SUPERCEDE;
}

public ObjectiveRoundEnd(WinStatus:status, ScenarioEventEndRound:event, Float:delay)
{
	if (!g_hasControl || (g_matchState != MATCH_RUNNING && g_matchState != MATCH_PAUSED) ||
		event == ROUND_GAME_RESTART || event == ROUND_GAME_OVER)
		return HC_CONTINUE;
	SetHookChainReturn(ATYPE_BOOL, false);
	return HC_SUPERCEDE;
}

public ObjectiveRoundRestarted()
{
	if (g_layoutReady && !g_manuallyStopped)
	{
		ObjectiveResetMatch();
		ObjectiveDisableMapObjectives();
	}
}

public ObjectiveTick()
{
	new Float:now = get_gametime(), Float:delta = now - g_lastTick;
	g_lastTick = now;
	if (g_matchState == MATCH_STOPPED || g_matchState == MATCH_ENDED)
		return;
	// A disconnect can spend the final ticket even when that leaves a team empty.
	new disconnectedWinner = ObjectiveWinner(g_tickets[1], g_tickets[2]);
	if ((g_matchState == MATCH_RUNNING || g_matchState == MATCH_PAUSED) && disconnectedWinner != OBJ_NO_WINNER)
	{
		ObjectiveFinish(disconnectedWinner);
		return;
	}
	if (delta < 0.0)
		delta = 0.0;
	if (delta > 1.0)
		delta = 1.0; // Avoid applying a long catch-up burst after a server stall.

	new participants[3];
	for (new id = 1; id <= g_maxPlayers; id++)
	{
		if (!is_user_connected(id) || is_user_hltv(id))
			continue;
		new team = get_member(id, m_iTeam);
		if (team == OBJ_TEAM_T || team == OBJ_TEAM_CT)
			participants[team]++;
	}
	new bool:ready = participants[1] > 0 && participants[2] > 0 && participants[1] + participants[2] >= g_minPlayers;
	if (!ready || get_member_game(m_bFreezePeriod) || !get_member_game(m_bGameStarted))
	{
		if (g_matchState == MATCH_RUNNING)
			g_matchState = MATCH_PAUSED;
		ObjectiveShowHud(now);
		return;
	}
	g_matchState = MATCH_RUNNING;
	g_activeTime += delta;
	ObjectiveUpdatePoints(delta);
	g_bleedElapsed += delta;
	while (g_bleedElapsed >= g_bleedInterval)
	{
		g_bleedElapsed -= g_bleedInterval;
		new owned[3];
		for (new point; point < OBJ_MAX_POINTS; point++)
			if (g_pointPresent[point])
				owned[g_points[point][OBJ_OWNER]]++;
		new losingTeam = ObjectiveBleedTeam(owned[1], owned[2], g_pointCount);
		if (losingTeam)
			g_tickets[losingTeam] = ObjectiveSpend(g_tickets[losingTeam], g_bleedAmount);
	}
	new winner = ObjectiveWinner(g_tickets[1], g_tickets[2]);
	if (winner == OBJ_NO_WINNER && g_timeLimit > 0.0 && g_activeTime >= g_timeLimit)
		winner = g_tickets[1] == g_tickets[2] ? OBJ_DRAW : (g_tickets[1] > g_tickets[2] ? OBJ_TEAM_T : OBJ_TEAM_CT);
	if (winner != OBJ_NO_WINNER)
	{
		ObjectiveFinish(winner);
		return;
	}
	for (new id = 1; id <= g_maxPlayers; id++)
	{
		if (!is_user_connected(id))
			continue;
		if (is_user_alive(id))
			ObjectiveSettleDebt(id, false);
		else if (g_activeTime >= g_respawnAt[id])
			ObjectiveTryRespawn(id);
	}
	winner = ObjectiveWinner(g_tickets[1], g_tickets[2]);
	if (winner != OBJ_NO_WINNER)
		ObjectiveFinish(winner);
	else
		ObjectiveShowHud(now);
}

stock ObjectiveUpdatePoints(Float:delta)
{
	new step = floatround(delta * float(OBJ_CONTROL_MAX) / g_captureTime);
	for (new point; point < OBJ_MAX_POINTS; point++)
	{
		if (!g_pointPresent[point])
			continue;
		new occupants[3];
		for (new id = 1; id <= g_maxPlayers; id++)
		{
			g_inside[point][id] = false;
			if (!is_user_alive(id))
				continue;
			new team = get_member(id, m_iTeam);
			if (team != OBJ_TEAM_T && team != OBJ_TEAM_CT)
				continue;
			new Float:origin[3];
			pev(id, pev_origin, origin);
			if (get_distance_f(origin, g_pointOrigin[point]) > g_pointRadius[point])
				continue;
			new Float:eye[3], Float:target[3];
			pev(id, pev_view_ofs, eye);
			for (new axis; axis < 3; axis++)
			{
				eye[axis] += origin[axis];
				target[axis] = g_pointOrigin[point][axis];
			}
			target[2] += 16.0;
			engfunc(EngFunc_TraceLine, eye, target, IGNORE_MONSTERS, id, g_trace);
			new Float:fraction;
			get_tr2(g_trace, TR_flFraction, fraction);
			if (fraction < 1.0)
				continue;
			g_inside[point][id] = true;
			occupants[team]++;
		}
		g_pointContested[point] = ObjectiveContested(g_points[point][OBJ_OWNER], occupants[1], occupants[2]);
		new event = ObjectiveAdvance(g_points[point], occupants[1], occupants[2], step);
		if (event == OBJ_EVENT_CAPTURED)
		{
			new owner = g_points[point][OBJ_OWNER], ignored;
			for (new id = 1; id <= g_maxPlayers; id++)
				if (g_inside[point][id] && is_user_alive(id) && get_member(id, m_iTeam) == owner)
					ExecuteForward(g_captureForward, ignored, id, point, owner);
		}
		new entity = g_pointEntity[point];
		if (pev_valid(entity))
		{
			switch (g_points[point][OBJ_OWNER])
			{
				case OBJ_TEAM_T: set_pev(entity, pev_rendercolor, Float:{255.0, 80.0, 60.0});
				case OBJ_TEAM_CT: set_pev(entity, pev_rendercolor, Float:{60.0, 160.0, 255.0});
				default: set_pev(entity, pev_rendercolor, Float:{220.0, 220.0, 220.0});
			}
		}
	}
}

stock ObjectiveDeploymentTeam(id)
{
	// Spawn-pre applies the reserved class/team; choose a matching destination before respawning.
	new BF4_TEAM:reserved = BF4GetUserTeam(id, true);
	return reserved == BF4_TEAM_RU ? OBJ_TEAM_T : (reserved == BF4_TEAM_US ? OBJ_TEAM_CT : 0);
}

stock bool:ObjectiveSafeSpawn(id, const Float:origin[3])
{
	engfunc(EngFunc_TraceHull, origin, origin, DONT_IGNORE_MONSTERS, HULL_HUMAN, id, g_trace);
	if (get_tr2(g_trace, TR_StartSolid) || get_tr2(g_trace, TR_AllSolid))
		return false;
	new team = ObjectiveDeploymentTeam(id);
	for (new other = 1; other <= g_maxPlayers; other++)
	{
		if (other == id || !is_user_alive(other))
			continue;
		new Float:position[3];
		pev(other, pev_origin, position);
		new Float:distance = get_distance_f(origin, position);
		if (distance < 64.0 || (get_member(other, m_iTeam) != team && distance < 256.0))
			return false;
	}
	return true;
}

stock bool:ObjectiveFindSpawn(id)
{
	new team = ObjectiveDeploymentTeam(id), start = random_num(0, g_spawnCount - 1);
	if (!team)
		return false;
	for (new offset; offset < g_spawnCount; offset++)
	{
		new index = (start + offset) % g_spawnCount, reference = g_spawns[index][SPAWN_POINT];
		if ((g_spawns[index][SPAWN_TEAM] && g_spawns[index][SPAWN_TEAM] != team) || reference != g_spawnSelection[id])
			continue;
		new owner = reference ? g_points[reference - 1][OBJ_OWNER] : 0;
		new bool:contested = reference ? g_pointContested[reference - 1] : false;
		if (!ObjectiveSpawnAllowed(g_mode, team, reference, owner, contested) || !ObjectiveSafeSpawn(id, g_spawns[index][SPAWN_ORIGIN]))
			continue;
		for (new axis; axis < 3; axis++)
			g_deployOrigin[id][axis] = g_spawns[index][SPAWN_ORIGIN][axis];
		g_deployYaw[id] = g_spawns[index][SPAWN_YAW];
		return true;
	}
	return false;
}

stock ObjectiveTryRespawn(id)
{
	new team = get_member(id, m_iTeam);
	if ((team != OBJ_TEAM_T && team != OBJ_TEAM_CT) || get_member(id, m_iJoiningState) != JOINED || !ObjectiveFindSpawn(id))
		return;
	g_isRedeploying[id] = true;
	ExecuteHamB(Ham_CS_RoundRespawn, id);
	g_isRedeploying[id] = false;
}

stock bool:ObjectivePublishMatch(winner)
{
	if (g_matchState != MATCH_RUNNING && g_matchState != MATCH_PAUSED)
		return false;
	g_matchState = MATCH_ENDED; // Latch before notifying consumers that could call back.
	new ignored;
	ExecuteForward(g_matchForward, ignored, g_mode, winner);
	return true;
}

stock ObjectiveFinish(winner)
{
	if (!ObjectivePublishMatch(winner))
		return;
	client_print(0, print_chat, "[BF4] Match ended. Winner: %s (T %d / CT %d)",
		winner == OBJ_TEAM_T ? "T" : (winner == OBJ_TEAM_CT ? "CT" : "DRAW"), g_tickets[1], g_tickets[2]);
	ObjectiveReleaseControl();
	for (new id = 1; id <= g_maxPlayers; id++)
		ObjectiveClearPlayer(id);
	switch (winner)
	{
		case OBJ_TEAM_T: rg_round_end(5.0, WINSTATUS_TERRORISTS, ROUND_TERRORISTS_WIN);
		case OBJ_TEAM_CT: rg_round_end(5.0, WINSTATUS_CTS, ROUND_CTS_WIN);
		default: rg_round_end(5.0, WINSTATUS_DRAW, ROUND_END_DRAW);
	}
}

stock ObjectiveShowHud(Float:now)
{
	if (now < g_nextHud)
		return;
	g_nextHud = now + 1.0;
	new text[768], used;
	used = formatex(text, charsmax(text), "%s | T %d : %d CT%s^n",
		g_mode == OBJ_MODE_DOMINATION ? "DOMINATION" : "CONQUEST", g_tickets[1], g_tickets[2],
		g_matchState == MATCH_WAITING || g_matchState == MATCH_PAUSED ? " | WAITING" : "");
	for (new point; point < OBJ_MAX_POINTS; point++)
	{
		if (!g_pointPresent[point])
			continue;
		ObjectiveDrawRing(point);
		new progress = g_points[point][OBJ_PROGRESS];
		if (progress < 0)
			progress = -progress;
		used += formatex(text[used], charsmax(text) - used, "%c: %s %d%%%s^n", 'A' + point,
			g_points[point][OBJ_OWNER] == 1 ? "T" : (g_points[point][OBJ_OWNER] == 2 ? "CT" : "NEUTRAL"),
			progress / 100, g_pointContested[point] ? " CONTESTED" : "");
	}
	set_hudmessage(220, 220, 220, 0.02, 0.16, 0, 0.0, 1.1, 0.0, 0.0);
	ShowSyncHudMsg(0, g_hud, "%s", text);
}

stock ObjectiveDrawRing(point)
{
	new owner = g_points[point][OBJ_OWNER];
	new red = owner == OBJ_TEAM_CT ? 60 : 220;
	new green = owner == OBJ_TEAM_T ? 80 : 180;
	new blue = owner == OBJ_TEAM_T ? 60 : 255;
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, g_pointOrigin[point], 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, g_pointOrigin[point][0]);
	engfunc(EngFunc_WriteCoord, g_pointOrigin[point][1]);
	engfunc(EngFunc_WriteCoord, g_pointOrigin[point][2] - 28.0);
	engfunc(EngFunc_WriteCoord, g_pointOrigin[point][0]);
	engfunc(EngFunc_WriteCoord, g_pointOrigin[point][1]);
	engfunc(EngFunc_WriteCoord, g_pointOrigin[point][2] - 28.0 + g_pointRadius[point]);
	write_short(g_ringSprite);
	write_byte(0);
	write_byte(0);
	write_byte(12);
	write_byte(3);
	write_byte(0);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(120);
	write_byte(0);
	message_end();
}

public ObjectiveDeployMenu(id)
{
	if (!g_layoutReady || g_manuallyStopped || !is_user_connected(id) || is_user_alive(id))
		return PLUGIN_HANDLED;
	if (g_deployMenu[id] != -1)
		menu_destroy(g_deployMenu[id]);
	new menu = menu_create("BF4 Deployment", "ObjectiveDeploySelected");
	g_deployMenu[id] = menu;
	new info[32], caption[48], team = ObjectiveDeploymentTeam(id);
	formatex(info, charsmax(info), "%d 0", g_connectionGeneration[id]);
	menu_additem(menu, "Base / map spawn", info);
	if (g_mode == OBJ_MODE_CONQUEST)
	{
		for (new point; point < OBJ_MAX_POINTS; point++)
		{
			if (!g_pointPresent[point] || g_points[point][OBJ_OWNER] != team || g_pointContested[point])
				continue;
			new bool:hasSpawn;
			for (new i; i < g_spawnCount; i++)
				if (g_spawns[i][SPAWN_POINT] == point + 1 && (!g_spawns[i][SPAWN_TEAM] || g_spawns[i][SPAWN_TEAM] == team))
					hasSpawn = true;
			if (!hasSpawn)
				continue;
			formatex(caption, charsmax(caption), "Point %c", 'A' + point);
			formatex(info, charsmax(info), "%d %d", g_connectionGeneration[id], point + 1);
			menu_additem(menu, caption, info);
		}
	}
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public ObjectiveDeploySelected(id, menu, item)
{
	if (id < 1 || id > g_maxPlayers || g_deployMenu[id] != menu)
		return PLUGIN_HANDLED;
	g_deployMenu[id] = -1;
	if (item < 0 || !is_user_connected(id) || is_user_alive(id) || !g_hasControl)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new info[32], name[48], access, callback, generation[16], selection[8];
	menu_item_getinfo(menu, item, access, info, charsmax(info), name, charsmax(name), callback);
	parse(info, generation, charsmax(generation), selection, charsmax(selection));
	new reference = str_to_num(selection);
	if (str_to_num(generation) == g_connectionGeneration[id] && reference >= 0 && reference <= OBJ_MAX_POINTS)
		g_spawnSelection[id] = reference;
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public CommandStart(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;
	if (!g_layoutReady)
	{
		console_print(id, "[BF4] No valid layout/settings. Correct configuration and reload the map.");
		return PLUGIN_HANDLED;
	}
	g_manuallyStopped = false;
	ObjectiveResetMatch();
	// Clear existing planted bombs, arming animations and other standard-round state atomically.
	rg_restart_round();
	console_print(id, "[BF4] Match reset; waiting for both teams.");
	return PLUGIN_HANDLED;
}

public CommandStop(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;
	g_manuallyStopped = true;
	g_matchState = MATCH_STOPPED;
	ObjectiveReleaseControl();
	for (new player = 1; player <= g_maxPlayers; player++)
		ObjectiveClearPlayer(player);
	console_print(id, "[BF4] Stopped; standard map objectives restored.");
	return PLUGIN_HANDLED;
}

public CommandStatus(id, level, cid)
{
	if (cmd_access(id, level, cid, 1))
		console_print(id, "[BF4] mode=%d state=%d layout=%d points=%d spawns=%d T=%d CT=%d elapsed=%.1f",
			g_mode, g_matchState, g_layoutReady, g_pointCount, g_spawnCount, g_tickets[1], g_tickets[2], g_activeTime);
	return PLUGIN_HANDLED;
}

public CommandOrigin(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1) || !id || !is_user_alive(id))
		return PLUGIN_HANDLED;
	new Float:origin[3], Float:angles[3];
	pev(id, pev_origin, origin);
	pev(id, pev_v_angle, angles);
	console_print(id, "[BF4] x=%d y=%d z=%d yaw=%d (standing player origin)",
		floatround(origin[0]), floatround(origin[1]), floatround(origin[2]), floatround(angles[1]));
	return PLUGIN_HANDLED;
}

public NativeAPIVersion(plugin, params)
{
	return 1;
}

public NativeMode(plugin, params)
{
	return g_mode;
}

public NativeRunning(plugin, params)
{
	return g_matchState == MATCH_RUNNING;
}
public NativeTickets(plugin, params)
{
	if (params < 1)
		return -1;
	new team = get_param(1);
	return team == OBJ_TEAM_T || team == OBJ_TEAM_CT ? g_tickets[team] : -1;
}

public plugin_end()
{
	remove_task(TASK_OBJECTIVES);
	ObjectiveReleaseControl();
	for (new id = 1; id <= g_maxPlayers; id++)
		ObjectiveClearPlayer(id);
	for (new point; point < OBJ_MAX_POINTS; point++)
		if (pev_valid(g_pointEntity[point]))
			engfunc(EngFunc_RemoveEntity, g_pointEntity[point]);
	DestroyForward(g_captureForward);
	DestroyForward(g_matchForward);
	free_tr2(g_trace);
}
