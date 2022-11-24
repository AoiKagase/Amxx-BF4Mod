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
#include <csx>

#define PLUGIN 	"[BF4] Weapon System"
#define VERSION "0.1"
#define AUTHOR	"Aoi.Kagase"

enum WPN_CLASSIC_DATA
{
	CSC_NAME[64],
	CSC_ITEM[33],
	CSC_AMMOID,
	BF4_TEAM:CSC_TEAM,
	BF4_WEAPONCLASS:CSC_WPNCLASS,
	BF4_CLASS:CSC_HASCLASS,
};

enum _:BF4_WEAPON_DATA
{
	BF4_TEAM:TEAM,
	BF4_CLASS:HASCLASS,
	BF4_WEAPONCLASS:WPNCLASS,
	CSWM_ID,
	CSX_WPNID,
	AMMO_ID,
	NAME[64],
	ITEM[33],
	AMMONAME[33],
}

enum AMMO_LIST
{
	AmmoName[33],
	MaxAmmo,
}

// Classic Weapon Data.
// FullName, ItemName, AmmoId, Team, WeaponClass, Has Class
new const gWpnClassicItem[CSW_LAST_WEAPON + 1][WPN_CLASSIC_DATA] =
{
	{
		"",
		"",
		_:Ammo_None,
		BF4_TEAM_NONE,	
		BF4_WEAPONCLASS_NONE,		
		BF4_CLASS_NONE,
	},
	{
		"SIG SAUER P228",
		"p228",
		_:Ammo_357SIG,	
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"",
		"",
		_:Ammo_None,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_NONE,
		BF4_CLASS_NONE,
	},
	{
		"Steyr Scout",
		"scout",
		_:Ammo_762Nato,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SNIPERS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON
	},
	{
		"HE Grenade",
		"hegrenade",
		_:Ammo_HEGRENADE,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_GRENADE,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"Benelli M4 Super 90", 	
		"xm1014",
		_:Ammo_12Gauge,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SHOTGUNS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_ENGINEER
	},
	{
		"C4",
		"c4",
		_:Ammo_C4,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_EQUIP,
		BF4_CLASS_NONE,
	},
	{
		"Ingram Model 10",
		"mac10",
		_:Ammo_45ACP,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
	{
		"Steyr AUG",
		"aug",
		_:Ammo_556Nato,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"Smoke Grenade",
		"smokegrenade",
		_:Ammo_SMOKEGRENADE,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_GRENADE,
		BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"Dual 96G Elite Berettas", 
		"elite",
		_:Ammo_9MM,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"FN Five-seveN",
		"fiveseven",
		_:Ammo_57MM,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"H&K UMP45",
		"ump45",
		_:Ammo_45ACP,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
	{
		"SIG SG550",
		"sg550",
		_:Ammo_556Nato,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_DMRS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON
	},
	{
		"IMI Galil",
		"galil",
		_:Ammo_556Nato,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"NEXTER FA-MAS",
		"famas",
		_:Ammo_556Nato,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"H&K USP",
		"usp",
		_:Ammo_45ACP,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"GLOCK 18",
		"glock18",
		_:Ammo_9MM,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"AI L96A1 AWP",
		"awp",
		_:Ammo_338Magnum,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SNIPERS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON 
	},
	{
		"H&K MP5N",
		"mp5navy",
		_:Ammo_9MM,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
	{
		"FN M249",
		"m249",
		_:Ammo_556NatoBox,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_LMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_SUPPORT
	},
	{
		"Benelli M3",
		"m3",
		_:Ammo_12Gauge,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_SHOTGUNS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_ENGINEER
	},
	{
		"Colt M4A1",
		"m4a1",
		_:Ammo_556Nato,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"Steyr TMP",
		"tmp",
		_:Ammo_9MM,
		BF4_TEAM_US,
		BF4_WEAPONCLASS_SMGS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER
	},
	{
		"H&K G3SG/1",
		"g3sg1",
		_:Ammo_762Nato,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_DMRS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON
	},
	{
		"FLASHBANG",
		"flashbang",
		_:Ammo_FLASHBANG,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_GRENADE,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"IWI Deset Eagle .50AE",
		"deagle",
		_:Ammo_50AE,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_PISTOLS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER
	},
	{
		"SIG SG552",
		"sg552",
		_:Ammo_556Nato,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"Izhmash AK-47",
		"ak47",
		_:Ammo_762Nato,
		BF4_TEAM_RU,
		BF4_WEAPONCLASS_ASSAULTS,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT
	},
	{
		"KNIFE",
		"knife",
		_:Ammo_None,
		BF4_TEAM_BOTH,
		BF4_WEAPONCLASS_MELEE,
		BF4_CLASS_NONE,
	},
	{
		"FN P90",
		"p90",
		_:Ammo_57MM,
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
	register_clcmd("drop",				"InvalidDrop");
	RegisterHamPlayer(Ham_Spawn, 		"PlayerSpawnPre", false);
	RegisterHamPlayer(Ham_Spawn, 		"PlayerSpawn", true);
	RegisterHamPlayer(Ham_TakeDamage, 	"PlayerTakeDamagePre");
	RegisterHamPlayer(Ham_TakeDamage, 	"PlayerTakeDamagePost", true);

 	RegisterHam(Ham_Touch,	"weaponbox", "BF4TouchWeaponBox", 0);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228", 	"CustomPrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", 	"CustomPrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", 	"CustomPrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014", 	"CustomPrimaryAttack");

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
public InvalidDrop(id)
{
	return PLUGIN_HANDLED;
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
		if (is_user_bot(receiver))
			return PLUGIN_CONTINUE;
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
		weapon[CSX_WPNID]= -1;

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
	register_native("BF4WeaponNameToClass", "_native_weapon_name_to_class");
}

public plugin_end()
{
	ArrayDestroy(gWeaponList);
}
// const BF4_WEAPON_TEAM:team, const BF4_WEAPON_HAS_CLASS:has_class, const BF4_WEAPON_CLASS:wpn_class, const CSWM_id, const name[33], const item[33];
public _native_register_weapon(iPlugin, iParams)
{

	new name[33], item[33], ammo[33];
	get_string(5, name, charsmax(name));
	get_string(6, item, charsmax(item));
	get_string(8, ammo, charsmax(ammo));

	return RegisterWeapon(BF4_TEAM:get_param(1), BF4_CLASS:get_param(2), BF4_WEAPONCLASS:get_param(3), get_param(4), name, item, get_param(7), ammo);
}

public _native_select_weapon_menu(iPlugin, iParams)
{
	new id = get_param(1);
	BF4WeaponMenu(id);
}

RegisterWeapon(BF4_TEAM:team, BF4_CLASS:has_class, BF4_WEAPONCLASS:wpn_class, cswm_id, name[33], item[33], ammo_id, ammoname[33])
{
	new weapon[BF4_WEAPON_DATA];
	weapon[TEAM] 			= team;
	weapon[HASCLASS] 		= has_class;
	weapon[WPNCLASS]		= wpn_class;
	weapon[CSWM_ID] 		= cswm_id;
	weapon[AMMO_ID]			= ammo_id;
	weapon[NAME]			= name;
	weapon[ITEM]			= item;
	if (cswm_id > 0)
	{
		weapon[CSX_WPNID] 	= custom_weapon_add(weapon[NAME], 0, weapon[ITEM]);
		// console_print(0, "[BF4 DEBUG] REGISTER %d CSXID %d %s", cswm_id, weapon[CSX_WPNID], weapon[NAME]);
	}

	copy(weapon[AMMONAME], charsmax(weapon[AMMONAME]), ammoname);
	
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

public BF4_WEAPONCLASS:_native_weapon_name_to_class(iPlugin, iParams)
{
	new id = get_param(1);
	new weaponname[33];
	new data[BF4_WEAPON_DATA];

	get_string(2, weaponname, charsmax(weaponname));

	for(new i = 0; i <= EQUIP; i++)
	{
		if (gUseWeapons[id][i] <= -1)
			continue;

		ArrayGetArray(gWeaponList, gUseWeapons[id][i], data, charsmax(data));
		if (equali(data[ITEM], weaponname))
		{
			return data[WPNCLASS];
		}
	}
	return BF4_WEAPONCLASS_NONE;
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

	if (is_user_bot(id))
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
					ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][SECONDARY], data, sizeof(data));
					if (data[CSWM_ID] > -1)
						rg_set_iteminfo(weapon, ItemInfo_pszName, data[ITEM]);
				}
			case CSW_AK47, CSW_XM1014, CSW_AWP:
				if (gUseWeapons[iAttacker][PRIMARY] > -1)
				{
					ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][PRIMARY], data, sizeof(data));
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
		new data[BF4_WEAPON_DATA];
		switch(cswid)
		{
			case CSW_P228:
			{
				ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][SECONDARY], data, sizeof(data));
				if (data[CSWM_ID])
				{
					custom_weapon_dmg(data[CSX_WPNID], iAttacker, iVictim, floatround(damage), 0);
					rg_set_iteminfo(weapon, ItemInfo_pszName, "p228");
				}
			}
			case CSW_AK47:
			{
				ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][PRIMARY], data, sizeof(data));
				if (data[CSWM_ID])
				{
					custom_weapon_dmg(data[CSX_WPNID], iAttacker, iVictim, floatround(damage), 0);
					rg_set_iteminfo(weapon, ItemInfo_pszName, "ak47");
				}
			}
			case CSW_XM1014:
			{
				ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][PRIMARY], data, sizeof(data));
				if (data[CSWM_ID])
				{
					custom_weapon_dmg(data[CSX_WPNID], iAttacker, iVictim, floatround(damage), 0);
					rg_set_iteminfo(weapon, ItemInfo_pszName, "xm1014");
				}
			}
			case CSW_AWP:
			{
				ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][PRIMARY], data, sizeof(data));
				if (data[CSWM_ID])
				{
					custom_weapon_dmg(data[CSX_WPNID], iAttacker, iVictim, floatround(damage), 0);
					rg_set_iteminfo(weapon, ItemInfo_pszName, "awp");
				}
			}
		}
	}
}

