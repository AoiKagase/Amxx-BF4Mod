#if defined _bf4_objective_config_included
	#endinput
#endif
#define _bf4_objective_config_included

#define OBJ_ROW_POINT 1
#define OBJ_ROW_SPAWN 2

enum _:ObjectiveConfigRow
{
	OBJ_CFG_TEAM,
	OBJ_CFG_POINT,
	OBJ_CFG_X,
	OBJ_CFG_Y,
	OBJ_CFG_Z,
	OBJ_CFG_VALUE
};

stock bool:ObjectiveTextEqual(const left[], const right[])
{
	new i;
	while (left[i] && left[i] == right[i])
		i++;
	return left[i] == right[i];
}

stock ObjectiveReadToken(const line[], &cursor, token[], capacity)
{
	while (line[cursor] == ' ' || line[cursor] == 9 || line[cursor] == 13 || line[cursor] == 10)
		cursor++;
	if (!line[cursor] || line[cursor] == ';' || line[cursor] == '#')
		return 0;
	new length;
	while (line[cursor] && line[cursor] != ' ' && line[cursor] != 9 && line[cursor] != 13 && line[cursor] != 10)
	{
		if (length >= capacity - 1)
			return -1;
		token[length++] = line[cursor++];
	}
	token[length] = 0;
	return 1;
}

stock bool:ObjectiveParseInteger(const text[], minimum, maximum, &value)
{
	new cursor, sign = 1, number;
	if (text[0] == '-')
	{
		sign = -1;
		cursor++;
	}
	if (!text[cursor])
		return false;
	while (text[cursor])
	{
		new digit = text[cursor++] - '0';
		if (digit < 0 || digit > 9 || number > (32768 - digit) / 10)
			return false;
		number = number * 10 + digit;
	}
	number *= sign;
	if (number < minimum || number > maximum)
		return false;
	value = number;
	return true;
}

stock ObjectiveParseLine(const line[], row[ObjectiveConfigRow])
{
	new tokens[8][32], cursor, count, result;
	while ((result = ObjectiveReadToken(line, cursor, tokens[count], 32)) > 0)
	{
		if (++count == sizeof tokens)
			return -1;
	}
	if (result < 0)
		return -1;
	if (!count)
		return 0;

	new kind, coordinateStart, pointToken;
	if (ObjectiveTextEqual(tokens[0], "point") && count == 6)
	{
		kind = OBJ_ROW_POINT;
		coordinateStart = 2;
		pointToken = 1;
		row[OBJ_CFG_TEAM] = 0;
	}
	else if (ObjectiveTextEqual(tokens[0], "spawn") && count == 7)
	{
		kind = OBJ_ROW_SPAWN;
		coordinateStart = 3;
		pointToken = 2;
		if (ObjectiveTextEqual(tokens[1], "T"))
			row[OBJ_CFG_TEAM] = OBJ_TEAM_T;
		else if (ObjectiveTextEqual(tokens[1], "CT"))
			row[OBJ_CFG_TEAM] = OBJ_TEAM_CT;
		else if (ObjectiveTextEqual(tokens[1], "BOTH"))
			row[OBJ_CFG_TEAM] = 0;
		else
			return -1;
	}
	else
		return -1;

	if (kind == OBJ_ROW_SPAWN && ObjectiveTextEqual(tokens[pointToken], "base"))
		row[OBJ_CFG_POINT] = -1;
	else
	{
		if (tokens[pointToken][1] || tokens[pointToken][0] < 'A' || tokens[pointToken][0] > 'G')
			return -1;
		row[OBJ_CFG_POINT] = tokens[pointToken][0] - 'A';
	}

	for (new axis; axis < 3; axis++)
		if (!ObjectiveParseInteger(tokens[coordinateStart + axis], -32768, 32767, row[OBJ_CFG_X + axis]))
			return -1;
	if (!ObjectiveParseInteger(tokens[coordinateStart + 3], kind == OBJ_ROW_POINT ? 1 : -360,
		kind == OBJ_ROW_POINT ? 1024 : 360, row[OBJ_CFG_VALUE]))
		return -1;
	return kind;
}
