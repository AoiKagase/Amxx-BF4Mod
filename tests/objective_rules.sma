#pragma semicolon 1
native check(value, code);
#include <bf4/objective_rules>

public main()
{
	new point[ObjectivePoint];
	check(ObjectiveAdvance(point, 1, 0, 2500) == OBJ_EVENT_NONE && point[OBJ_PROGRESS] == -2500, 1);
	ObjectiveAdvance(point, 1, 0, 7500);
	check(point[OBJ_OWNER] == OBJ_TEAM_T && point[OBJ_PROGRESS] == -10000, 2);
	check(ObjectiveAdvance(point, 2, 2, 5000) == OBJ_EVENT_NONE && point[OBJ_PROGRESS] == -10000, 3);
	check(ObjectiveAdvance(point, 0, 1, 15000) == OBJ_EVENT_NEUTRALIZED && point[OBJ_OWNER] == 0 && point[OBJ_PROGRESS] == 0, 4);
	check(ObjectiveAdvance(point, 0, 1, 10000) == OBJ_EVENT_CAPTURED && point[OBJ_OWNER] == OBJ_TEAM_CT, 5);
	check(ObjectiveAdvance(point, 0, 4, 10000) == OBJ_EVENT_NONE, 6);
	check(ObjectiveAdvance(point, 0, 0, 5000) == OBJ_EVENT_NONE && point[OBJ_PROGRESS] == 10000, 7);
	point[OBJ_OWNER] = 0;
	point[OBJ_PROGRESS] = 0;
	ObjectiveAdvance(point, 2, 1, 1000);
	check(point[OBJ_PROGRESS] == -1000, 8);
	ObjectiveAdvance(point, 20, 0, 1000);
	check(point[OBJ_PROGRESS] == -4000, 9);
	check(ObjectiveBleedTeam(2, 1, 3) == OBJ_TEAM_CT, 10);
	check(ObjectiveBleedTeam(1, 1, 3) == 0 && ObjectiveBleedTeam(1, 0, 3) == 0, 11);
	check(ObjectiveBleedTeam(1, 1, 2) == 0 && ObjectiveBleedTeam(2, 0, 2) == OBJ_TEAM_CT, 12);
	check(ObjectiveSpend(2, 3) == 0 && ObjectiveSpend(5, 1) == 4 && ObjectiveSpend(5, -1) == 5, 13);
	check(ObjectiveWinner(0, 5) == OBJ_TEAM_CT && ObjectiveWinner(5, 0) == OBJ_TEAM_T, 14);
	check(ObjectiveWinner(0, 0) == OBJ_DRAW && ObjectiveWinner(2, 2) == OBJ_NO_WINNER, 15);
	check(ObjectiveSpawnAllowed(OBJ_MODE_DOMINATION, 1, 0, 0, true), 16);
	check(!ObjectiveSpawnAllowed(OBJ_MODE_CONQUEST, 1, 1, 2, false), 17);
	check(ObjectiveSpawnAllowed(OBJ_MODE_CONQUEST, 1, 1, 1, false), 18);
	check(!ObjectiveSpawnAllowed(OBJ_MODE_CONQUEST, 1, 1, 1, true), 19);
	check(ObjectiveSpawnAllowed(OBJ_MODE_CONQUEST, 1, 0, 0, false), 20);
	check(ObjectiveResolveDebt(1, false, false) == OBJ_DEBT_WAIT, 21);
	check(ObjectiveResolveDebt(1, true, false) == OBJ_DEBT_CLEAR, 22);
	check(ObjectiveResolveDebt(1, true, true) == OBJ_DEBT_SPEND, 23);
	check(ObjectiveResolveDebt(0, true, true) == OBJ_DEBT_WAIT, 24);
	check(ObjectiveContested(OBJ_TEAM_T, 0, 1) && ObjectiveContested(OBJ_TEAM_CT, 1, 0), 25);
	check(!ObjectiveContested(OBJ_TEAM_T, 1, 0) && ObjectiveContested(0, 1, 1) && !ObjectiveContested(0, 1, 0), 26);
	return 26;
}
