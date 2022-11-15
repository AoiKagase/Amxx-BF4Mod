#include <amxmodx>
#include <reapi>
#include <bf4const>
#include <bf4classes>
#include <bf4weapons>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <cswm>

#define PLUGIN 	"[BF4] Weapon System"
#define VERSION "0.1"
#define AUTHOR	"Aoi.Kagase"

enum WPN_CLASSIC_DATA
{
	CSC_NAME[64],
	CSC_ITEM[33],
	Ammo:CSC_AMMOID,
	BF4_TEAM:CSC_TEAM,
	BF4_WEAPONCLASS:CSC_WPNCLASS,
	BF4_CLASS:CSC_HASCLASS,
};

// Classic Weapon Data.
// FullName, ItemName, AmmoId, Team, WeaponClass, Has Class
new const gWpnClassicItem[CSW_LAST_WEAPON + 1][WPN_CLASSIC_DATA] =
{
	{
		"",
		"",
		Ammo_None,
		BF4_TEAM_NONE,	
		BF4_WEAPONCLASS_NONE,		
		BF4_CLASS_NONE,
	},
	{
		"SIG SAUER P228",
		"p228",
		Ammo_357SIG,	
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"",
		"",
		Ammo_None,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_NONE,
		BF4_CLASS_NONE,
	},
	{
		"Steyr Scout",
		"scout",
		Ammo_762Nato,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SNIPERS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON
	},
	{
		"HE Grenade",
		"hegrenade",
		Ammo_HEGRENADE,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_GRENADE,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"Benelli M4 Super 90", 	
		"xm1014",
		Ammo_12Gauge,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SHOTGUNS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_ENGINEER
	},
	{
		"C4",
		"c4",
		Ammo_C4,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_EQUIP,
		BF4_CLASS_NONE,
	},
	{
		"Ingram Model 10",
		"mac10",
		Ammo_45ACP,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
	{
		"Steyr AUG",
		"aug",
		Ammo_556Nato,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"Smoke Grenade",
		"smokegrenade",
		Ammo_SMOKEGRENADE,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_GRENADE,
		BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"Dual 96G Elite Berettas", 
		"elite",
		Ammo_9MM,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"FN Five-seveN",
		"fiveseven",
		Ammo_57MM,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"H&K UMP45",
		"ump45",
		Ammo_45ACP,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
	{
		"SIG SG550",
		"sg550",
		Ammo_556Nato,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_DMRS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON
	},
	{
		"IMI Galil",
		"galil",
		Ammo_556Nato,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"NEXTER FA-MAS",
		"famas",
		Ammo_556Nato,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"H&K USP",
		"usp",
		Ammo_45ACP,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"GLOCK 18",
		"glock18",
		Ammo_9MM,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"AI L96A1 AWP",
		"awp",
		Ammo_338Magnum,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SNIPERS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON 
	},
	{
		"H&K MP5N",
		"mp5navy",
		Ammo_9MM,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
	{
		"FN M249",
		"m249",
		Ammo_556NatoBox,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_LMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_SUPPORT
	},
	{
		"Benelli M3",
		"m3",
		Ammo_12Gauge,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SHOTGUNS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_ENGINEER
	},
	{
		"Colt M4A1",
		"m4a1",
		Ammo_556Nato,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"Steyr TMP",
		"tmp",
		Ammo_9MM,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
	{
		"H&K G3SG/1",
		"g3sg1",
		Ammo_762Nato,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_DMRS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON
	},
	{
		"FLASHBANG",
		"flashbang",
		Ammo_FLASHBANG,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_GRENADE,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"IWI Deset Eagle .50AE",
		"deagle",
		Ammo_50AE,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"SIG SG552",
		"sg552",
		Ammo_556Nato,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"Izhmash AK-47",
		"ak47",
		Ammo_762Nato,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"KNIFE",
		"knife",
		Ammo_None,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_MELEE,
		BF4_CLASS_NONE,
	},
	{
		"FN P90",
		"p90",
		Ammo_57MM,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
} 

// Player Use Weapon
enum _:WPN_SLOT
{
	PRIMARY,
	SECONDARY,
	MELEE,		// KNIFE (Not Selectable)
	GRENADE,
	EQUIP,		// Slot Smokegrenade Replace.
	EXTRAITEM	// C4	(Not Selectable)
}

// All registed weapon.
new Array:gWeaponList;

new gUseWeapons[MAX_PLAYERS + 1][WPN_SLOT];
new gStackUseWeapons[MAX_PLAYERS + 1][WPN_SLOT];

// used to supercede c4 icon displaying
new g_icon_c4[] = "c4";
new g_icon_buyzone[] = "buyzone";

// bomb should't be given so creation of the given classname will be superceded
new g_weapon_c4[] = "weapon_c4"

// icon modes
#define ICON_NONE 		0
#define ICON_NORMAL 	(1<<0)
#define ICON_BLINK	 	(1<<1)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("say /bf4sec", 		"BF4WeaponMenu");
	register_clcmd("buy",				"BF4WeaponMenu");
	RegisterHamPlayer(Ham_Spawn, 		"PlayerSpawnPre", false);
	RegisterHamPlayer(Ham_Spawn, 		"PlayerSpawn", true);
	RegisterHamPlayer(Ham_TakeDamage, 	"PlayerTakeDamagePre");
	RegisterHamPlayer(Ham_TakeDamage, 	"PlayerTakeDamagePost", true);

	register_forward(FM_CreateNamedEntity, "forward_create_named_entity");

	register_message(get_user_msgid("DeathMsg"), 	"PlayerDeath");

	register_message(get_user_msgid("StatusIcon"), 	"message_status_icon");
}

public forward_create_named_entity(int_class) 
{
	static class[16];
	engfunc(EngFunc_SzFromIndex, int_class, class, 15);

	if (equal(class, g_weapon_c4))
		return FMRES_SUPERCEDE;

	return FMRES_IGNORED;
}

RemoveFromBuyzone(id) 
{
    // Define offsets to be used
    const m_fClientMapZone = 235;
    const MAPZONE_BUYZONE = (1 << 0);
    const XO_PLAYERS = 5;
    
    // Remove player's buyzone bit for the map zones
    set_pdata_int(id, m_fClientMapZone, get_pdata_int(id, m_fClientMapZone, XO_PLAYERS) & ~MAPZONE_BUYZONE, XO_PLAYERS);
}

public message_status_icon(MsgId, dest, receiver) 
{
	if (get_msg_arg_int(1) == ICON_NONE)
		return PLUGIN_CONTINUE;

	static arg[12];
	get_msg_arg_string(2, arg, charsmax(arg));

	if (equal(arg, g_icon_c4))
		return PLUGIN_HANDLED;

	if (equal(arg, g_icon_buyzone))
	{
		RemoveFromBuyzone(receiver);
		set_msg_arg_int(1, ARG_BYTE, 0);
	}
	return PLUGIN_CONTINUE;
}


public plugin_precache()
{
	gWeaponList = ArrayCreate(BF4_WEAPON_DATA);
	for(new i = 0; i < 33; i++)
	{
		gUseWeapons[i] = {-1,-1,-1,-1,-1,-1};
		gStackUseWeapons[i] = {-1,-1,-1,-1,-1,-1};
	}

	RegisterClassicWeapon();
}

RegisterClassicWeapon()
{
	for(new i = 0; i <= CSW_LAST_WEAPON; i++)
	{
		new weapon[BF4_WEAPON_DATA];
		weapon[TEAM]	 = gWpnClassicItem[i][CSC_TEAM];
		weapon[HASCLASS] = gWpnClassicItem[i][CSC_HASCLASS];
		weapon[WPNCLASS] = gWpnClassicItem[i][CSC_WPNCLASS];
		weapon[CSWM_ID]	 = -1;
		weapon[AMMO_ID]  = gWpnClassicItem[i][CSC_AMMOID];

		copy(weapon[NAME],charsmax(weapon[NAME]), gWpnClassicItem[i][CSC_NAME]);
		copy(weapon[ITEM],charsmax(weapon[ITEM]), gWpnClassicItem[i][CSC_ITEM]);

		ArrayPushArray(gWeaponList, weapon, sizeof(weapon));
	}
}

public plugin_natives()
{
	register_library("bf4_weapons_natives");
	register_native("BF4RegisterWeapon", "_native_register_weapon");
	register_native("BF4HaveThisWeapon", "_native_have_this_weapon");
	register_native("BF4SelectWeaponMenu", "_native_select_weapon_menu");
}

public plugin_end()
{
	ArrayDestroy(gWeaponList);
}
// const BF4_WEAPON_TEAM:team, const BF4_WEAPON_HAS_CLASS:has_class, const BF4_WEAPON_CLASS:wpn_class, const CSWM_id, const name[33], const item[33];
public _native_register_weapon(iPlugin, iParams)
{

	new name[33], item[33];
	get_string(6, name, charsmax(name));
	get_string(7, item, charsmax(item));

	return RegisterWeapon(BF4_TEAM:get_param(1), BF4_CLASS:get_param(2), BF4_WEAPONCLASS:get_param(3), get_param(4), Ammo:get_param(5), name, item);
}

public _native_select_weapon_menu(iPlugin, iParams)
{
	new id = get_param(1);
	BF4WeaponMenu(id);
}

RegisterWeapon(BF4_TEAM:team, BF4_CLASS:has_class, BF4_WEAPONCLASS:wpn_class, cswm_id, Ammo:ammo_id, name[33], item[33])
{
	new weapon[BF4_WEAPON_DATA];
	weapon[TEAM] 			= team;
	weapon[HASCLASS] 		= has_class;
	weapon[WPNCLASS]		= wpn_class;
	weapon[CSWM_ID] 		= cswm_id;
	weapon[AMMO_ID]			= ammo_id;
	weapon[NAME]			= name;
	weapon[ITEM]			= item;

	return ArrayPushArray(gWeaponList, weapon, sizeof(weapon));
}
public _native_have_this_weapon(iPlugin, iParams)
{
	new id = get_param(1);
	new wpnidx = get_param(2);

	for(new i = PRIMARY; i <= EQUIP; i++)
	{
		if (gUseWeapons[id][i] == wpnidx)
			return true;
	}
	return false;
}

public BF4WeaponMenu(id)
{
	new menu = menu_create("\r[BF4] \ySelect Weapon:", "BF4WeaponMenu_Handler");
	new weapondata[BF4_WEAPON_DATA];

	if (gStackUseWeapons[id][PRIMARY] > -1)
	{
		ArrayGetArray(gWeaponList, gStackUseWeapons[id][PRIMARY], weapondata);
		menu_additem(menu, fmt("Primary: \r[%s]",  weapondata[NAME]));
	} else
	{
		menu_additem(menu, "Primary");
	}

	if (gStackUseWeapons[id][SECONDARY] > -1)
	{
		ArrayGetArray(gWeaponList, gStackUseWeapons[id][SECONDARY], weapondata);
		menu_additem(menu, fmt("Secondary: \r[%s]",  weapondata[NAME]));
	} else
	{
		menu_additem(menu, "Secondary");
	}

	if (gStackUseWeapons[id][GRENADE] > -1)
	{
		ArrayGetArray(gWeaponList, gStackUseWeapons[id][GRENADE], weapondata);
		menu_additem(menu, fmt("Grenade: \r[%s]", weapondata[NAME]));
	} else
	{
		menu_additem(menu, "Grenade");
	}

	if (gStackUseWeapons[id][EQUIP] > -1)
	{
		ArrayGetArray(gWeaponList, gStackUseWeapons[id][EQUIP], weapondata);
		menu_additem(menu, fmt("Equipment: \r[%s]", weapondata[NAME]));
	} else
	{
		menu_additem(menu, "Equipment");
	}

	if (gStackUseWeapons[id][PRIMARY] == -1 || gStackUseWeapons[id][SECONDARY] == -1)
		menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu, 0);
}

public BF4WeaponMenu_Handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		if (!BF4FirstJoinTeam(id))
		{
			client_print_color(id, print_team_default, "^4[BF4] ^1It will be applied at the next respawn.");
			// ExecuteHamB(Ham_CS_RoundRespawn,id);
		}
		return PLUGIN_CONTINUE;
	}

	switch(item)
	{
		// Primary
		case 0:
		{
			BF4WeaponMenuPrimary(id);
		}
		// Secondary
		case 1:
			BF4WeaponMenuWeaponClass(id, BF4_WEAPONCLASS_PISTOLS);
		// Grenade
		case 2:
			BF4WeaponMenuWeaponClass(id, BF4_WEAPONCLASS_GRENADE);
		case 3:
			BF4WeaponMenuWeaponClass(id, BF4_WEAPONCLASS_EQUIP);
	}
	menu_destroy(menu);

	return PLUGIN_HANDLED;
}
	
// ====================================================================
// Select Primary Weapon menu.
// =====================================================================
public BF4WeaponMenuPrimary(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;

	if (is_user_bot(id))
		return PLUGIN_HANDLED;

	// Primary Weapon Menu.
	new menu = menu_create("\r[BF4] \ySelect Weapon Primary:", "BF4WeaponMenuPrimary_Handler");

	switch(BF4GetUserClass(id, true))
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
public BF4WeaponMenuPrimary_Handler(id, menu, item)
{

	new szData[16], szName[32];
	new _access, item_callback;	
	menu_item_getinfo(menu, item, _access, szData, charsmax(szData), szName, charsmax(szName), item_callback);

	BF4WeaponMenuWeaponClass(id, BF4_WEAPONCLASS:str_to_num(szData));
	menu_destroy(menu);

	return PLUGIN_HANDLED;
}


public BF4WeaponMenuWeaponClass(id, BF4_WEAPONCLASS:iWpnClass)
{
	new szClass[33];
	switch(iWpnClass)
	{
		case BF4_WEAPONCLASS_PISTOLS: 	formatex(szClass, charsmax(szClass), "Secondary");
		case BF4_WEAPONCLASS_ASSAULTS:	formatex(szClass, charsmax(szClass), "Assault Rifle");
		// case BF4_WEAPONCLASS_CARBINS:formatex(szClass, charsmax(szClass), "Carbin");
		case BF4_WEAPONCLASS_SNIPERS:	formatex(szClass, charsmax(szClass), "Sniper Rifle");
		// case BF4_WEAPONCLASS_PDWS:	formatex(szClass, charsmax(szClass), "PDW");
		case BF4_WEAPONCLASS_LMGS:		formatex(szClass, charsmax(szClass), "Light Machine Gun");
		case BF4_WEAPONCLASS_DMRS:		formatex(szClass, charsmax(szClass), "DMR");
		case BF4_WEAPONCLASS_SMGS:		formatex(szClass, charsmax(szClass), "Sub Machine Gun");
		case BF4_WEAPONCLASS_SHOTGUNS:	formatex(szClass, charsmax(szClass), "Shotgun");
		case BF4_WEAPONCLASS_MELEE:		formatex(szClass, charsmax(szClass), "Melee");
		case BF4_WEAPONCLASS_GRENADE:	formatex(szClass, charsmax(szClass), "Grenade");
		case BF4_WEAPONCLASS_EQUIP:		formatex(szClass, charsmax(szClass), "Equipment");
		case BF4_WEAPONCLASS_EXTRA:		formatex(szClass, charsmax(szClass), "Extra Weapon");
	}

	new menu = menu_create(fmt("\r[BF4] \ySelect Weapon %s:",szClass), "BF4WeaponMenuWeaponClass_Handler");
	new data[BF4_WEAPON_DATA];
	new index[33];

	for(new i = 0; i < ArraySize(gWeaponList); i++)
	{
		ArrayGetArray(gWeaponList, i, data, sizeof(data));
		num_to_str(i, index, charsmax(index));
		if ((data[HASCLASS] & BF4_CLASS_SELECTABLE) && (data[HASCLASS] & BF4GetUserClass(id, true)) && data[WPNCLASS] == iWpnClass)
		{
			if (data[TEAM] == BF4_TEAM_BOTH || data[TEAM] == BF4GetUserTeam(id, true))
				menu_additem(menu, data[NAME], index);
		}
	}

	if (menu_items(menu) <= 0)
	{
		// client_print(id, print_chat, "[BF4 DEBUG] TEAM: %d, CLASS: %d", BF4GetUserTeam(id), BF4GetUserClass(id));
		menu_addtext2(menu, "There is no equipment available in this class.");
	}
	// NOT EXIT.
//	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0);
}


// ====================================================================
// Select Primary Weapon menu. Handler.
// =====================================================================
public BF4WeaponMenuWeaponClass_Handler(id, menu, item)
{
	new szData[64 + 6], szName[32];
	new _access, item_callback;	
	menu_item_getinfo(menu, item, _access, szData, charsmax(szData), szName, charsmax(szName), item_callback);

	new index = str_to_num(szData);
	new data[BF4_WEAPON_DATA];

	ArrayGetArray(gWeaponList, index, data, sizeof(data));

	gStackUseWeapons[id][GetWeaponSlot(data[WPNCLASS])] 	= index;

	menu_destroy(menu);
	BF4WeaponMenu(id);
	return PLUGIN_HANDLED;
}

public PlayerSpawnPre(id)
{
	gUseWeapons[id] = gStackUseWeapons[id];
}

public PlayerSpawn(id)
{
	if (!is_user_alive(id))
		return HAM_IGNORED;
	strip_user_weapons(id);

	BF4GiveWeapon(id);

	return HAM_IGNORED;
}

public PlayerTakeDamagePre(iVictim, inflictor, iAttacker, Float:damage, damage_type)
{
	if (is_user_alive(iAttacker))
	{
		new data[BF4_WEAPON_DATA];
		new weapon = cs_get_user_weapon_entity(iAttacker);
		new cswid  = cs_get_weapon_id(weapon);
		switch(cswid)
		{
			case CSW_P228:
				if (gUseWeapons[iAttacker][SECONDARY] > -1)
				{
					ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][SECONDARY], data, charsmax(data));
					if (data[CSWM_ID] > -1)
						rg_set_iteminfo(weapon, ItemInfo_pszName, data[ITEM]);
				}
			case CSW_AK47, CSW_XM1014, CSW_AWP:
				if (gUseWeapons[iAttacker][PRIMARY] > -1)
				{
					ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][PRIMARY], data, charsmax(data));
					if (data[CSWM_ID] > -1)
						rg_set_iteminfo(weapon, ItemInfo_pszName, data[ITEM]);
				}
		}
	}
}

