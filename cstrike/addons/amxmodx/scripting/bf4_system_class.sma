#pragma tabsize 	4
#pragma semicolon 	1

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <bf4classes>
#include <bf4weapons>
#include <hamsandwich>
#include <reapi>

#define XO_PLAYER           		5
//#define m_iPlayerTeam          	114
//#define m_iJoiningState         	121
#define m_bHasChangeTeamThisRound 	125
//#define m_iMenu             		205

// Old Style Menus
new const FIRST_JOIN_MSG  		[] = "#Team_Select";
new const FIRST_JOIN_MSG_SPEC	[] = "#Team_Select_Spect";
new const INGAME_JOIN_MSG 		[] = "#IG_Team_Select";
new const INGAME_JOIN_MSG_SPEC	[] = "#IG_Team_Select_Spect";

// New VGUI Menus
new const VGUI_JOIN_TEAM_NUM = 2;

// Plugin Info.
new const PLUGIN_NAME			[]	= "[BF4] Class System";
new const PLUGIN_VERSION		[]	= "0.01";
new const PLUGIN_AUTHOR			[]	= "Aoi.Kagase";
new const PLUGIN_URL			[]	= "github.com/AoiKagase";
new const PLUGIN_DESC			[]	= "BattleField 4 Mod: Class System.";

new BF4_CLASS:gSelectClass		[MAX_PLAYERS + 1];
new BF4_CLASS:gReserveClass	[MAX_PLAYERS + 1];
new BF4_TEAM:gSelectTeam		[MAX_PLAYERS + 1];
new BF4_TEAM:gReserveTeam	[MAX_PLAYERS + 1];
new gJoined						[MAX_PLAYERS + 1];
new fwdTeamChange;
new fwdClassChange;

// =====================================================================
// Plugin Initialize.
// =====================================================================
public plugin_init()
{
	register_plugin	(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR, PLUGIN_URL, PLUGIN_DESC);

	RegisterHamPlayer(Ham_Spawn, "PlayerSpawnPre", false);

	register_message(get_user_msgid("ShowMenu"), "message_ShowMenu");
	register_message(get_user_msgid("VGUIMenu"), "message_VGUIMenu");

    register_clcmd( "chooseteam","bf4_menu_select_team" );
	register_clcmd( "/bf4class", "bf4_menu_select_class");

	plugin_forward();
}

// =====================================================================
// Native Functions.
// =====================================================================
public plugin_natives()
{
	register_library("bf4_classes_natives");
	register_native("BF4GetUserClass", 	"_bf4_get_user_class");
	register_native("BF4GetUserTeam", 	"_bf4_get_user_team");
	register_native("BF4FirstJoinTeam", "_bf4_first_jointeam");
}

// =====================================================================
// Forward Functions.
// =====================================================================
public plugin_forward()
{
	fwdTeamChange  = CreateMultiForward("BF4ForwardTeamChanged", 	ET_IGNORE, FP_CELL);
	fwdClassChange = CreateMultiForward("BF4ForwardClassChanged", 	ET_IGNORE, FP_CELL);
}

// =====================================================================
// Native Functions.
// 
// The game initialization process is required when first joining, 
// but is not executed because the team selection screen is blocked.
// Initialization is forced by rg_join_team.
//
// Note that this will be made available to the outside world, 
// not only by class decisions, but also by other menus, 
// as the timing will change depending on other menus.
// In this case, it is executed by the decision of the weapon menu.
// =====================================================================
public bool:_bf4_first_jointeam(iPlugins, iParams)
{
	new id = get_param(1);
	// First Join?
	if (!gJoined[id])
	{
		// When m_iJoiningState becomes GETINTOGAME, 
		// it is changed to JOINED by the game system and spawns automatically.
		// set_member(id, m_iJoiningState, GETINTOGAME);
		// The `rg_join_team` does it.
		rg_join_team(id, TeamName:gReserveTeam[id]);

		// Joined.
		gJoined[id] = 1;
		return true;
	}
	return false;
}

