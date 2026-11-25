#include <bf4/progression_math>
new bool:g_isAwardUpdateInProgress[MAX_PLAYERS + 1];
new const g_awardKeys[19][] = {
	"marksman", "headshot", "pistol", "assault", "sniper",
	"lmg", "dmr", "smg", "shotgun", "melee",
	"assist", "avenger", "savior", "mvp", "medikit",
	"ammobox", "revive", "ctf_capture", "ctf_win"};

stock bool:ProgressionEligible(id)
{
	return id >= 1 && id <= g_maxPlayers && is_user_connected(id) && g_playerReady[id] &&
		   (!g_ignoreBots || !is_user_bot(id)) && !is_user_hltv(id) &&
		   (!g_teamLock || get_user_team(id) == g_teamLock) && get_playersnum() >= g_ready_players;
}

stock ProgressionLevel(id)
{
	new low, high = ArraySize(g_rankXP) - 1;
	while (low < high)
	{
		new middle = (low + high + 1) / 2;
		if (g_xp[id] >= ArrayGetCell(g_rankXP, middle))
			low = middle;
		else
			high = middle - 1;
	}
	return low;
}

stock bool:ProgressionGiveXP(id, amount)
{
	if (!ProgressionEligible(id))
		return false;
	new oldLevel = ProgressionLevel(id), oldXP = g_xp[id];
	g_xp[id] = ProgressionClampXP(oldXP, amount);
	if (g_xp[id] == oldXP)
		return true;
	if (!g_isAwardUpdateInProgress[id])
		StoreCapture(id);
	new newLevel = ProgressionLevel(id);
	if (newLevel != oldLevel)
		ProgressionLevelEffect(id, newLevel, newLevel > oldLevel);
	ProgressionNotifyXP(id, g_xp[id] - oldXP);
	return true;
}

stock ProgressionRecordAward(id, ribbon, const info[] = "", bool:grantPoints = true)
{
	if (ribbon < 0 || ribbon >= BF4_RNK_MAX || !ProgressionEligible(id) || is_user_bot(id))
		return false;
	if (g_awardEventCounts[id][ribbon] == 2147483647)
		return false;
	g_isAwardUpdateInProgress[id] = true;
	g_awardEventCounts[id][ribbon]++;
	if (info[0] && grantPoints && g_awardEventXP[ribbon])
		client_print(id, print_chat, "+%d %s", g_awardEventXP[ribbon], info);
	if (grantPoints && g_awardEventXP[ribbon])
		ProgressionGiveXP(id, g_awardEventXP[ribbon]);
	if (g_awardEventCounts[id][ribbon] % g_ribbonDefinitions[ribbon][AWARD_REQUIRED_COUNT] == 0)
	{
		ProgressionGiveXP(id, g_ribbonDefinitions[ribbon][AWARD_XP_REWARD]);
		if (ArraySize(g_awardDisplayQueue[id]) < 32)
			ArrayPushArray(g_awardDisplayQueue[id], g_ribbonDefinitions[ribbon]);
		if (g_earnedRibbonCounts[id][ribbon] == 2147483647)
		{
			g_isAwardUpdateInProgress[id] = false;
			StoreCapture(id);
			return true;
		}
		g_earnedRibbonCounts[id][ribbon]++;
		if (g_earnedRibbonCounts[id][ribbon] % g_medalDefinitions[ribbon][AWARD_REQUIRED_COUNT] == 0)
		{
			ProgressionGiveXP(id, g_medalDefinitions[ribbon][AWARD_XP_REWARD]);
			if (ArraySize(g_awardDisplayQueue[id]) < 32)
				ArrayPushArray(g_awardDisplayQueue[id], g_medalDefinitions[ribbon]);
		}
	}
	g_isAwardUpdateInProgress[id] = false;
	StoreCapture(id);
	return true;
}

stock ProgressionReward(id, const event[])
{
	return ProgressionGiveXP(id, RewardValue(id, event));
}

public ProgressionXPCommand(id)
{
	if (!g_playerReady[id])
	{
		client_print(id, print_chat, "[BF4Ranks] Progression is loading/unavailable.");
		return PLUGIN_HANDLED;
	}
	new name[64];
	ArrayGetString(g_rankNames, ProgressionLevel(id), name, charsmax(name));
	client_print(id, print_chat, "[BF4Ranks] XP: %d | Level %d: %s", g_xp[id], ProgressionLevel(id) + 1, name);
	return PLUGIN_HANDLED;
}

public ProgressionPlanted(id)
{
	ProgressionReward(id, "bomb_planted");
}
public ProgressionDefused(id)
{
	ProgressionReward(id, "bomb_defused");
}
public ProgressionBombed()
{
	new id = get_loguser_index();
	if (id)
		ProgressionReward(id, "bomb_exploded");
}

stock get_loguser_index()
{
	new loguser[128], name[32];
	read_logargv(0, loguser, charsmax(loguser));
	parse_loguser(loguser, name, charsmax(name));
	return get_user_index(name);
}

public NativeProgressionReady(plugin, params)
{
	new id = get_param(1);
	return id > 0 && id <= g_maxPlayers && g_playerReady[id];
}
public NativeProgressionXP(plugin, params)
{
	new id = get_param(1);
	return id > 0 && id <= g_maxPlayers && g_playerReady[id] ? g_xp[id] : -1;
}
public NativeProgressionGive(plugin, params)
{
	return ProgressionGiveXP(get_param(1), get_param(2));
}
public NativeProgressionLevel(plugin, params)
{
	new id = get_param(1);
	return id > 0 && id <= g_maxPlayers && g_playerReady[id] ? ProgressionLevel(id) + 1 : -1;
}
public NativeProgressionRank(plugin, params)
{
	new id = get_param(1), name[64];
	if (id < 1 || id > g_maxPlayers || !g_playerReady[id])
		return 0;
	ArrayGetString(g_rankNames, ProgressionLevel(id), name, charsmax(name));
	return set_string(2, name, get_param(3));
}
public NativeProgressionAward(plugin, params)
{
	new key[32], caption[64];
	get_string(2, key, charsmax(key));
	get_string(3, caption, charsmax(caption));
	for (new i; i < sizeof g_awardKeys; i++)
		if (equal(key, g_awardKeys[i]))
			return ProgressionRecordAward(get_param(1), i, caption);
	return false;
}

stock ProgressionApplyFlags(id)
{
	if (!g_playerReady[id] || ProgressionLevel(id) != ArraySize(g_rankXP) - 1)
		return;
	new flags[32];
	ConfigString("FINAL_LEVEL_FLAGS", flags, charsmax(flags));
	if (flags[0])
		set_user_flags(id, read_flags(flags));
}

public amxbans_admin_connect(id)
{
	ProgressionApplyFlags(id);
}
