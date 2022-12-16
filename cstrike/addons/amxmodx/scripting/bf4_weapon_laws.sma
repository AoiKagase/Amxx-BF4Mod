#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <bf4natives>
#include <bf4classes>
#include <bf4weapons>
#include <reapi>
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

static const PLUGIN_NAME	[] 			= "[BF4 Weapons] LAW";
static const PLUGIN_AUTHOR	[] 			= "Aoi.Kagase";
static const PLUGIN_VERSION	[]			= "0.1";

#define AMMOBOX_INTERVAL				1.0
#define TASK_DROP						1250

#define ITEM_OWNER 						pev_iuser1
#define ITEM_TEAM  						pev_iuser2

enum _:E_SOUNDS
{
	SOUND_BOUNCE,
	SOUND_DISCARD,
	SOUND_DRAW,
	SOUND_EXPLODE,
	SOUND_FIRE,
	SOUND_TRAVEL,
};

enum _:E_MODELS
{
	V_WPN,
	P_WPN,
	W_WPN,
	ROCKET,
};

enum _:E_MESSAGES
{
	MSG_CURWEAPON,
	MSG_BARTIME,
	MSG_SCREEN_FADE,
	MSG_STATUS_ICON,
	MSG_CLCORPSE,
	MSG_WEAPONLIST,
	MSG_SCREEN_SHAKE,
	MSG_TEXTMSG,
}

enum _:E_SEQUENCE
{
	SEQ_IDLE,
	SEQ_DRAW,
	SEQ_SHOOT,
	SEQ_DISCARD,
}

enum _:E_THINK
{
	THINK_IDLE,
	THINK_DRAW,
	THINK_SHOOT,
	THINK_DISCARD,
}

new const MESSAGES[E_MESSAGES][] = 
{
	"CurWeapon",
	"BarTime",
	"ScreenFade",
	"StatusIcon",
	"ClCorpse",
	"WeaponList",
	"ScreenShake",
	"TextMsg",
};

new const ENT_MODELS[E_MODELS][] = 
{
	"models/bf4_ranks/weapons/v_law.mdl",
	"models/bf4_ranks/weapons/p_law.mdl",
	"models/bf4_ranks/weapons/w_law.mdl",
	"models/bf4_ranks/weapons/lawrocket.mdl",
};

new const ENT_SOUNDS[E_SOUNDS][] = 
{
	"bf4_ranks/weapons/law_bounce.wav",
	"bf4_ranks/weapons/law_discard.wav",
	"bf4_ranks/weapons/law_draw.wav",
	"bf4_ranks/weapons/law_explode.wav",
	"bf4_ranks/weapons/law_fire.wav",
	"bf4_ranks/weapons/law_travel.wav",
};

new const ENT_CLASS_C4[]		= "weapon_c4";
new const ENT_CLASS_BREAKABLE[] = "func_breakable";
new const ENT_CLASS_ROCKET[]	= "laws_rocket";

new g_msg_data		[E_MESSAGES];

new gObjectItem		[MAX_PLAYERS + 1];
new gWpnSystemId;
new gWpnThinkStatus	[MAX_PLAYERS + 1];