// =====================================================================
// Native Functions.
//
// Gets the current class.
// The second argument is used to obtain the class being reserved.
// =====================================================================
public BF4_CLASS:_bf4_get_user_class(iPlugin, iParams)
{
	new id = get_param(1);
	new reserve = get_param(2);
	if (reserve)
		return gReserveClass[id];
	else
		return gSelectClass[id];
}

// =====================================================================
// Native Functions.
//
// Gets the current team.
// The second argument is used to obtain the team being reserved.
// =====================================================================
public BF4_TEAM:_bf4_get_user_team(id)
{
	new id = get_param(1);
	new reserve = get_param(2);
	if (reserve)
		return gReserveTeam[id];
	else
		return gSelectTeam[id];
}

// =====================================================================
// Player Spawn Prelogic.
// =====================================================================
public PlayerSpawnPre(id)
{
	// If there is a change of team or class during the course of the battle, 
	// the team shall be changed before respawning.
	if ((gSelectTeam[id] != gReserveTeam[id]) || (gSelectClass[id] != gReserveClass[id]))
	{
		// Apply reserved team information.
		gSelectTeam[id]		= gReserveTeam[id];
		gSelectClass[id]	= gReserveClass[id];

		// Team and Class Change.
		switch(gSelectClass[id])
		{
			case BF4_CLASS_ASSAULT:
				(gSelectTeam[id] == BF4_TEAM_RU) ? cs_set_user_team(id, CS_TEAM_T, CS_T_TERROR) 	: cs_set_user_team(id, CS_TEAM_CT, CS_CT_URBAN);
			case BF4_CLASS_RECON:
				(gSelectTeam[id] == BF4_TEAM_RU) ? cs_set_user_team(id, CS_TEAM_T, CS_T_LEET) 		: cs_set_user_team(id, CS_TEAM_CT, CS_CT_GSG9);
			case BF4_CLASS_SUPPORT:
				(gSelectTeam[id] == BF4_TEAM_RU) ? cs_set_user_team(id, CS_TEAM_T, CS_T_ARCTIC) 	: cs_set_user_team(id, CS_TEAM_CT, CS_CT_GIGN);
			case BF4_CLASS_ENGINEER:
				(gSelectTeam[id] == BF4_TEAM_RU) ? cs_set_user_team(id, CS_TEAM_T, CS_T_GUERILLA) 	: cs_set_user_team(id, CS_TEAM_CT, CS_CT_SAS);
		}	
	}
}

// =====================================================================
// Player Initialize.
// =====================================================================
public client_putinserver(id)
{
	gJoined[id] 		= 0;
	gReserveClass[id] 	= gSelectClass[id] 	= BF4_CLASS_NONE;
	gReserveTeam[id] 	= gSelectTeam[id] 	= BF4_TEAM_NONE;

	if (is_user_bot(id))
	{
		gReserveTeam[id] = BF4_TEAM:random_num(_:BF4_TEAM_RU, _:BF4_TEAM_US);
		gReserveClass[id] = BF4_CLASS:random_num(_:BF4_CLASS_ASSAULT, _:BF4_CLASS_ENGINEER);
	}	
}

