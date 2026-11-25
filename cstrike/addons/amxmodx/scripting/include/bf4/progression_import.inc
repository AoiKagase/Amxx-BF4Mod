// Console-only import of canonical player_key<TAB>xp<TAB>38 comma counts.
// Validate ALL rows and all existing identities before the first insert. No UPDATE.
new Array:g_importRecords;
new g_importRecordIndex;

stock ImportFinish(const message[])
{
	server_print("[BF4Ranks import] %s", message);
	if (g_importRecords)
		ArrayDestroy(g_importRecords);
	g_importRecords = Invalid_Array;
	g_isImportInProgress = false;
	g_importRecordIndex = 0;
}

stock bool:ImportEqual(const left[StoreRecord], const right[StoreRecord])
{
	if (left[SR_TOTAL_XP] != right[SR_TOTAL_XP])
		return false;
	for (new i; i < STORE_VALUES; i++)
		if (left[SR_AWARD_COUNTS + i] != right[SR_AWARD_COUNTS + i])
			return false;
	return true;
}

public ImportCommand(id)
{
	if (id != 0)
		return PLUGIN_HANDLED;
	if (!g_isStorageReady || g_isImportInProgress || get_playersnum())
	{
		server_print("[BF4Ranks import] Requires ready storage, no players, and no active import.");
		return PLUGIN_HANDLED;
	}
	new filename[128], path[256];
	read_argv(1, filename, charsmax(filename));
	if (!filename[0] || contain(filename, "..") != -1 ||
		contain(filename, "/") != -1 || contain(filename, "\\") != -1 ||
		contain(filename, ":") != -1)
	{
		server_print("[BF4Ranks import] Use a filename inside addons/amxmodx/data/.");
		return PLUGIN_HANDLED;
	}
	get_datadir(path, charsmax(path));
	add(path, charsmax(path), "/");
	add(path, charsmax(path), filename);
	new file = fopen(path, "rt");
	if (!file)
	{
		server_print("[BF4Ranks import] Cannot open input.");
		return PLUGIN_HANDLED;
	}
	g_isImportInProgress = true;
	g_importRecords = ArrayCreate(StoreRecord);
	new line[1024];
	while (!feof(file))
	{
		fgets(file, line, charsmax(line));
		new length = strlen(line);
		while (length && (line[length - 1] == 10 || line[length - 1] == 13))
			line[--length] = 0;
		if (!length)
			continue;
		new record[StoreRecord];
		if (!StoreParseImportRow(line, record))
		{
			fclose(file);
			ImportFinish("Invalid canonical TSV snapshot; no writes.");
			return PLUGIN_HANDLED;
		}
		new previous[StoreRecord];
		for (new i; i < ArraySize(g_importRecords); i++)
		{
			ArrayGetArray(g_importRecords, i, previous);
			if (equal(record[SR_PLAYER_KEY], previous[SR_PLAYER_KEY]))
			{
				fclose(file);
				ImportFinish("Duplicate player key; no writes.");
				return PLUGIN_HANDLED;
			}
		}
		new existing = StoreFind(record[SR_PLAYER_KEY]);
		if (existing != -1)
		{
			ArrayGetArray(g_progressionRecords, existing, previous);
			if (previous[SR_IS_LOAD_PENDING] || previous[SR_IS_SAVE_PENDING] || previous[SR_HAS_UNSAVED_CHANGES] ||
				(previous[SR_IS_LOADED] && !ImportEqual(record, previous)))
			{
				fclose(file);
				ImportFinish("Conflicting live/pending snapshot; no writes.");
				return PLUGIN_HANDLED;
			}
		}
		ArrayPushArray(g_importRecords, record);
	}
	fclose(file);
	if (!ArraySize(g_importRecords))
	{
		ImportFinish("Input is empty; no writes.");
		return PLUGIN_HANDLED;
	}
	server_print("[BF4Ranks import] Validated %d rows; checking existing data.", ArraySize(g_importRecords));
	g_importRecordIndex = 0;
	if (g_isSqlStorageEnabled)
		ImportSQLPreflight();
	else
		ImportVault();
	return PLUGIN_HANDLED;
}