new SprTrail, SprExplode, SprRing;
//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	for (new i = 0; i < E_SOUNDS; i++)
		precache_sound(ENT_SOUNDS[i]);

	for (new i = 0; i < E_MODELS; i++) 
		precache_model(ENT_MODELS[i]);

	precache_generic("sprites/bf4_ranks/weapons/weapon_laws.txt");
	precache_generic("sprites/bf4_ranks/weapons/czr_640hud18.spr");
	precache_generic("sprites/bf4_ranks/weapons/czr_640hud19.spr");
	precache_generic("sprites/bf4_ranks/weapons/czr_640hud7.spr");

	gWpnSystemId = BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_EQUIP, 
		-1,
		"LAWS",
		"c4",
		_:Ammo_C4,
		"laws",
		5,
		5
	);

	SprExplode	= precache_model("sprites/zerogxplode.spr");
	SprRing 	= precache_model("sprites/shockwave.spr");
	SprTrail 	= precache_model("sprites/smoke.spr");

	return PLUGIN_CONTINUE;
}

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin		(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_cvar		(PLUGIN_NAME, PLUGIN_VERSION, FCVAR_SPONLY|FCVAR_SERVER);

	// Register Forward.
	register_forward	(FM_CmdStart,								"PlayerCmdStart");
	RegisterHamPlayer	(Ham_Spawn, 								"PlayerSpawn", 	.Post = true);

/// =======================================================================================
/// START Custom Weapon Defibrillator
/// =======================================================================================
    register_clcmd		("bf4_ranks/weapons/weapon_laws", 	"SelectLaws");
    RegisterHam			(Ham_Item_AddToPlayer, 		ENT_CLASS_C4, 	"OnAddToPlayerC4", 	.Post = true);
	RegisterHam			(Ham_Item_ItemSlot, 		ENT_CLASS_C4, 	"OnItemSlotC4");
	RegisterHam			(Ham_Item_Deploy, 			ENT_CLASS_C4, 	"OnSetModels",			.Post = true);
	RegisterHam			(Ham_Weapon_PrimaryAttack, 	ENT_CLASS_C4, 	"OnPrimaryAttackPre");
	RegisterHam			(Ham_Weapon_PrimaryAttack, 	ENT_CLASS_C4, 	"OnPrimaryAttackPost",	.Post = true);
	RegisterHamPlayer	(Ham_Think,					"WeaponThink",			.Post = true);
//	RegisterHam			(Ham_Weapon_SecondaryAttack,ENT_CLASS_C4, 	"OnSecondaryAttackPre");
//	register_forward	(FM_EmitSound, 				"KnifeSound");
//	register_event		("CurWeapon", "weapon_change", "be", "1=1");
/// =======================================================================================
/// END Custom Weapon Defibrillator
/// =======================================================================================

/// =======================================================================================
/// START HealthKit
/// =======================================================================================
	RegisterHam			(Ham_Touch, 				ENT_CLASS_BREAKABLE, 			"BF4ObjectThink");
/// =======================================================================================
/// END HealthKit
/// =======================================================================================

	for(new i = 0; i < E_MESSAGES; i++)
		g_msg_data[i] = get_user_msgid(MESSAGES[i]);

	register_message(g_msg_data[MSG_TEXTMSG], "Message_TextMsg") ;
}

