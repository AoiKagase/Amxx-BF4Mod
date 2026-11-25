// One record per identity, not per slot. Records survive disconnect and async writes.
#include <bf4/progression_snapshot>
new Array:g_progressionRecords;
new g_playerRecordIndex[MAX_PLAYERS + 1], g_playerSessionGeneration[MAX_PLAYERS + 1];
new bool:g_isStorageReady;
new Handle:g_sqlConnectionTuple = Empty_Handle;
new g_progressionVault = INVALID_HANDLE, g_pendingSaveJournal = INVALID_HANDLE;
new bool:g_isSqlStorageEnabled, bool:g_isSchemaRequestPending;
new Float:g_nextSchemaRetryTime;
new g_pendingSaveKeyIndexPath[256];

stock StoreFind(const key[])
{
	new record[StoreRecord];
	for (new i; i < ArraySize(g_progressionRecords); i++)
	{
		ArrayGetArray(g_progressionRecords, i, record);
		if (equal(record[SR_PLAYER_KEY], key))
			return i;
	}
	return -1;
}

stock StoreAdd(const key[])
{
	new record[StoreRecord];
	copy(record[SR_PLAYER_KEY], 64, key);
	return ArrayPushArray(g_progressionRecords, record);
}

stock StoreEncode(const record[StoreRecord], output[], length, bool:csv = false)
{
	new used;
	if (!csv)
		used = formatex(output, length, "2 %d %d", record[SR_TOTAL_XP], record[SR_REVISION]);
	for (new i; i < STORE_VALUES; i++)
		used += formatex(output[used], length - used, "%s%d",
						 csv ? (i ? "," : "") : " ",
						 record[SR_AWARD_COUNTS + i]);
}

stock StoreJournal(index)
{
	new record[StoreRecord], text[STORE_TEXT];
	ArrayGetArray(g_progressionRecords, index, record);
	StoreEncode(record, text, charsmax(text));
	new previous[STORE_TEXT], stamp;
	if (!nvault_lookup(g_pendingSaveJournal, record[SR_PLAYER_KEY], previous, charsmax(previous), stamp))
	{
		new file = fopen(g_pendingSaveKeyIndexPath, "at");
		if (!file)
		{
			set_fail_state("Cannot persist SQL recovery index");
			return;
		}
		fprintf(file, "%s^n", record[SR_PLAYER_KEY]);
		fclose(file);
	}
	if (!nvault_set(g_pendingSaveJournal, record[SR_PLAYER_KEY], text))
		set_fail_state("Cannot persist SQL recovery journal");
}

stock StoreInit()
{
	g_progressionRecords = ArrayCreate(StoreRecord);
	for (new id; id <= MAX_PLAYERS; id++)
		g_playerRecordIndex[id] = -1;
	g_isSqlStorageEnabled = ConfigNumber("USE_MYSQL") != 0;
	if (!g_isSqlStorageEnabled)
	{
		g_progressionVault = nvault_open("BF4Ranks_v2");
		if (g_progressionVault == INVALID_HANDLE)
		{
			set_fail_state("Cannot open BF4Ranks_v2");
			return;
		}
		g_isStorageReady = true;
		return;
	}
	g_pendingSaveJournal = nvault_open("BF4Ranks_v2_pending");
	if (g_pendingSaveJournal == INVALID_HANDLE)
	{
		set_fail_state("Cannot open SQL recovery journal");
		return;
	}
	get_datadir(g_pendingSaveKeyIndexPath, charsmax(g_pendingSaveKeyIndexPath));
	add(g_pendingSaveKeyIndexPath, charsmax(g_pendingSaveKeyIndexPath), "/bf4_progression_v2_pending.keys");
	new file = fopen(g_pendingSaveKeyIndexPath, "rt"), key[65], text[STORE_TEXT], stamp;
	if (file)
	{
		while (!feof(file))
		{
			new line[128];
			fgets(file, line, charsmax(line));
			new length = strlen(line);
			while (length && (line[length - 1] == 10 || line[length - 1] == 13))
				line[--length] = 0;
			copy(key, charsmax(key), line);
			if (!key[0] || StoreFind(key) != -1 ||
				!nvault_lookup(g_pendingSaveJournal, key, text, charsmax(text), stamp))
				continue;
			new record[StoreRecord];
			copy(record[SR_PLAYER_KEY], 64, key);
			if (!StoreDecode(text, record))
			{
				fclose(file);
				set_fail_state("Invalid SQL recovery snapshot");
				return;
			}
			record[SR_IS_LOADED] = record[SR_HAS_UNSAVED_CHANGES] = true;
			ArrayPushArray(g_progressionRecords, record);
		}
		fclose(file);
	}
	new host[128], user[128], pass[128], database[128];
	ConfigString("SQL_HOST", host, charsmax(host));
	ConfigString("SQL_USER", user, charsmax(user));
	ConfigString("SQL_PASSWORD", pass, charsmax(pass));
	ConfigString("SQL_DATABASE", database, charsmax(database));
	g_sqlConnectionTuple = SQL_MakeDbTuple(host, user, pass, database);
	StoreRequestSchema();
}