// =====================================================================
// Blocks in the team selection menu.
// Old Style.
// =====================================================================
public message_ShowMenu(iMsgid, iDest, id)
{
	static sMenuCode[sizeof(INGAME_JOIN_MSG_SPEC)];
	get_msg_arg_string(4, sMenuCode, charsmax(sMenuCode));

	if(equal(sMenuCode, FIRST_JOIN_MSG) 
	|| equal(sMenuCode, FIRST_JOIN_MSG_SPEC))
	{
		// Open Menu: team select.
		bf4_menu_select_team(id);
		return PLUGIN_HANDLED;
	}
	else
	if(equal(sMenuCode, INGAME_JOIN_MSG) 
	|| equal(sMenuCode, INGAME_JOIN_MSG_SPEC))
	{
		// Open Menu: team select.
		bf4_menu_select_team(id);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

// public TaskJoin(taskid)
// {
// 	new id = taskid - 8731;
// 	if (gSelectTeam[id] != BF4_TEAM_NONE)
// 	{
// 		bf4_menu_select_team(id);
// 		return PLUGIN_HANDLED;
// 	}

// 	new msgid = get_user_msgid("VGUIMenu");
// 	new block = get_msg_block(msgid);
// 	set_msg_block(msgid, BLOCK_SET);
// 	engclient_cmd(id, "jointeam", "6");
// 	set_msg_block(msgid, block);
// 	set_pdata_int(id, m_bHasChangeTeamThisRound, (get_pdata_int(id, m_bHasChangeTeamThisRound, XO_PLAYER) & ~(1 << 8)), XO_PLAYER);

// 	bf4_menu_select_team(id);
// 	return PLUGIN_HANDLED;
// }

// =====================================================================
// Block Team select menu.
// New VGUI Style.
// =====================================================================
public message_VGUIMenu(iMsgid, iDest, id)
{
	if(get_msg_arg_int(1) != VGUI_JOIN_TEAM_NUM)
		return PLUGIN_CONTINUE;

	// set_task(0.1, "TaskJoin", id + 8731);
	bf4_menu_select_team(id);
	return PLUGIN_HANDLED;
}

// =====================================================================
// Open Menu: Select Team menu.
// =====================================================================
public bf4_menu_select_team(id)
{
	// Invalid Not connected.
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;

	// Invalid bots.
	if (is_user_bot(id))
		return PLUGIN_HANDLED;

	// Menu create.
	new menu = menu_create("\r[BF4] \ySelect team:", "bf4_menu_select_team_handler");

	menu_additem(menu,  "(TR) RU / CH");
	menu_additem(menu,  "(CT) US");

	// Not on a team (first time joining) cannot be cancelled.
	if (!gSelectTeam[id])
		menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

// =====================================================================
// Menu Handler: Select Team menu.
// =====================================================================
public bf4_menu_select_team_handler(id, menu, item)
{
	new BF4_TEAM:team = gSelectTeam[id];
	switch(item)
	{
		case 0:
			gReserveTeam[id] = BF4_TEAM_RU;
		case 1:
			gReserveTeam[id] = BF4_TEAM_US;
	}

	if (team != gReserveTeam[id])
	{
		new ret;
		ExecuteForward(fwdTeamChange, ret, id);
	}

	// Open class menu.
	bf4_menu_select_class(id);
    menu_destroy(menu);
}

// ====================================================================
// Select Class menu.
// =====================================================================
public bf4_menu_select_class(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;

	if (is_user_bot(id))
		return PLUGIN_HANDLED;

	new menu = menu_create("\r[BF4] \ySelect class:", "bf4_menu_select_class_handler");

	menu_additem(menu,  "Assault");
	menu_additem(menu,  "Recon");
	menu_additem(menu,  "Support");
	menu_additem(menu,  "Engineer");

	// NOT EXIT.
	// Not on a class (first time joining) cannot be cancelled.
	if (!gSelectClass[id])
		menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

// ====================================================================
// Menu Handler: Select Class menu.
// =====================================================================
public bf4_menu_select_class_handler(id, menu, item)
{
	new BF4_CLASS:team = gSelectClass[id];

	// Bit calculation.
	gReserveClass[id] = BF4_CLASS:(1 << item);

	if (!gJoined[id])
	{
		set_member(id, m_iJoiningState, PICKINGTEAM);

		// Open weapon menu.
		BF4SelectWeaponMenu(id);
		menu_destroy(menu);

		return;
	}

	if (team != gReserveClass[id])
	{
		// client_print_color(id, print_team_default, "^4[BF4 DEBUG] Class Change");
		new ret;
		ExecuteForward(fwdClassChange, ret, id);
	}

	// Open weapon menu.
	BF4SelectWeaponMenu(id);
    menu_destroy(menu);
}