public PlayerDeath()
{
	new iAttacker 	= get_msg_arg_int(1);

	if (!is_user_connected(iAttacker) || !is_user_alive(iAttacker))
		return PLUGIN_CONTINUE;
	
	new killweapon[33];
	new data[BF4_WEAPON_DATA];
	new BF4_TEAM:team = BF4GetUserTeam(iAttacker);
	get_msg_arg_string(4, killweapon, charsmax(killweapon));

	for(new i = 0; i <= EQUIP; i++)
	{
		if (gUseWeapons[iAttacker][i] <= -1)
			continue;

		ArrayGetArray(gWeaponList, gUseWeapons[iAttacker][i], data, charsmax(data));
		if (equali(data[ITEM], killweapon))
		{
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
				default:
				{
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
						case Ammo_C4:
							set_msg_arg_string(4, "c4");
					}
				}
			}
			break;
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
//			client_print(id, print_chat, "AmmoId: %d %s", data[AMMO_ID], data[AMMONAME]);
			GiveAmmo(id, data[AMMO_ID], 900);
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

// =====================================================================
// Weapon box pick up
// =====================================================================
public BF4TouchWeaponBox(iWpnBox, iToucher)
{
	// Player Check
	if (is_user_alive(iToucher))
	{
		// Get Weapon Box information.
		new bWeaponId, bAmmoName[33], bAmmo, bAmmoId;
		GetWeaponBoxInfo(iWpnBox, bWeaponId, bAmmo, bAmmoId, bAmmoName, charsmax(bAmmoName));

		new data[BF4_WEAPON_DATA];
		new pMaxAmmo, pAmmoName[33];

		// All Slot weapon.
		for(new i = 0; i <= EQUIP; i++)
		{
			if (gUseWeapons[iToucher][i] <= -1)
				continue;
			// Search for the weapon you currently have.
			ArrayGetArray(gWeaponList, gUseWeapons[iToucher][i], data, sizeof(data));

			// Is Custom Weapon.
			if (data[CSWM_ID] && bAmmoId > _:Ammo_C4)
			{
				// Get AmmoId, AmmoName, MaxAmmo
				// Use CS Weapon Mod Function.
				pAmmoName = data[AMMONAME];
			}
			else
			{
				// Is Default Weapon.
				// Use ReAPI Function.
				// AmmoName, MaxAmmo
				new iPWeapon = cs_get_user_weapon_entity(iToucher);
				GePlayerDefaultWeaponInfo(iPWeapon, pMaxAmmo, pAmmoName, charsmax(pAmmoName));
			}

			// WeaponBox AmmoName == PlayerWeapon AmmoName
			client_print_color(iToucher, print_team_default, "^4[BF4 DEBUG] ^1AmmoName - WeaponBox: %s, PlayerWeapon: %s", bAmmoName, pAmmoName);
			if (equali(bAmmoName, pAmmoName))
			{

				// Pick up Ammo.
				// ExecuteHam(Ham_GiveAmmo, this, amount, "type", max);
				if (data[CSWM_ID])
				{
					ExecuteHamB(Ham_GiveAmmo, iToucher, data[AMMO_ID], bAmmoName, pMaxAmmo);
					GiveAmmo(iToucher, data[AMMO_ID], bAmmo);
				}
				else
					ExecuteHamB(Ham_GiveAmmo, iToucher, bAmmo, bAmmoName, pMaxAmmo);
				emit_sound(iToucher, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

				// Remove Ammobox Entity.
				set_pev(iWpnBox, pev_flags, pev(iWpnBox, pev_flags) | FL_KILLME);
				return;
			}
		}
	}
}

// =====================================================================
// ReAPI: Get Weapon box Info
// =====================================================================
GetWeaponBoxInfo(iEnt, &iWeapon, &irgAmmo, &iAmmoId, iszAmmo[], length) 
{ 
    for(new i = 0; i < MAX_ITEM_TYPES; i++)
    {
		iWeapon 	= get_member(iEnt, m_WeaponBox_rgpPlayerItems, i);
		irgAmmo 	= get_member(iEnt, m_WeaponBox_rgAmmo, i);
		iAmmoId		= get_member(iEnt, m_WeaponBox_cAmmoTypes, i);
		get_member(iEnt, m_WeaponBox_rgiszAmmo, iszAmmo, length, i);
		if (!is_nullent(iWeapon))
			return;
    }
} 

// =====================================================================
// ReAPI: Get Default Weapon Info
// =====================================================================
GePlayerDefaultWeaponInfo(iEnt, &iMaxAmmo, szAmmo[], length)
{
	rg_get_iteminfo(iEnt, ItemInfo_pszAmmo1, szAmmo, length);
	iMaxAmmo = rg_get_iteminfo(iEnt, ItemInfo_iMaxAmmo1);
	return;
}

public CustomPrimaryAttack(iWpnId)
{
	new id = get_member(iWpnId, m_pPlayer);
	new wpnname[33];
	rg_get_iteminfo(iWpnId, ItemInfo_pszName, wpnname, charsmax(wpnname));
	if (is_user_alive(id))
	{
		new data[BF4_WEAPON_DATA];
		if (equali(wpnname, "p228"))
			ArrayGetArray(gWeaponList, gUseWeapons[id][SECONDARY], data, sizeof(data));
		else
			ArrayGetArray(gWeaponList, gUseWeapons[id][PRIMARY], data, sizeof(data));
		if (data[CSWM_ID] > -1 && data[CSX_WPNID] > -1)
		{
//			client_print_color(id, print_team_default, "^3[BF4 DEBUG] ^1SHOT %s", wpnname);
			custom_weapon_shot(data[CSX_WPNID], id);
		}
	}
}