stock StoreRequestSchema()
{
	if (g_isSchemaRequestPending || get_gametime() < g_nextSchemaRetryTime)
		return;
	g_isSchemaRequestPending = true;
	SQL_ThreadQuery(g_sqlConnectionTuple, "StoreSchemaResult", "CREATE TABLE IF NOT EXISTS bf4_progression_v2 (player_key VARBINARY(64) PRIMARY KEY,xp INT NOT NULL,counters TEXT NOT NULL,revision INT NOT NULL,schema_version INT NOT NULL)");
}

public StoreSchemaResult(failstate, Handle:query, error[], errnum, data[], size, Float:duration)
{
	if (failstate != TQUERY_SUCCESS)
	{
		g_isSchemaRequestPending = false;
		g_nextSchemaRetryTime = get_gametime() + 30.0;
		log_amx("Progression SQL schema unavailable; retry in 30 seconds: %s", error);
		return;
	}
	SQL_ThreadQuery(g_sqlConnectionTuple, "StoreSchemaChecked", "SHOW COLUMNS FROM bf4_progression_v2 LIKE 'player_key'");
}

public StoreSchemaChecked(failstate, Handle:query, error[], errnum, data[], size, Float:duration)
{
	g_isSchemaRequestPending = false;
	if (failstate != TQUERY_SUCCESS)
	{
		g_nextSchemaRetryTime = get_gametime() + 30.0;
		log_amx("Cannot verify progression schema: %s", error);
		return;
	}
	new type[64];
	if (SQL_NumResults(query))
		SQL_ReadResult(query, 1, type, charsmax(type));
	if (!equali(type, "varbinary(64)"))
	{
		set_fail_state("Progression player_key must be VARBINARY(64); migrate schema before loading");
		return;
	}
	g_isStorageReady = true;
	StoreTick();
	for (new id = 1; id <= g_maxPlayers; id++)
		if (is_user_authorized(id) && !g_playerReady[id])
			StoreAttach(id);
}

stock bool:StoreIdentity(id, key[], length)
{
	new value[64];
	switch (g_saveType)
	{
		case 0:
		{
			get_user_name(id, value, charsmax(value));
			formatex(key, length, "nick:%s", value);
		}
		case 1:
		{
			get_user_ip(id, value, charsmax(value), 1);
			formatex(key, length, "ip:%s", value);
		}
		default:
		{
			get_user_authid(id, value, charsmax(value));
			if (!value[0] || equal(value, "STEAM_ID_PENDING") || equal(value, "VALVE_ID_PENDING"))
				return false;
			// Bots do not share the common BOT identity.
			if (is_user_bot(id))
			{
				get_user_name(id, value, charsmax(value));
				formatex(key, length, "bot:%s", value);
			}
			else
				formatex(key, length, "steam:%s", value);
		}
	}
	return SnapshotKeyValid(key);
}

