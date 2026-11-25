// Configuration is read before assets are precached. Existing values remain authoritative.
new Trie:g_settings, Trie:g_rewards;
new Array:g_rankNames, Array:g_rankXP;
new g_saveType, g_saveInterval, g_teamLock, g_ignoreBots, g_combined, g_vipFlags;

stock ConfigString(const key[], value[], length, const fallback[] = "")
{
	if (!TrieGetString(g_settings, key, value, length))
		copy(value, length, fallback);
}

stock ConfigNumber(const key[], fallback = 0)
{
	new value[32];
	if (!TrieGetString(g_settings, key, value, charsmax(value)))
		return fallback;
	return str_to_num(value);
}

stock ConfigLoad()
{
	g_settings = TrieCreate();
	g_rewards = TrieCreate();
	g_rankNames = ArrayCreate(64);
	g_rankXP = ArrayCreate();
	new path[256];
	get_configsdir(path, charsmax(path));
	add(path, charsmax(path), "/RankSystem.ini");
	new file = fopen(path, "rt");
	if (!file)
	{
		set_fail_state("Cannot open RankSystem.ini");
		return;
	}
	new line[512], key[128], value[384], section, map[64], selector[64];
	new bool:active = true;
	get_mapname(map, charsmax(map));
	while (!feof(file))
	{
		fgets(file, line, charsmax(line));
		trim(line);
		if (!line[0] || line[0] == '#' || line[0] == ';')
			continue;
		if (line[0] == '-')
		{
			copy(selector, charsmax(selector), line[1]);
			new end = strlen(selector) - 1;
			if (end >= 0 && selector[end] == '-')
				selector[end] = 0;
			trim(selector);
			end = strlen(selector) - 1;
			active = equal(selector, "#all") || equali(selector, map);
			if (end >= 0 && selector[end] == '*')
			{
				selector[end] = 0;
				active = equali(selector, map, end) != 0;
			}
			continue;
		}
		if (!active)
			continue;
		if (line[0] == '[')
		{
			if (equali(line, "[Settings]"))
				section = 1;
			else if (equali(line, "[Ranks]"))
				section = 2;
			else if (equali(line, "[XP Rewards]"))
				section = 3;
			else
				section = 0;
			continue;
		}
		strtok(line, key, charsmax(key), value, charsmax(value), '=');
		trim(key);
		trim(value);
		if (!key[0])
			continue;
		switch (section)
		{
			case 1:
				TrieSetString(g_settings, key, value);
			case 2:
			{
				new xp = str_to_num(value), size = ArraySize(g_rankXP);
				if (xp < 0 || (!size && xp != 0) || (size && xp <= ArrayGetCell(g_rankXP, size - 1)))
				{
					fclose(file);
					set_fail_state("Ranks must start at zero and increase strictly");
					return;
				}
				ArrayPushString(g_rankNames, key);
				ArrayPushCell(g_rankXP, xp);
			}
			case 3:
			{
				new normal[24], vip[24], reward[2];
				parse(value, normal, charsmax(normal), vip, charsmax(vip));
				reward[0] = str_to_num(normal);
				reward[1] = vip[0] ? str_to_num(vip) : reward[0];
				TrieSetArray(g_rewards, key, reward, sizeof reward);
			}
		}
	}
	fclose(file);
	if (!ArraySize(g_rankXP))
	{
		set_fail_state("No ranks configured");
		return;
	}
	g_saveType = ConfigNumber("SAVE_TYPE", 2);
	g_saveInterval = ConfigNumber("SAVE_INTERVAL");
	g_teamLock = ConfigNumber("TEAM_LOCK");
	g_ignoreBots = ConfigNumber("IGNORE_BOTS");
	g_combined = ConfigNumber("USE_COMBINED_EVENTS", 1);
	g_ready_players = ConfigNumber("MINIMUM_PLAYERS");
	ConfigString("VIP_FLAGS", value, charsmax(value));
	g_vipFlags = read_flags(value);
	ConfigString("CHAT_PREFIX", g_ChatPrefix, charsmax(g_ChatPrefix), "[BF4Ranks]");
	ConfigString("LEVELUP_SOUND", value, charsmax(value));
	if (value[0])
		precache_sound(value);
	ConfigString("LEVELDN_SOUND", value, charsmax(value));
	if (value[0])
		precache_sound(value);
}

stock RewardValue(id, const event[])
{
	new reward[2];
	if (!TrieGetArray(g_rewards, event, reward, sizeof reward))
		return 0;
	return reward[g_vipFlags != 0 && (get_user_flags(id) & g_vipFlags) == g_vipFlags];
}

stock bool:HasReward(const event[])
{
	return TrieKeyExists(g_rewards, event);
}
