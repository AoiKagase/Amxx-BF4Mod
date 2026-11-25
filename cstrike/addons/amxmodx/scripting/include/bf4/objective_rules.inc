#if defined _bf4_objective_rules_included
	#endinput
#endif
#define _bf4_objective_rules_included

// Pure rules. Engine team IDs are used explicitly; never use BF4_CLASS ordinals.
#define OBJ_TEAM_T 1
#define OBJ_TEAM_CT 2
#define OBJ_MODE_DOMINATION 1
#define OBJ_MODE_CONQUEST 2
#define OBJ_MAX_POINTS 7
#define OBJ_CONTROL_MAX 10000
#define OBJ_NO_WINNER -1
#define OBJ_DRAW 0

enum _:ObjectivePoint
{
	OBJ_OWNER,
	OBJ_PROGRESS
};

enum
{
	OBJ_EVENT_NONE,
	OBJ_EVENT_NEUTRALIZED,
	OBJ_EVENT_CAPTURED
};

enum
{
	OBJ_DEBT_WAIT,
	OBJ_DEBT_CLEAR,
	OBJ_DEBT_SPEND
};

stock ObjectiveAdvance(point[ObjectivePoint], terrorists, counterTerrorists, step)
{
	if (step <= 0 || terrorists < 0 || counterTerrorists < 0 || terrorists == counterTerrorists)
		return OBJ_EVENT_NONE;

	new direction = counterTerrorists > terrorists ? 1 : -1;
	new advantage = counterTerrorists - terrorists;
	if (advantage < 0)
		advantage = -advantage;
	if (advantage > 3)
		advantage = 3;
	if (step > OBJ_CONTROL_MAX)
		step = OBJ_CONTROL_MAX;

	new progress = point[OBJ_PROGRESS] + direction * advantage * step;
	// Enemy ownership must pass through neutral, even for an oversized update.
	if ((point[OBJ_OWNER] == OBJ_TEAM_T && progress >= 0) ||
		(point[OBJ_OWNER] == OBJ_TEAM_CT && progress <= 0))
	{
		point[OBJ_OWNER] = 0;
		point[OBJ_PROGRESS] = 0;
		return OBJ_EVENT_NEUTRALIZED;
	}
	if (progress < -OBJ_CONTROL_MAX)
		progress = -OBJ_CONTROL_MAX;
	if (progress > OBJ_CONTROL_MAX)
		progress = OBJ_CONTROL_MAX;
	point[OBJ_PROGRESS] = progress;

	new owner = progress == -OBJ_CONTROL_MAX ? OBJ_TEAM_T : (progress == OBJ_CONTROL_MAX ? OBJ_TEAM_CT : 0);
	if (owner && point[OBJ_OWNER] != owner)
	{
		point[OBJ_OWNER] = owner;
		return OBJ_EVENT_CAPTURED;
	}
	return OBJ_EVENT_NONE;
}

stock ObjectiveBleedTeam(terroristFlags, counterTerroristFlags, total)
{
	if (total <= 0)
		return 0;
	if (terroristFlags > total / 2)
		return OBJ_TEAM_CT;
	if (counterTerroristFlags > total / 2)
		return OBJ_TEAM_T;
	return 0;
}

stock ObjectiveSpend(tickets, amount)
{
	if (tickets <= 0)
		return 0;
	if (amount <= 0)
		return tickets;
	return amount >= tickets ? 0 : tickets - amount;
}

stock ObjectiveWinner(terroristTickets, counterTerroristTickets)
{
	if (terroristTickets <= 0 && counterTerroristTickets <= 0)
		return OBJ_DRAW;
	if (terroristTickets <= 0)
		return OBJ_TEAM_CT;
	if (counterTerroristTickets <= 0)
		return OBJ_TEAM_T;
	return OBJ_NO_WINNER;
}

stock bool:ObjectiveSpawnAllowed(mode, team, pointIndex, owner, bool:contested)
{
	if (team != OBJ_TEAM_T && team != OBJ_TEAM_CT)
		return false;
	if (pointIndex == 0)
		return true; // Base/map spawn. Stored point references are one-based.
	return mode == OBJ_MODE_CONQUEST && owner == team && !contested;
}

stock bool:ObjectiveContested(owner, terrorists, counterTerrorists)
{
	return (terrorists > 0 && counterTerrorists > 0) ||
		(owner == OBJ_TEAM_T && counterTerrorists > 0) ||
		(owner == OBJ_TEAM_CT && terrorists > 0);
}

stock ObjectiveResolveDebt(debtTeam, bool:alive, bool:redeploying)
{
	if (!debtTeam || !alive)
		return OBJ_DEBT_WAIT;
	return redeploying ? OBJ_DEBT_SPEND : OBJ_DEBT_CLEAR;
}