public PlayerTakeDamagePost(iVictim, inflictor, iAttacker, Float:damage, damage_type)
{
	if (is_user_alive(iAttacker))
	{
		new weapon = cs_get_user_weapon_entity(iAttacker);
		new cswid = cs_get_weapon_id(weapon);
		switch(cswid)
		{
			case CSW_P228:
				rg_set_iteminfo(weapon, ItemInfo_pszName, "p228");
			case CSW_AK47:
				rg_set_iteminfo(weapon, ItemInfo_pszName, "ak47");
			case CSW_XM1014:
				rg_set_iteminfo(weapon, ItemInfo_pszName, "xm1014");
			case CSW_AWP:
				rg_set_iteminfo(weapon, ItemInfo_pszName, "awp");
		}
	}
}

public PlayerDeath()
{
	new iAttacker 	= get_msg_arg_int(1);

	if (!is_user_connected(iAttacker) || !is_user_alive(iAttacker))
		return PLUGIN_CONTINUE;
	new data[BF4_WEAPON_DATA];
	new weapon		= cs_get_user_weapon(iAttacker);
	switch(weapon)
	{
		case CSW_P228:
			if (gUseWeapons[iAttacker][SECONDARY] > -1)
			{
				ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][SECONDARY], data, charsmax(data));
				if (data[CSWM_ID] > -1)
					switch(data[AMMO_ID])
					{
						case Ammo_9MM:
							set_msg_arg_string(4, "glock18");
						case Ammo_45ACP:
							set_msg_arg_string(4, "usp");
						case Ammo_357SIG:
							set_msg_arg_string(4, "p228");
						case Ammo_50AE:
							set_msg_arg_string(4, "deagle");
						case Ammo_57MM:
							set_msg_arg_string(4, "fiveseven");
					}
			}
		case CSW_AK47, CSW_XM1014, CSW_AWP:
			if (gUseWeapons[iAttacker][PRIMARY] > -1)
			{
				ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][PRIMARY], data, charsmax(data));
				if (data[CSWM_ID] > -1)
				{
					new BF4_TEAM:team = BF4GetUserTeam(iAttacker);
					switch(data[WPNCLASS])
					{
						case BF4_WEAPONCLASS_ASSAULTS:
							(team == BF4_TEAM_US) ? set_msg_arg_string(4, "m4a1") :	set_msg_arg_string(4, "ak47");
						case BF4_WEAPONCLASS_SNIPERS:
							set_msg_arg_string(4, "awp");
						case BF4_WEAPONCLASS_SMGS:
							set_msg_arg_string(4, "mp5navy");
						case BF4_WEAPONCLASS_LMGS:
							set_msg_arg_string(4, "m249");
						case BF4_WEAPONCLASS_DMRS:
							(team == BF4_TEAM_US) ? set_msg_arg_string(4, "sg550") : set_msg_arg_string(4, "g3sg1");
					}
				}
			}
	}

	return PLUGIN_CONTINUE;
}