public Message_TextMsg(iMsgId, iMsgDest, id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE;
	
	if (!BF4HaveThisWeapon(id, gWpnSystemId))
		return PLUGIN_CONTINUE;

	new szMessage[64];
	get_msg_arg_string(2, szMessage, charsmax(szMessage));
	if (equali(szMessage, "#C4_Plant_At_Bomb_Spot"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}
/// =======================================================================================
/// START Custom Weapon Defibrillator
/// =======================================================================================
public OnAddToPlayerC4(const item, const player)
{
    if(pev_valid(item) && is_user_alive(player)) 	// just for safety.
    {
		if (!BF4HaveThisWeapon(player, gWpnSystemId))
			return PLUGIN_CONTINUE;

        message_begin( MSG_ONE, g_msg_data[MSG_WEAPONLIST], .player = player );
        {
            write_string("bf4_ranks/weapons/weapon_laws");   // WeaponName
            write_byte(14);                   		// PrimaryAmmoID
            write_byte(1);                   		// PrimaryAmmoMaxAmount
            write_byte(-1);                   		// SecondaryAmmoID
            write_byte(-1);                   		// SecondaryAmmoMaxAmount
            write_byte(4);                    		// SlotID (0...N)
            write_byte(3);                    		// NumberInSlot (1...N)
            write_byte(CSW_C4); 	           		// WeaponID
            write_byte(0);                    		// Flags
        }
        message_end();
    }
	return PLUGIN_CONTINUE;
}

public weapon_change(id)
{
	if (!is_user_alive(id))
		return;
	if (is_user_bot(id))
		return;
	if (!BF4HaveThisWeapon(id, gWpnSystemId))
		return;
	new clip, ammo;
	if (cs_get_user_weapon(id, clip, ammo) != CSW_C4)
	{
		if (task_exists(TASK_DROP + id))
		{
			emit_sound(id, CHAN_WEAPON, "bf4_ranks/weapons/briefcase_use.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			remove_task(TASK_DROP + id);
		}
	}
}

public SelectLaws(const client) 
{ 
	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return PLUGIN_CONTINUE;

    engclient_cmd(client, "weapon_c4"); 
	return PLUGIN_CONTINUE;
} 

public OnItemSlotC4(const item)
{
	static client;
	client = get_member(item, m_pPlayer);

	if (is_user_alive(client))
	{
		if (!BF4HaveThisWeapon(client, gWpnSystemId))
			return HAM_IGNORED;

	    SetHamReturnInteger(3);
	}

    return HAM_SUPERCEDE;
}

public OnSetModels(const Weapon)
{
	if (pev_valid(Weapon) != 2)
		return PLUGIN_CONTINUE;

	static client; 	client = get_member(Weapon, m_pPlayer);

	if (!is_user_alive(client))
		return PLUGIN_CONTINUE;
	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return PLUGIN_CONTINUE;
	if (get_pdata_cbase(client, 373) != Weapon)
		return PLUGIN_CONTINUE;

	set_pev(client, pev_viewmodel2, 	ENT_MODELS[V_WPN]);
	set_pev(client, pev_weaponmodel2, 	ENT_MODELS[P_WPN]);	

	gWpnThinkStatus[client] = THINK_DRAW;
	UTIL_PlayWeaponAnimation(client, SEQ_DRAW);

	set_pev(client, pev_nextthink, get_gametime());
	// UTIL_PlayWeaponAnimation(client, SEQ_DRAW);
	// set_member(Weapon, m_Weapon_flTimeWeaponIdle, 3.1);
	// set_pev(Weapon, pev_nextthink, get_gametime() + 3.1);

	return HAM_SUPERCEDE;
}

public OnPrimaryAttackPre(Weapon)
{
	static client; client = get_member(Weapon, m_pPlayer);

	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return HAM_IGNORED;
	
	if(get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	if (gWpnThinkStatus[client] != THINK_IDLE)
		return HAM_IGNORED;

	// UTIL_PlayWeaponAnimation(client, SEQ_SHOOT);
	// gWpnThinkStatus[client] = THINK_SHOOT;
	return HAM_SUPERCEDE;
}
#define m_flNextPrimaryAttack			46
#define m_flNextSecondaryAttack			47
public OnPrimaryAttackPost(Weapon)
{
	static client; client = get_member(Weapon, m_pPlayer);

	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return HAM_IGNORED;

	if(get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	// set_pev(Weapon, pev_nextthink, get_gametime() + 1.1);
	// gWpnThinkStatus[client] = THINK_DISCARD;

	set_pdata_float(Weapon, m_flNextPrimaryAttack, 999.9);
	return HAM_IGNORED;
}

public WeaponThink(client)
{
	// Not alive
	if(!is_user_alive(client) || is_user_bot(client))
		return HAM_IGNORED;

	if (get_user_weapon(client) != CSW_C4) 
		return HAM_IGNORED;

	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return HAM_IGNORED;

	new Weapon = cs_get_user_weapon_entity(client);
//	new client = get_member(Weapon, m_pPlayer);
	client_print(client, print_chat, "[LAWS] STATUS=%d", gWpnThinkStatus[client]);

	switch(gWpnThinkStatus[client])
	{
		case THINK_DRAW:
		{
			if (cs_get_user_bpammo(client, CSW_C4) <= 0)
			{
				ExecuteHam(Ham_Weapon_RetireWeapon, cs_get_user_weapon_entity(client));			
				set_pev(client, pev_nextthink, get_gametime() + 0.1);
				return HAM_IGNORED;
			}
			if (get_gametime() > Float:pev(client, pev_nextthink))
			{
				if (pev(client, pev_weaponanim) != SEQ_DRAW)
					UTIL_PlayWeaponAnimation(client, SEQ_DRAW);
				gWpnThinkStatus[client] = THINK_IDLE;
				set_member(Weapon, m_Weapon_flTimeWeaponIdle, 3.1);
				set_pev(client, pev_nextthink, get_gametime() + 3.1);
				return HAM_IGNORED;
			}
		}
		case THINK_IDLE:
		{
			if (get_gametime() > Float:pev(client, pev_nextthink))
				UTIL_PlayWeaponAnimation(client, SEQ_IDLE);
			set_pev(client, pev_nextthink, get_gametime() + 0.1);
		}
		case THINK_SHOOT:
		{
			set_pev(client, pev_nextthink, get_gametime() + 1.1);
			gWpnThinkStatus[client] = THINK_DISCARD;
			cs_set_user_bpammo(client, CSW_C4, max(cs_get_user_bpammo(client, CSW_C4) - 1, 0));
			BF4SpawnEntity(client);
			return HAM_IGNORED;
		}
		case THINK_DISCARD:
		{
			if (get_gametime() > Float:pev(client, pev_nextthink))
			{
				if (pev(client, pev_weaponanim) != SEQ_DISCARD)
					UTIL_PlayWeaponAnimation(client, SEQ_DISCARD);
				gWpnThinkStatus[client] = THINK_DRAW;
				set_pev(client, pev_nextthink, get_gametime() + 1.7);
				return HAM_IGNORED;
			}
		}
	}
	set_pev(client, pev_nextthink, get_gametime() + 0.1);

	return HAM_IGNORED;
}

public PlayerSpawn(id)
{
	if (!is_user_connected(id))
		return HAM_IGNORED;
	
	if (is_user_bot(id))
		return HAM_IGNORED;

	if (is_user_alive(id) && pev(id, pev_flags) & (FL_CLIENT))
	{
		if (!BF4HaveThisWeapon(id, gWpnSystemId))
			return HAM_IGNORED;

//		give_item(id, "weapon_c4");
		cs_set_user_bpammo(id, CSW_C4, 5);
	}
	return HAM_IGNORED;
}

public OnSecondaryAttackPre(Weapon)
{
	return HAM_SUPERCEDE;
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence);
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player);
	write_byte(Sequence);
	write_byte(pev(Player, pev_body));
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
		engfunc(EngFunc_SetModel, iEnt, ENT_MODELS[ROCKET]);
		// set solid.
		set_pev(iEnt, pev_solid, 		SOLID_TRIGGER);
		// set movetype.
		set_pev(iEnt, pev_movetype, 	MOVETYPE_FLYMISSILE);

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
		set_pev(iEnt, pev_classname, 	ENT_CLASS_ROCKET);
		// set take damage.
		set_pev(iEnt, pev_takedamage, 	DAMAGE_YES);
		set_pev(iEnt, pev_sequence, 	0); // IDLE.
		set_pev(iEnt, pev_dmg, 			100.0);
		// set entity health.
		set_pev(iEnt, pev_health,		50.0);
		// Vector settings.
		new Float:vOrigin	[3],
			Float:vVelocity	[3],
			Float:vViewOfs	[3],
			Float:vAngles	[3];

		// get user position.
		pev(id, pev_origin, vOrigin);
		pev(id, pev_view_ofs, vViewOfs);
		xs_vec_add(vOrigin, vViewOfs, vOrigin);  	
		// set entity position.
		engfunc(EngFunc_SetOrigin, iEnt, vOrigin );

		// Set Angles.
		pev(id, pev_v_angle, vAngles);
		vAngles[0] = -vAngles[0];
		set_pev(iEnt, pev_angles, vAngles);

		velocity_by_aim(id, 1500, vVelocity);
//		xs_vec_mul_scalar(vVelocity, 5000.0, vVelocity);
		// set size.
		engfunc(EngFunc_SetSize, iEnt, Float:{ -0.1, -0.1, -0.1 }, Float:{ 0.1, 0.1, 0.1 } );
		set_pev(iEnt, pev_velocity,		vVelocity);

		set_pev(iEnt, pev_rendermode, 	kRenderNormal);
		// set_pev(iEnt, pev_renderamt, 	5.0);

		// Save results to be used later.
		set_pev(iEnt, ITEM_TEAM,	BF4GetUserTeam(id));
		// think rate. hmmm....
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.1);

		emit_sound(iEnt, CHAN_ITEM, ENT_SOUNDS[SOUND_TRAVEL], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

		new iColor[3];
		iColor[0] = 224;
		iColor[1] = 224;
		iColor[2] = 224;

		EffectTrail(iEnt, iColor);
	}
}

public BF4ObjectThink(iEnt, iToucher)
{
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	new iOwner, flags;
	iOwner = pev(iEnt, pev_owner);

	if (is_user_alive(iOwner))
	{
		if (iToucher == iOwner)
			return HAM_IGNORED;
	}

	new Float:vOrigin[3];
	new Float:radius = 250.0;
	new Float:damage = 450.0;

	pev(iEnt, pev_origin, vOrigin);

	EffectCreateExplostion(vOrigin, SprExplode);
	EffectSylinder(vOrigin);

	new victim = -1;
	new Float:fOrigin[3], Float:fDistance, Float:fDamage;
	new attacker = pev(iEnt, pev_owner);
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, vOrigin, radius)) != 0)
	{
		if(!is_user_alive(victim)) 
			continue; //not alive
		if(BF4GetUserTeam(attacker) == BF4GetUserTeam(victim))
			continue; //friendly fire

		//damage calculation
		pev(victim, pev_origin, fOrigin);
		fDistance = get_distance_f(fOrigin, vOrigin);
		fDamage = damage - floatmul(damage, floatdiv(fDistance, radius));
		fDamage *= 1.0;

		EffectScreenShake(victim);

		xs_vec_sub(fOrigin, vOrigin, fOrigin);
		xs_vec_mul_scalar(fOrigin, fDamage * 0.7, fOrigin);
		xs_vec_mul_scalar(fOrigin, damage / xs_vec_len(fOrigin), fOrigin);
		set_pev(victim, pev_velocity, fOrigin);

		ExecuteHamB(Ham_TakeDamage, victim, iEnt, attacker, fDamage, DMG_BULLET);
	}

	pev(iEnt, pev_flags, flags);
	set_pev(iEnt, pev_flags, flags | FL_KILLME);
	dllfunc(DLLFunc_Think, iEnt);

	return HAM_IGNORED;
}

