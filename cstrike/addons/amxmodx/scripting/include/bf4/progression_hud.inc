stock ProgressionColor(const setting[], color[3])
{
	new value[64], r[12], g[12], b[12];
	ConfigString(setting, value, charsmax(value), "255 255 255");
	parse(value, r, charsmax(r), g, charsmax(g), b, charsmax(b));
	color[0] = str_to_num(r);
	color[1] = str_to_num(g);
	color[2] = str_to_num(b);
	for (new i; i < 3; i++)
		color[i] = color[i] == -1 ? random_num(0, 255) : clamp(color[i], 0, 255);
}

stock ProgressionPosition(const setting[], &Float:x, &Float:y, const fallback[] = "0.01 0.9")
{
	new value[64], sx[24], sy[24];
	ConfigString(setting, value, charsmax(value), fallback);
	if (!value[0])
		copy(value, charsmax(value), fallback);
	parse(value, sx, charsmax(sx), sy, charsmax(sy));
	x = str_to_float(sx);
	y = str_to_float(sy);
}

stock ProgressionNotifyXP(id, amount)
{
	if (!ConfigNumber("XP_NOTIFIER_ENABLED", 1))
		return;
	new color[3], value[32];
	new Float:x, Float:y;
	ProgressionColor(amount >= 0 ? "XP_NOTIFIER_COLOR_GET" : "XP_NOTIFIER_COLOR_LOSE", color);
	ProgressionPosition("XP_NOTIFIER_POSITION", x, y, "0.8 0.8");
	ConfigString("XP_NOTIFIER_DURATION", value, charsmax(value), "1.5");
	if (ConfigNumber("XP_NOTIFIER_USE_DHUD", 1))
	{
		set_dhudmessage(color[0], color[1], color[2], x, y, 0, 0.0, str_to_float(value));
		show_dhudmessage(id, "%s%d XP", amount >= 0 ? "+" : "",
						 amount);
	}
	else
	{
		set_hudmessage(color[0], color[1], color[2], x, y, 0, 0.0, str_to_float(value), .channel = 3);
		show_hudmessage(id, "%s%d XP", amount >= 0 ? "+" : "", amount);
	}
}

stock ProgressionLevelEffect(id, level, bool:up)
{
	new sound[128], rank[64];
	ConfigString(up ? "LEVELUP_SOUND" : "LEVELDN_SOUND", sound, charsmax(sound));
	if (sound[0])
		client_cmd(id, "spk ^"%s^"", sound);
	ArrayGetString(g_rankNames, level, rank, charsmax(rank));
	new type = ConfigNumber("LEVELUP_MESSAGE_TYPE", 1);
	if (type)
		client_print(type == 2 ? 0 : id, print_chat, "[BF4Ranks] Level %d: %s", level + 1, rank);
	if (level == ArraySize(g_rankXP) - 1)
	{
		new flags[32];
		ConfigString("FINAL_LEVEL_FLAGS", flags, charsmax(flags));
		if (flags[0])
			set_user_flags(id, read_flags(flags));
	}
	if (ConfigNumber(up ? "LEVELUP_SCREEN_FADE_ENABLED" : "LEVELDN_SCREEN_FADE_ENABLED"))
	{
		new color[3], alpha[64], r[12], g[12], b[12], a[12];
		ProgressionColor(up ? "LEVELUP_SCREEN_FADE_COLOR" : "LEVELDN_SCREEN_FADE_COLOR", color);
		ConfigString(up ? "LEVELUP_SCREEN_FADE_COLOR" : "LEVELDN_SCREEN_FADE_COLOR", alpha, charsmax(alpha), "0 255 0 75");
		parse(alpha, r, charsmax(r), g, charsmax(g), b, charsmax(b), a, charsmax(a));
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), .player = id);
		write_short(1 << 12);
		write_short(1 << 12);
		write_short(0);
		write_byte(color[0]);
		write_byte(color[1]);
		write_byte(color[2]);
		write_byte(clamp(str_to_num(a), 0, 255));
		message_end();
	}
}

public ProgressionHUD()
{
	if (!ConfigNumber("HUDINFO_ENABLED", 1))
		return;
	for (new id = 1; id <= g_maxPlayers; id++)
	{
		if (!is_user_connected(id) || is_user_bot(id) || !g_playerReady[id])
			continue;
		new bool:alive = is_user_alive(id) != 0;
		new visibility = ConfigNumber("HUDINFO_VISIBILITY");
		if ((visibility == 1 && !alive) || (visibility == 2 && alive) ||
			(visibility == 3 && alive && !get_member_game(m_bFreezePeriod)))
			continue;
		new target = id;
		if (!alive && ConfigNumber("HUDINFO_OTHER_PLAYERS"))
		{
			new watched = pev(id, pev_iuser2);
			if (watched > 0 && watched <= g_maxPlayers && g_playerReady[watched])
				target = watched;
		}
		if (g_teamLock && ConfigNumber("HUDINFO_TEAM_LOCK", 1) && get_user_team(target) != g_teamLock)
			continue;
		new level = ProgressionLevel(target), last = ArraySize(g_rankXP) - 1, text[256], rank[64], number[24];
		ConfigString(level == last ? "HUDINFO_FORMAT_FINAL" : "HUDINFO_FORMAT", text, charsmax(text),
					 "[ XP: $current_xp$ | Level $level$: $rank$ ]");
		ArrayGetString(g_rankNames, level, rank, charsmax(rank));
		replace_all(text, charsmax(text), "$rank$", rank);
		num_to_str(g_xp[target], number, charsmax(number));
		replace_all(text, charsmax(text), "$current_xp$", number);
		num_to_str(level == last ? g_xp[target] : ArrayGetCell(g_rankXP, level + 1), number, charsmax(number));
		replace_all(text, charsmax(text), "$next_xp$", number);
		num_to_str(level + 1, number, charsmax(number));
		replace_all(text, charsmax(text), "$level$", number);
		num_to_str(last + 1, number, charsmax(number));
		replace_all(text, charsmax(text), "$max_levels$", number);
		new color[3];
		new Float:x, Float:y;
		ProgressionColor("HUDINFO_COLOR", color);
		new fallback[64];
		ConfigString("HUDINFO_POSITION", fallback, charsmax(fallback), "0.01 0.9");
		ProgressionPosition(alive ? "HUDINFO_POSITION" : "HUDINFO_POSITION_DEAD", x, y, fallback);
		if (ConfigNumber("HUDINFO_USE_DHUD"))
		{
			set_dhudmessage(color[0], color[1], color[2], x, y, 0, 0.0, 1.0);
			show_dhudmessage(id, "%s", text);
		}
		else
		{
			set_hudmessage(color[0], color[1], color[2], x, y, 0, 0.0, 1.0, .channel = 4);
			show_hudmessage(id, "%s", text);
		}
	}
}