public BF4ForwardClassChanged(id)
{
	for(new i = 0; i <= EQUIP; i++)
		gStackUseWeapons[id][i] = -1;

//	client_print_color(id, print_team_default, "^4[BF4 DEBUG] ^3Class Changed");
}

public BF4ForwardTeamChanged(id)
{
	for(new i = 0; i <= EQUIP; i++)
		gStackUseWeapons[id][i] = -1;
	// client_print_color(id, print_team_default, "^4[BF4 DEBUG] ^3Team Changed");
}

public BF4GiveWeapon(id)
{
	new data[BF4_WEAPON_DATA];
	for(new i = 0; i < ArraySize(gWeaponList); i++)
	{
		ArrayGetArray(gWeaponList, i, data, sizeof(data));
		if (data[TEAM] == BF4GetUserTeam(id) || data[TEAM] & BF4_TEAM_BOTH)
		{
			if ((data[HASCLASS] & BF4GetUserClass(id)) && (data[HASCLASS] & BF4_CLASS_REQUIRE))
			{
				// client_print(id, print_chat, "[BF4 DEBUG] %s", data[NAME]);
				gUseWeapons[id][GetWeaponSlot(data[WPNCLASS])] = i;
			}
		}
	}

	for(new i = 0; i <= EQUIP; i++)
	{
		if (gUseWeapons[id][i] > -1)
		{
			ArrayGetArray(gWeaponList, gUseWeapons[id][i], data, sizeof(data));
			if (data[CSWM_ID] > -1)
			{
				GiveWeaponByID(id, data[CSWM_ID]);
			} else {
//				client_print(id, print_chat, "[BF4 DEBUG] %s", data[ITEM]);
				give_item(id, fmt("weapon_%s", data[ITEM]));
			}
			GiveAmmo(id, _:data[AMMO_ID], 900);
		}
	}

	cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
}

stock GetWeaponSlot(BF4_WEAPONCLASS:class)
{
	switch(class)
	{
		case BF4_WEAPONCLASS_PISTOLS:	return SECONDARY;
		case BF4_WEAPONCLASS_ASSAULTS:	return PRIMARY;
		// case BF4_WEAPONCLASS_CARBINS:return PRIMARY;
		case BF4_WEAPONCLASS_SNIPERS:	return PRIMARY;
		// case BF4_WEAPONCLASS_PDWS:	return PRIMARY;
		case BF4_WEAPONCLASS_LMGS:		return PRIMARY;
		case BF4_WEAPONCLASS_DMRS:		return PRIMARY;
		case BF4_WEAPONCLASS_SMGS:		return PRIMARY;
		case BF4_WEAPONCLASS_SHOTGUNS:	return PRIMARY;
		case BF4_WEAPONCLASS_MELEE:		return MELEE;
		case BF4_WEAPONCLASS_GRENADE:	return GRENADE;
		case BF4_WEAPONCLASS_EQUIP:		return EQUIP;
		case BF4_WEAPONCLASS_EXTRA:		return EXTRAITEM;
	}
	return EXTRAITEM;
}