//====================================================
// Player Cmd Start event.
// Stop movement for mine deploying.
//====================================================
public PlayerCmdStart(id, handle, random_seed)
{
	// Not alive
	if(!is_user_alive(id) || is_user_bot(id))
		return FMRES_IGNORED;

	if (!BF4HaveThisWeapon(id, gWpnSystemId))
		return HAM_IGNORED;

	// Get user old and actual buttons
	static buttons, buttonsChanged, buttonPressed, buttonReleased;
    buttons 		= get_uc(handle, UC_Buttons);
    buttonsChanged 	= get_member(id, m_afButtonLast) ^ buttons;
    buttonPressed 	= buttonsChanged & buttons;
    buttonReleased 	= buttonsChanged & ~buttons;


	if (get_user_weapon(id) != CSW_C4) 
		return FMRES_IGNORED;

	if (buttonPressed & IN_ATTACK)
	{
		if (gWpnThinkStatus[id] == THINK_IDLE)
		{
			if (pev(id, pev_weaponanim) == SEQ_IDLE)
			{
				gWpnThinkStatus[id] = THINK_SHOOT;
				UTIL_PlayWeaponAnimation(id, SEQ_SHOOT);			
				set_pev(id, pev_nextthink, get_gametime());
			}
		}
//		set_member(id, m_Weapon_flTimeWeaponIdle, 1.1);
//		set_member(id, m_flNextAttack, 10.0);

		return FMRES_IGNORED;

	} else if (buttonReleased & IN_ATTACK) 
	{
		return FMRES_IGNORED;

	} else if (buttons & IN_ATTACK)
	{
		return FMRES_IGNORED;
	}
	return FMRES_IGNORED;
}