stock StoreAttach(id)
{
	if (!g_isStorageReady || g_isImportInProgress || !is_user_authorized(id))
		return;
	new key[65];
	if (!StoreIdentity(id, key, charsmax(key)))
		return;
	new index = StoreFind(key);
	if (index == -1)
		index = StoreAdd(key);
	for (new other = 1; other <= g_maxPlayers; other++)
		if (other != id && is_user_connected(other) && g_playerRecordIndex[other] == index)
		{
			log_amx("Duplicate progression identity refused for slot %d", id);
			return;
		}
	g_playerRecordIndex[id] = index;
	new record[StoreRecord];
	ArrayGetArray(g_progressionRecords, index, record);
	if (record[SR_IS_LOADED])
	{
		StoreRestore(id, record);
		return;
	}
	if (record[SR_IS_LOAD_PENDING])
		return;
	if (!g_isSqlStorageEnabled)
	{
		new text[STORE_TEXT], stamp;
		if (nvault_lookup(g_progressionVault, key, text, charsmax(text), stamp) && !StoreDecode(text, record))
		{
			log_amx("Invalid progression snapshot; identity remains read-only: %s", key);
			return;
		}
		record[SR_IS_LOADED] = true;
		ArraySetArray(g_progressionRecords, index, record);
		StoreRestore(id, record);
		return;
	}
	new escaped[132], sql[512], callback[1];
	StoreSQLKey(key, escaped, charsmax(escaped));
	formatex(sql, charsmax(sql), "SELECT xp,counters,revision,schema_version FROM bf4_progression_v2 WHERE player_key=%s", escaped);
	callback[0] = index;
	record[SR_IS_LOAD_PENDING] = true;
	ArraySetArray(g_progressionRecords, index, record);
	SQL_ThreadQuery(g_sqlConnectionTuple, "StoreLoadResult", sql, callback, sizeof callback);
}

public StoreLoadResult(failstate, Handle:query, error[], errnum, data[], size, Float:duration)
{
	new index = data[0], record[StoreRecord];
	ArrayGetArray(g_progressionRecords, index, record);
	record[SR_IS_LOAD_PENDING] = false;
	if (failstate != TQUERY_SUCCESS)
	{
		ArraySetArray(g_progressionRecords, index, record);
		log_amx("Progression load failed (no writes): %s", error);
		return;
	}
	if (SQL_NumResults(query))
	{
		new csv[STORE_TEXT], text[STORE_TEXT];
		SQL_ReadResult(query, 1, csv, charsmax(csv));
		replace_all(csv, charsmax(csv), ",", " ");
		formatex(text, charsmax(text), "%d %d %d %s", SQL_ReadResult(query, 3), SQL_ReadResult(query, 0),
				 SQL_ReadResult(query, 2), csv);
		if (!StoreDecode(text, record))
		{
			ArraySetArray(g_progressionRecords, index, record);
			log_amx("Invalid SQL progression snapshot");
			return;
		}
	}
	record[SR_IS_LOADED] = true;
	ArraySetArray(g_progressionRecords, index, record);
	for (new id = 1; id <= g_maxPlayers; id++)
		if (g_playerRecordIndex[id] == index && is_user_connected(id))
			StoreRestore(id, record);
}

stock StoreRestore(id, const record[StoreRecord])
{
	g_xp[id] = record[SR_TOTAL_XP];
	for (new i; i < BF4_RNK_MAX; i++)
	{
		g_awardEventCounts[id][i] = record[SR_AWARD_COUNTS + i];
		g_earnedRibbonCounts[id][i] = record[SR_AWARD_COUNTS + BF4_RNK_MAX + i];
	}
	g_playerReady[id] = true;
	ProgressionApplyFlags(id);
}

stock StoreCapture(id)
{
	if (!g_playerReady[id])
		return;
	new index = g_playerRecordIndex[id], record[StoreRecord];
	ArrayGetArray(g_progressionRecords, index, record);
	if (record[SR_REVISION] == 2147483647)
	{
		set_fail_state("Progression revision exhausted");
		return;
	}
	record[SR_TOTAL_XP] = g_xp[id];
	record[SR_REVISION]++;
	record[SR_HAS_UNSAVED_CHANGES] = true;
	for (new i; i < BF4_RNK_MAX; i++)
	{
		record[SR_AWARD_COUNTS + i] = g_awardEventCounts[id][i];
		record[SR_AWARD_COUNTS + BF4_RNK_MAX + i] = g_earnedRibbonCounts[id][i];
	}
	ArraySetArray(g_progressionRecords, index, record);
	if (g_isSqlStorageEnabled)
		// Journal the latest revision before scheduling its asynchronous SQL write.
		StoreJournal(index);
	if (g_saveInterval == 3)
		StoreFlush(index);
}

