#pragma semicolon 1
native check(value, code);
#include <bf4/objective_rules>
#include <bf4/objective_config>

public main()
{
	new row[ObjectiveConfigRow];
	check(ObjectiveParseLine("; comment", row) == 0, 1);
	check(ObjectiveParseLine("", row) == 0, 2);
	check(ObjectiveParseLine("point A -100 20 30 160", row) == OBJ_ROW_POINT, 3);
	check(row[OBJ_CFG_POINT] == 0 && row[OBJ_CFG_X] == -100 && row[OBJ_CFG_VALUE] == 160, 4);
	check(ObjectiveParseLine("spawn T base 1 2 3 90", row) == OBJ_ROW_SPAWN, 5);
	check(row[OBJ_CFG_TEAM] == 1 && row[OBJ_CFG_POINT] == -1 && row[OBJ_CFG_VALUE] == 90, 6);
	check(ObjectiveParseLine("spawn BOTH G 1 2 3 -90 # note", row) == OBJ_ROW_SPAWN && row[OBJ_CFG_POINT] == 6, 7);
	check(ObjectiveParseLine("spawn CT A 1 2 3 360", row) == OBJ_ROW_SPAWN && row[OBJ_CFG_TEAM] == 2, 8);
	check(ObjectiveParseLine("point H 1 2 3 100", row) == -1, 9);
	check(ObjectiveParseLine("point A 1 2 3 0", row) == -1, 10);
	check(ObjectiveParseLine("point A 1 2 3 1025", row) == -1, 11);
	check(ObjectiveParseLine("point A 1 2 3 100 extra", row) == -1, 12);
	check(ObjectiveParseLine("point A 1.5 2 3 100", row) == -1, 13);
	check(ObjectiveParseLine("point A 999999999999999 2 3 100", row) == -1, 14);
	check(ObjectiveParseLine("spawn X base 1 2 3 90", row) == -1, 15);
	check(ObjectiveParseLine("spawn T base 1 2 3 361", row) == -1, 16);
	check(ObjectiveParseLine("point A 1 2 100", row) == -1, 17);
	check(ObjectiveParseLine("point A - 2 3 100", row) == -1, 18);
	return 18;
}