/// =======================================================================================
/// END Medikit for Ground
/// =======================================================================================

public client_putinserver(id)
{
}

public client_disconnected(id)
{
}

stock remove_target_entity_by_owner(id, const className[])
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

stock EffectCreateExplostion(Float:vOrigin[3], SprExplode)
{
	//explosion
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vOrigin[0]);
	engfunc(EngFunc_WriteCoord, vOrigin[1]);
	engfunc(EngFunc_WriteCoord, vOrigin[2]);
	write_short(SprExplode);
	write_byte(30);
	write_byte(30);
	write_byte(10);
	message_end();
}

stock EffectScreenShake(victim)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msg_data[MSG_SCREEN_SHAKE], _, victim);
	write_short((1<<12)*8);
	write_short((1<<12)*3);
	write_short((1<<12)*18);
	message_end();
}

stock EffectTrail(iEnt, iColor[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(iEnt);
	write_short(SprTrail);
	write_byte(10);
	write_byte(5);
	write_byte(iColor[0]);
	write_byte(iColor[1]);
	write_byte(iColor[2]);
	write_byte(192);
	message_end();
}

stock EffectSylinder(Float:vOrigin[3])
{
	//ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, vOrigin[0]);
	engfunc(EngFunc_WriteCoord, vOrigin[1]);
	engfunc(EngFunc_WriteCoord, vOrigin[2]);
	engfunc(EngFunc_WriteCoord, vOrigin[0]);
	engfunc(EngFunc_WriteCoord, vOrigin[1]);
	engfunc(EngFunc_WriteCoord, vOrigin[2]+500.0);
	write_short(SprRing);
	write_byte(0);
	write_byte(0);
	write_byte(5);
	write_byte(30);
	write_byte(0);
	write_byte(224);
	write_byte(224);
	write_byte(224);
	write_byte(255);
	write_byte(0);
	message_end();
}