stock StoreFlush(index)
{
	new record[StoreRecord];
	ArrayGetArray(g_progressionRecords, index, record);
	if (!g_isStorageReady || !StoreCanFlush(record))
		return;
	new text[STORE_TEXT];
	StoreEncode(record, text, charsmax(text), g_isSqlStorageEnabled);
	if (!g_isSqlStorageEnabled)
	{
		if (nvault_set(g_progressionVault, record[SR_PLAYER_KEY], text))
		{
			record[SR_HAS_UNSAVED_CHANGES] = false;
			ArraySetArray(g_progressionRecords, index, record);
		}
		return;
	}
	new key[132], sql[1536], callback[2];
	StoreSQLKey(record[SR_PLAYER_KEY], key, charsmax(key));
	formatex(sql, charsmax(sql), "INSERT INTO bf4_progression_v2 (player_key,xp,counters,revision,schema_version) VALUES (%s,%d,'%s',%d,2) ON DUPLICATE KEY UPDATE xp=IF(revision<VALUES(revision),VALUES(xp),xp),counters=IF(revision<VALUES(revision),VALUES(counters),counters),schema_version=2,revision=GREATEST(revision,VALUES(revision))", key, record[SR_TOTAL_XP], text, record[SR_REVISION]);
	callback[0] = index;
	callback[1] = record[SR_REVISION];
	record[SR_IS_SAVE_PENDING] = true;
	ArraySetArray(g_progressionRecords, index, record);
	SQL_ThreadQuery(g_sqlConnectionTuple, "StoreWriteResult", sql, callback, sizeof callback);
}

public StoreWriteResult(failstate, Handle:query, error[], errnum, data[], size, Float:duration)
{
	new record[StoreRecord], index = data[0];
	ArrayGetArray(g_progressionRecords, index, record);
	if (failstate != TQUERY_SUCCESS)
		log_amx("Progression save queued for retry: %s", error);
	else if (record[SR_REVISION] == data[1])
		nvault_remove(g_pendingSaveJournal, record[SR_PLAYER_KEY]);
	StoreAcknowledge(record, data[1], failstate == TQUERY_SUCCESS);
	ArraySetArray(g_progressionRecords, index, record);
	// A newer revision stays dirty; next tick writes it, never clears it with an old acknowledgement.
}

public StoreTick()
{
	if (g_isSqlStorageEnabled && !g_isStorageReady)
	{
		StoreRequestSchema();
		return;
	}
	for (new i; i < ArraySize(g_progressionRecords); i++)
		StoreFlush(i);
	for (new id = 1; id <= g_maxPlayers; id++)
		if (is_user_authorized(id) && !g_playerReady[id])
			StoreAttach(id);
}

stock StoreClose()
{
	for (new id = 1; id <= g_maxPlayers; id++)
		if (g_playerReady[id])
			StoreCapture(id);
	for (new i; i < ArraySize(g_progressionRecords); i++)
	{
		if (g_isSqlStorageEnabled)
		{
			new record[StoreRecord];
			ArrayGetArray(g_progressionRecords, i, record);
			if (record[SR_HAS_UNSAVED_CHANGES])
				StoreJournal(i);
		}
		else
			StoreFlush(i);
	}
	if (g_progressionVault != INVALID_HANDLE)
		nvault_close(g_progressionVault);
	if (g_pendingSaveJournal != INVALID_HANDLE)
		nvault_close(g_pendingSaveJournal);
	if (g_sqlConnectionTuple != Empty_Handle)
		SQL_FreeHandle(g_sqlConnectionTuple);
	ArrayDestroy(g_progressionRecords);
}

public NativeProgressionKey(plugin, params)
{
	new id = get_param(1), key[65];
	if (id < 1 || id > g_maxPlayers || !g_playerReady[id])
		return 0;
	new record[StoreRecord];
	ArrayGetArray(g_progressionRecords, g_playerRecordIndex[id], record);
	copy(key, charsmax(key), record[SR_PLAYER_KEY]);
	return set_string(2, key, get_param(3));
}
