// Snapshot order: 19 event totals, then 19 earned-ribbon totals. Keep this order for saved data.
#define STORE_VALUES 38
#define STORE_TEXT 640
enum _:StoreRecord
{
	SR_PLAYER_KEY[65],
	SR_TOTAL_XP,
	SR_REVISION,
	SR_AWARD_COUNTS[STORE_VALUES],
	// Runtime state only; these flags are excluded from the persisted snapshot.
	SR_IS_LOADED,
	SR_IS_LOAD_PENDING,
	SR_IS_SAVE_PENDING,
	SR_IMPORT_ALREADY_PRESENT,
	SR_HAS_UNSAVED_CHANGES
};

// Strict decimal codec: reject truncation, extra fields, negatives and cell overflow.
stock bool:StoreDecode(const text[], record[StoreRecord])
{
	new cursor, values[STORE_VALUES + 3];
	for (new i; i < sizeof values; i++)
	{
		while (text[cursor] == ' ')
			cursor++;
		new start = cursor, value;
		while (text[cursor] && text[cursor] != ' ')
		{
			new digit = text[cursor++] - '0';
			if (digit < 0 || digit > 9 || value > (2147483647 - digit) / 10)
				return false;
			value = value * 10 + digit;
		}
		if (cursor == start)
			return false;
		values[i] = value;
	}
	while (text[cursor] == ' ')
		cursor++;
	if (text[cursor] || values[0] != 2)
		return false;
	record[SR_TOTAL_XP] = values[1];
	record[SR_REVISION] = values[2];
	for (new i; i < STORE_VALUES; i++)
		record[SR_AWARD_COUNTS + i] = values[i + 3];
	return true;
}

// Acknowledging an old write can never clear changes captured while it ran.
stock StoreAcknowledge(record[StoreRecord], sentRevision, bool:success)
{
	record[SR_IS_SAVE_PENDING] = false;
	if (success && record[SR_REVISION] == sentRevision)
		record[SR_HAS_UNSAVED_CHANGES] = false;
}

stock bool:StoreCanFlush(const record[StoreRecord])
{
	return record[SR_IS_LOADED] != 0 && record[SR_HAS_UNSAVED_CHANGES] != 0 && !record[SR_IS_SAVE_PENDING];
}

stock bool:SnapshotPrefix(const input[], const prefix[])
{
	new i;
	while (prefix[i])
	{
		if (input[i] != prefix[i])
			return false;
		i++;
	}
	return input[i] != 0;
}

stock bool:SnapshotKeyValid(const key[])
{
	new i;
	while (key[i])
	{
		new byte = key[i] & 255;
		if (i >= 63 || byte < 32 || byte == 127)
			return false;
		if (byte < 128)
		{
			i++;
			continue;
		}
		new count;
		if (byte >= 194 && byte <= 223)
			count = 1;
		else if (byte >= 224 && byte <= 239)
			count = 2;
		else if (byte >= 240 && byte <= 244)
			count = 3;
		else
			return false;
		new second = key[i + 1] & 255;
		if ((byte == 224 && second < 160) || (byte == 237 && second >= 160) || (byte == 240 && second < 144) ||
			(byte == 244 && second >= 144))
			return false;
		for (new n = 1; n <= count; n++)
		{
			if (i + n >= 63)
				return false;
			new part = key[i + n] & 255;
			if (part < 128 || part > 191)
				return false;
		}
		i += count + 1;
	}
	return SnapshotPrefix(key, "steam:") || SnapshotPrefix(key, "nick:") ||
		   SnapshotPrefix(key, "ip:") || SnapshotPrefix(key, "bot:");
}

// No whitespace tokenization: nickname keys can contain spaces, including at either end.
stock bool:StoreParseImportRow(const line[], record[StoreRecord])
{
	new cursor, key[65];
	while (line[cursor] && line[cursor] != 9)
	{
		if (cursor >= 64 || line[cursor] < 32)
			return false;
		key[cursor] = line[cursor];
		cursor++;
	}
	if (!cursor || line[cursor] != 9)
		return false;
	key[cursor] = 0;
	if (!SnapshotKeyValid(key))
		return false;
	cursor++;
	new text[STORE_TEXT], used = 2, xpStart = cursor;
	text[0] = '2';
	text[1] = ' ';
	while (line[cursor] && line[cursor] != 9)
	{
		if (line[cursor] < '0' || line[cursor] > '9' || used >= 15)
			return false;
		text[used++] = line[cursor++];
	}
	if (cursor == xpStart || line[cursor] != 9)
		return false;
	cursor++;
	text[used++] = ' ';
	text[used++] = '0';
	text[used++] = ' ';
	new commas, bool:previousComma = true;
	while (line[cursor])
	{
		if (used >= STORE_TEXT - 1)
			return false;
		if (line[cursor] == ',')
		{
			if (previousComma)
				return false;
			commas++;
			previousComma = true;
			text[used++] = ' ';
		}
		else
		{
			if (line[cursor] < '0' || line[cursor] > '9')
				return false;
			previousComma = false;
			text[used++] = line[cursor];
		}
		cursor++;
	}
	if (previousComma || commas != STORE_VALUES - 1)
		return false;
	text[used] = 0;
	if (!StoreDecode(text, record))
		return false;
	for (new i; i < 65; i++)
	{
		record[SR_PLAYER_KEY + i] = key[i];
		if (!key[i])
			break;
	}
	return true;
}

stock StoreSQLKey(const input[], output[], length)
{
	new const digits[] = "0123456789ABCDEF";
	new used = 2;
	output[0] = '0';
	output[1] = 'x';
	for (new i; input[i] && used + 2 <= length; i++)
	{
		new byte = input[i] & 255;
		output[used++] = digits[byte >> 4];
		output[used++] = digits[byte & 15];
	}
	output[used] = 0;
}