stock ImportVault()
{
	new record[StoreRecord], existing[StoreRecord], text[STORE_TEXT], stamp;
	for (new i; i < ArraySize(g_importRecords); i++)
	{
		ArrayGetArray(g_importRecords, i, record);
		if (nvault_lookup(g_progressionVault, record[SR_PLAYER_KEY], text, charsmax(text), stamp) &&
			(!StoreDecode(text, existing) || !ImportEqual(record, existing)))
		{
			ImportFinish("Existing nVault data conflicts; no writes.");
			return;
		}
	}
	for (new i; i < ArraySize(g_importRecords); i++)
	{
		ArrayGetArray(g_importRecords, i, record);
		if (!nvault_lookup(g_progressionVault, record[SR_PLAYER_KEY], text, charsmax(text), stamp))
		{
			StoreEncode(record, text, charsmax(text));
			if (!nvault_set(g_progressionVault, record[SR_PLAYER_KEY], text))
			{
				ImportFinish("nVault write failed; safely rerun the same file.");
				return;
			}
		}
		if (nvault_lookup(g_progressionVault, record[SR_PLAYER_KEY], text, charsmax(text), stamp) &&
			StoreDecode(text, existing))
			record[SR_REVISION] = existing[SR_REVISION];
		ImportRefresh(record);
	}
	ImportFinish("Complete. Existing identical data retained; old stores untouched.");
}

stock ImportRefresh(const record[StoreRecord])
{
	new index = StoreFind(record[SR_PLAYER_KEY]);
	if (index == -1)
		return;
	new snapshot[StoreRecord];
	ArrayGetArray(g_progressionRecords, index, snapshot);
	if (!snapshot[SR_IS_LOADED])
	{
		snapshot = record;
		snapshot[SR_IS_LOADED] = true;
		ArraySetArray(g_progressionRecords, index, snapshot);
	}
}

stock ImportSQLPreflight()
{
	if (g_importRecordIndex == ArraySize(g_importRecords))
	{
		g_importRecordIndex = 0;
		ImportSQLWrite();
		return;
	}
	new record[StoreRecord], key[132], sql[384];
	ArrayGetArray(g_importRecords, g_importRecordIndex, record);
	StoreSQLKey(record[SR_PLAYER_KEY], key, charsmax(key));
	formatex(sql, charsmax(sql), "SELECT xp,counters,revision,schema_version FROM bf4_progression_v2 WHERE player_key=%s", key);
	SQL_ThreadQuery(g_sqlConnectionTuple, "ImportSQLChecked", sql);
}

public ImportSQLChecked(failstate, Handle:query, error[], errnum, data[], size, Float:duration)
{
	if (failstate != TQUERY_SUCCESS)
	{
		log_amx("Import preflight SQL: %s", error);
		ImportFinish("SQL preflight failed; no writes.");
		return;
	}
	if (SQL_NumResults(query))
	{
		new row[StoreRecord], existing[StoreRecord], csv[STORE_TEXT], text[STORE_TEXT];
		ArrayGetArray(g_importRecords, g_importRecordIndex, row);
		SQL_ReadResult(query, 1, csv, charsmax(csv));
		replace_all(csv, charsmax(csv), ",", " ");
		formatex(text, charsmax(text), "%d %d %d %s", SQL_ReadResult(query, 3), SQL_ReadResult(query, 0),
				 SQL_ReadResult(query, 2), csv);
		if (!StoreDecode(text, existing) || !ImportEqual(row, existing))
		{
			ImportFinish("Existing SQL data conflicts; no writes.");
			return;
		}
		row[SR_REVISION] = existing[SR_REVISION];
		row[SR_IMPORT_ALREADY_PRESENT] = true;
		ArraySetArray(g_importRecords, g_importRecordIndex, row);
	}
	g_importRecordIndex++;
	ImportSQLPreflight();
}

stock ImportSQLWrite()
{
	while (g_importRecordIndex < ArraySize(g_importRecords))
	{
		new row[StoreRecord];
		ArrayGetArray(g_importRecords, g_importRecordIndex, row);
		if (row[SR_IMPORT_ALREADY_PRESENT])
		{
			ImportRefresh(row);
			g_importRecordIndex++;
			continue;
		}
		new key[132], csv[STORE_TEXT], sql[1024];
		StoreSQLKey(row[SR_PLAYER_KEY], key, charsmax(key));
		StoreEncode(row, csv, charsmax(csv), true);
		formatex(sql, charsmax(sql), "INSERT INTO bf4_progression_v2 (player_key,xp,counters,revision,schema_version) VALUES (%s,%d,'%s',0,2)", key, row[SR_TOTAL_XP], csv);
		SQL_ThreadQuery(g_sqlConnectionTuple, "ImportSQLWritten", sql);
		return;
	}
	ImportFinish("Complete. Existing identical data retained; old stores untouched.");
}

public ImportSQLWritten(failstate, Handle:query, error[], errnum, data[], size, Float:duration)
{
	if (failstate != TQUERY_SUCCESS)
	{
		log_amx("Import SQL write: %s", error);
		ImportFinish("SQL insert failed; safely rerun the same file. Existing rows untouched.");
		return;
	}
	new row[StoreRecord];
	ArrayGetArray(g_importRecords, g_importRecordIndex, row);
	ImportRefresh(row);
	g_importRecordIndex++;
	ImportSQLWrite();
}
