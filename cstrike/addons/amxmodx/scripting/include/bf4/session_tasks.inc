#if defined _bf4_session_tasks_included
#endinput
#endif
#define _bf4_session_tasks_included

// Plugin-local generations: independent of cross-plugin connect callback order.
new gBF4TaskGeneration[MAX_PLAYERS + 1];

stock BF4TaskReset(id)
{
	if (id < 1 || id > MAX_PLAYERS)
		return;
	gBF4TaskGeneration[id]++;
	if (!gBF4TaskGeneration[id])
		gBF4TaskGeneration[id]++;
}

stock bool:BF4TaskValid(id, const session[])
{
	return id >= 1 && id <= MAX_PLAYERS && is_user_connected(id) && session[0] == gBF4TaskGeneration[id];
}

stock bool:BF4TaskAccept(id, const session[], taskid)
{
	if (BF4TaskValid(id, session))
		return true;
	remove_task(taskid);
	return false;
}

stock BF4ScheduleTask(Float:delay, const callback[], id, taskid, bool:repeat = false)
{
	new session[1];
	session[0] = gBF4TaskGeneration[id];
	set_task_ex(delay, callback, taskid, session, sizeof session, repeat ? SetTask_Repeat : SetTask_Once);
}
