#pragma semicolon 1
#define MAX_PLAYERS 32
enum
{
	SetTask_Once,
	SetTask_Repeat
};
native check(value, code);
new bool:gConnected[33], gRemoved;
stock bool:is_user_connected(id)
{
	return gConnected[id];
}
stock remove_task(task)
{
	gRemoved++;
	return task;
}
stock set_task_ex(Float:delay, const callback[], task, const data[], size, flags)
{
	return _:delay + callback[0] + task + data[0] + size + flags;
}
#include <bf4/session_tasks>
public main()
{
	new saved[1];
	gConnected[32] = true;
	BF4TaskReset(32);
	saved[0] = gBF4TaskGeneration[32];
	check(BF4TaskAccept(32, saved, 100), 1);
	gConnected[32] = false;
	BF4TaskReset(32);
	check(!BF4TaskAccept(32, saved, 100), 2);
	gConnected[32] = true;
	BF4TaskReset(32);
	check(!BF4TaskAccept(32, saved, 100), 3);
	saved[0] = gBF4TaskGeneration[32];
	check(BF4TaskAccept(32, saved, 100), 4);
	check(!BF4TaskValid(0, saved), 5);
	check(!BF4TaskValid(33, saved), 6);
	check(gRemoved == 2, 7);
	return 7;
}
