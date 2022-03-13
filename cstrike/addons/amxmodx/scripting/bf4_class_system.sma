#pragma tabsize 	4
#pragma semicolon 	1

#include <amxmodx>
#include <cstrike>
#include <bf4natives>

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

new CsTeams:gSelectTeam			[MAX_PLAYERS + 1];
new E_BF4_CLASS:gSelectClass	[MAX_PLAYERS + 1];
new gSelectWeaponPrimary		[MAX_PLAYERS + 1];
new gSelectWeaponSecondary		[MAX_PLAYERS + 1];

// =====================================================================
// Initialize.
// =====================================================================
public plugin_init()
{
	register_plugin	(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR, PLUGIN_URL, PLUGIN_DESC);
	register_message(get_user_msgid("ShowMenu"), "message_ShowMenu");
	register_message(get_user_msgid("VGUIMenu"), "message_VGUIMenu");
}

// =====================================================================
// Block Team select menu.
// Old Style.
// =====================================================================
public message_ShowMenu(iMsgid, iDest, id)
{
	static sMenuCode[sizeof(INGAME_JOIN_MSG_SPEC)];
	get_msg_arg_string(4, sMenuCode, charsmax(sMenuCode));

	if(equal(sMenuCode, FIRST_JOIN_MSG) 
	|| equal(sMenuCode, FIRST_JOIN_MSG_SPEC))
	{
		return PLUGIN_HANDLED;
	}
	else
	if(equal(sMenuCode, INGAME_JOIN_MSG) 
	|| equal(sMenuCode, INGAME_JOIN_MSG_SPEC))
	{
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

// =====================================================================
// Block Team select menu.
// New VGUI Style.
// =====================================================================
public message_VGUIMenu(iMsgid, iDest, id)
{
	if(get_msg_arg_int(1) != VGUI_JOIN_TEAM_NUM)
		return PLUGIN_CONTINUE;
	
	return PLUGIN_HANDLED;
}

// =====================================================================
// Select Team menu.
// =====================================================================
public bf4_menu_select_team(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;

	if (is_user_bot(id))
		return PLUGIN_HANDLED;

	new menu = menu_create("\r[BF4] Select team:", "bf4_menu_select_team_handler");

	menu_additem(menu,  "(TR) RU / CH");
	menu_additem(menu,  "(CT) US");

	// NOT EXIT.
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

// =====================================================================
// Select Team menu. Handler.
// =====================================================================
public bf4_menu_select_team_handler(id, menu, item)
{
	switch(item)
	{
		case 0:
		{
			cs_set_user_team(id, CS_TEAM_T);
			gSelectTeam[id] = CS_TEAM_T;
		}
		case 1:
		{
			cs_set_user_team(id, CS_TEAM_CT);
			gSelectTeam[id] = CS_TEAM_CT;
		}
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

	new menu = menu_create("\r[BF4] Select class:", "bf4_menu_select_class_handler");

	menu_additem(menu,  "Assault");
	menu_additem(menu,  "Recon");
	menu_additem(menu,  "Support");
	menu_additem(menu,  "Engineer");

	// NOT EXIT.
    menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

// ====================================================================
// Select Class menu. Handler.
// =====================================================================
public bf4_menu_select_class_handler(id, menu, item)
{
	gSelectClass[id] = E_BF4_CLASS:item;

	// Open weapon menu.
	bf4_menu_select_weapon(id);
    menu_destroy(menu);
}

// ====================================================================
// Select Weapon menu.
// =====================================================================
public bf4_menu_select_weapon(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;

	if (is_user_bot(id))
		return PLUGIN_HANDLED;

	new menu = menu_create("\r[BF4] Select Weapon:", "bf4_menu_select_weapon_handler");

	menu_additem(menu,  "Primary");
	menu_additem(menu,  "Secondary");

	// NOT EXIT.
    menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

// ====================================================================
// Select Weapon menu. Handler.
// =====================================================================
public bf4_menu_select_weapon_handler(id, menu, item)
{
	switch(item)
	{
		case 0: // Primary.
			bf4_menu_select_weapon_primary(id);
		case 1: // Secondary.
			bf4_menu_select_weapon_secondary(id);
	}
    menu_destroy(menu);
}

// ====================================================================
// Select Primary Weapon menu.
// =====================================================================
public bf4_menu_select_weapon_primary(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;

	if (is_user_bot(id))
		return PLUGIN_HANDLED;

	new menu = menu_create("\r[BF4] Select Primary Weapon:", "bf4_menu_select_weapon_primary_handler");

	switch(gSelectClass[id])
	{
		case BF4_CLASS_ASSAULT:
		{
			menu_additem(menu,  "Assault Rifle", 			fmt("%d", BF4_WEAPONCLASS_ASSAULTS));
			menu_additem(menu,  "Sub Machine Gun",			fmt("%d", BF4_WEAPONCLASS_SMGS));
			menu_additem(menu,  "Shot Gun",					fmt("%d", BF4_WEAPONCLASS_SHOTGUNS));
		}
		case BF4_CLASS_RECON:
		{
			menu_additem(menu,  "Sniper Rifle",				fmt("%d", BF4_WEAPONCLASS_SNIPERS));
			menu_additem(menu,  "Designated Marksman Rifle",fmt("%d", BF4_WEAPONCLASS_DMRS));
		}
		case BF4_CLASS_SUPPORT:
		{
			menu_additem(menu,  "Sub Machine Gun",			fmt("%d", BF4_WEAPONCLASS_SMGS));
			menu_additem(menu,  "Light Machine Gun",		fmt("%d", BF4_WEAPONCLASS_LMGS));
		}
		case BF4_CLASS_ENGINEER:
		{
			menu_additem(menu,  "Sub Machine Gun",			fmt("%d", BF4_WEAPONCLASS_SMGS));
			menu_additem(menu,  "Shot Gun",					fmt("%d", BF4_WEAPONCLASS_SHOTGUNS));
		}
	}

	// NOT EXIT.
    menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;	
}

// ====================================================================
// Select Primary Weapon menu. Handler.
// =====================================================================
public bf4_menu_select_weapon_primary_handler(id, menu, item)
{
	switch(gSelectClass[id])
	{
		case BF4_CLASS_ASSAULT:
			switch(item)
			{
				case BF4_WEAPONCLASS_ASSAULT:
				case BF4_WEAPONCLASS_SMGS:
				case BF4_WEAPONCLASS_SHOTGUNS:
			}
		case BF4_CLASS_RECON:
			switch(item)
			{
				case BF4_WEAPONCLASS_SNIPERS:
				case BF4_WEAPONCLASS_DMR:
			}
		case BF4_CLASS_SUPPORT:
			switch(item)
			{
				case BF4_WEAPONCLASS_SMGS:
				case BF4_WEAPONCLASS_LMGS:
			}
		case BF4_CLASS_ENGINEER:
			switch(item)
			{
				case BF4_WEAPONCLASS_SMGS:
				case BF4_WEAPONCLASS_SHOTGUNS:
			}
	}
}

public bf4_menu_select_weapon_secondary(id)
{

}