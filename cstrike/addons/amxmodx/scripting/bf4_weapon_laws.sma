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
#include <csx>

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

#define ITEM_TEAM  						pev_iuser2
#define LAWS_THINK						pev_fuser1

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
	MSG_WEAPONLIST,
	MSG_SCREEN_SHAKE,
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

enum _:E_SPRITES_GEN
{
	SPR_WEAPONLIST,
	SPR_HUD1,
	SPR_HUD2,
	SPR_HUD3,
}

enum _:E_SPRITES_MDL
{
	SPR_EXPLODE,
	SPR_SHOCKWAVE,
	SPR_TRAIL,
}

new const MESSAGES[E_MESSAGES][] = 
{
	"WeaponList",
	"ScreenShake",
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

new const ENT_SPRITES_GEN[E_SPRITES_GEN][] =
{
	"sprites/bf4_ranks/weapons/weapon_laws.txt",
	"sprites/bf4_ranks/weapons/czr_640hud18.spr",
	"sprites/bf4_ranks/weapons/czr_640hud19.spr",
	"sprites/bf4_ranks/weapons/czr_640hud7.spr",
};

new const ENT_SPRITES_MDL[E_SPRITES_MDL][] =
{
	"sprites/zerogxplode.spr",
	"sprites/shockwave.spr",
	"sprites/smoke.spr",
};

new const ENT_CLASS_C4[]		= "weapon_c4";
new const ENT_CLASS_BREAKABLE[] = "func_breakable";
new const ENT_CLASS_ROCKET[]	= "laws_rocket";

new g_msg_data		[E_MESSAGES];

new gWpnSystemId;
new gCSXID;
new gWpnThinkStatus	[MAX_PLAYERS + 1];
new gSprites		[E_SPRITES_MDL];

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	for (new i = 0; i < E_SOUNDS; i++)
		precache_sound(ENT_SOUNDS[i]);

	for (new i = 0; i < E_MODELS; i++) 
		precache_model(ENT_MODELS[i]);

	for (new i = 0; i < E_SPRITES_GEN; i++) 
		precache_generic(ENT_SPRITES_GEN[i]);

	for (new i = 0; i < E_SPRITES_MDL; i++) 
		gSprites[i] = precache_model(ENT_SPRITES_MDL[i]);

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

	return PLUGIN_CONTINUE;
}

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin		(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_cvar		(PLUGIN_NAME, PLUGIN_VERSION, FCVAR_SPONLY|FCVAR_SERVER);


/// =======================================================================================
/// START Custom Weapon LAWS
/// =======================================================================================
    register_clcmd		("bf4_ranks/weapons/weapon_laws", 			"SelectLaws");
    RegisterHam			(Ham_Item_AddToPlayer, 		ENT_CLASS_C4, 	"OnAddToPlayerC4", 	.Post = true);
	RegisterHam			(Ham_Item_ItemSlot, 		ENT_CLASS_C4, 	"OnItemSlotC4");
	RegisterHam			(Ham_Item_Deploy, 			ENT_CLASS_C4, 	"OnSetModels",			.Post = true);
	RegisterHam			(Ham_Item_PostFrame,		ENT_CLASS_C4,	"WeaponThink",	.Post = true);
	RegisterHam			(Ham_Weapon_PrimaryAttack, 	ENT_CLASS_C4, 	"OnPrimaryAttackPre");
	RegisterHam			(Ham_Weapon_PrimaryAttack, 	ENT_CLASS_C4, 	"OnPrimaryAttackPost",	.Post = true);
/// =======================================================================================
/// END Custom Weapon LAWS
/// =======================================================================================

	// Register Forward.
	RegisterHamPlayer	(Ham_Spawn, 			"PlayerSpawn", 	.Post = true);
	register_forward	(FM_CmdStart,			"PlayerCmdStart");
	register_forward	(FM_UpdateClientData, 	"OnUpdateClientDataPost", ._post = true);
/// =======================================================================================
/// START ROCKET
/// =======================================================================================
	RegisterHam			(Ham_Touch, 				ENT_CLASS_BREAKABLE, 			"BF4ObjectThink");
/// =======================================================================================
/// END ROCKET
/// =======================================================================================

	for(new i = 0; i < E_MESSAGES; i++)
		g_msg_data[i] = get_user_msgid(MESSAGES[i]);

	gCSXID = custom_weapon_add("weapon_laws", 0, "LAWS");		
}

stock bool:SafetyCheck(const client, const weapon, const noweaponcheck = 0)
{
	if (!noweaponcheck && !pev_valid(weapon))
		return false;

	if (is_user_bot(client))
		return false;

	if (!is_user_alive(client))
		return false;

	if (!noweaponcheck && (cs_get_user_weapon(client) != CSW_C4))
		return false;

	if (!BF4HaveThisWeapon(client, gWpnSystemId))
		return false;

	if (!noweaponcheck && (get_pdata_cbase(client, 373) != weapon))
		return false;

	return true;
}
/// =======================================================================================
/// START Custom Weapon LAWS
/// =======================================================================================
public OnAddToPlayerC4(const item, const player)
{
	if (!SafetyCheck(player, item, 1))
		return PLUGIN_CONTINUE;

	message_begin( MSG_ONE, g_msg_data[MSG_WEAPONLIST], .player = player );
	{
		write_string("bf4_ranks/weapons/weapon_laws");   // WeaponName
		write_byte(14);                   		// PrimaryAmmoID
		write_byte(1);                   		// PrimaryAmmoMaxAmount
		write_byte(-1);                   		// SecondaryAmmoID
		write_byte(-1);                   		// SecondaryAmmoMaxAmount
		write_byte(2);                    		// SlotID (0...N)
		write_byte(1);                    		// NumberInSlot (1...N)
		write_byte(CSW_C4); 	           		// WeaponID
		write_byte(0);                    		// Flags
	}
	message_end();

	return PLUGIN_CONTINUE;
}

///
/// Select Weapon.
///
public SelectLaws(const client) 
{ 
	if (!SafetyCheck(client, 0, 1))
		return PLUGIN_CONTINUE;

    engclient_cmd(client, "weapon_c4"); 
	return PLUGIN_CONTINUE;
} 

///
/// Slot Change.
///
public OnItemSlotC4(const item)
{
	static client;
	client = get_member(item, m_pPlayer);

	if (!SafetyCheck(client, 0, 1))
		return HAM_IGNORED;

    SetHamReturnInteger(3);
    return HAM_SUPERCEDE;
}

///
/// Change Models.
///
public OnSetModels(const Weapon)
{
	static client; client = get_member(Weapon, m_pPlayer);
	if (!SafetyCheck(client, Weapon))
		return HAM_IGNORED;

	// Change Models.
	set_pev(client, pev_viewmodel2, 	ENT_MODELS[V_WPN]);
	set_pev(client, pev_weaponmodel2, 	ENT_MODELS[P_WPN]);	

	// Draw.
	gWpnThinkStatus[client] = THINK_DRAW;
	UTIL_PlayWeaponAnimation(client, SEQ_DRAW);

	set_pev(Weapon, LAWS_THINK, get_gametime());
	return HAM_IGNORED;
}

public OnUpdateClientDataPost(Player, SendWeapons, CD_Handle)
{
	if (!SafetyCheck(Player, cs_get_user_weapon_entity(Player)))
		return FMRES_IGNORED;

	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001);
	return FMRES_HANDLED;
}

///
/// Blocking Attack logic.
///
public OnPrimaryAttackPre(Weapon)
{
	static client; client = get_member(Weapon, m_pPlayer);
	if (!SafetyCheck(client, Weapon))
		return HAM_IGNORED;

	return HAM_SUPERCEDE;
}

public OnPrimaryAttackPost(Weapon)
{
	static client; client = get_member(Weapon, m_pPlayer);
	if (!SafetyCheck(client, Weapon))
		return HAM_IGNORED;

	return HAM_SUPERCEDE;
}

/// ===================================
/// WEAPON THINK.
/// ===================================
public WeaponThink(Weapon)
{
	/// SAFETY LOGIC.
	/// ===================================
	new client = get_member(Weapon, m_pPlayer);
	if (!SafetyCheck(client, Weapon))
		return HAM_IGNORED;

	/// LAWS STATUS LOGIC.
	/// ===================================
	static Float:fThink; pev(Weapon, LAWS_THINK, fThink); 
	static Float:fNow; fNow = get_gametime();

	switch(gWpnThinkStatus[client])
	{
		case THINK_DRAW:
		{
			if (fNow > fThink)
			{
				// RETIRED.
				if (cs_get_user_bpammo(client, CSW_C4) <= 0)
				{
					ExecuteHam(Ham_Weapon_RetireWeapon, cs_get_user_weapon_entity(client));			
					set_pev(Weapon, LAWS_THINK, fNow + 0.1);
					return HAM_IGNORED;
				}
				// PLAY DRAW ANIMATION.
				if (pev(client, pev_weaponanim) != SEQ_DRAW)
					UTIL_PlayWeaponAnimation(client, SEQ_DRAW);

				// NEXT THINK.
				gWpnThinkStatus[client] = THINK_IDLE;

				// DRAW ANIMATION IS 3.1 sec.
				set_member(Weapon, m_Weapon_flTimeWeaponIdle, 3.1);
				set_pev(Weapon, LAWS_THINK, fNow + 3.1);
			}
		}
		case THINK_IDLE:
		{
			// CHECK PREVIOUS STATUS.
			if (fNow > fThink)
			{
				// PLAY IDLE ANIMATION.
				UTIL_PlayWeaponAnimation(client, SEQ_IDLE);
				set_pev(Weapon, LAWS_THINK, fNow + 1.0);
			}
		}
		case THINK_SHOOT:
		{
			// SHOOT.
			custom_weapon_shot(gCSXID, client);

			// NEXT THINK.
			gWpnThinkStatus[client] = THINK_DISCARD;

			// USE AMMO.
			cs_set_user_bpammo(client, CSW_C4, max(cs_get_user_bpammo(client, CSW_C4) - 1, 0));

			// CREATE ROCKET.
			BF4SpawnEntity(client);

			// SHOOT ANIMATION IS 1.1 sec.
			set_pev(Weapon, LAWS_THINK, fNow + 1.1);
		}
		case THINK_DISCARD:
		{
			// CHECK PREVIOUS STATUS.
			if (fNow > fThink)
			{
				// PLAY DISCARD ANIMATION.
				if (pev(client, pev_weaponanim) != SEQ_DISCARD)
					UTIL_PlayWeaponAnimation(client, SEQ_DISCARD);
				
				// NEXT THINK.
				gWpnThinkStatus[client] = THINK_DRAW;

				// DISCARD ANIMATION IS 1.7 sec.
				set_pev(Weapon, LAWS_THINK, fNow + 1.7);
			}
		}
	}
	return HAM_IGNORED;
}

public PlayerSpawn(id)
{
	/// SAFETY LOGIC.
	if (!SafetyCheck(id, 0, 1))
		return HAM_IGNORED;

	// GIVE WEAPON. (The first one is given in BF4WeaponSystem.)
	// TODO:Set 5 Ammo.
//	give_item(id, "weapon_c4");
	cs_set_user_bpammo(id, CSW_C4, 5);

	return HAM_IGNORED;
}
/// =======================================================================================
/// END Custom Weapon LAWS
/// =======================================================================================

/// =======================================================================================
/// START Rocket
/// =======================================================================================
BF4SpawnEntity(id)
{
	new iEnt = cs_create_entity(ENT_CLASS_BREAKABLE);
	if (pev_valid(iEnt))
	{
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

	new classname[MAX_NAME_LENGTH];
	pev(iEnt, pev_classname, classname, charsmax(classname));

	if (!equali(classname, ENT_CLASS_ROCKET))
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

	EffectCreateExplostion(iEnt, vOrigin, gSprites[SPR_EXPLODE]);
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

		custom_weapon_dmg(gCSXID, attacker, victim, floatround(fDamage), 0);
		ExecuteHamB(Ham_TakeDamage, victim, iEnt, attacker, fDamage, DMG_BULLET);
	}

	pev(iEnt, pev_flags, flags);
	set_pev(iEnt, pev_flags, flags | FL_KILLME);
	dllfunc(DLLFunc_Think, iEnt);

	return HAM_IGNORED;
}

//====================================================
// Player Cmd Start event.
//====================================================
public PlayerCmdStart(id, handle, random_seed)
{
	if (!SafetyCheck(id, cs_get_user_weapon_entity(id)))
		return FMRES_IGNORED;

	// Get user old and actual buttons
	static buttons, buttonsChanged, buttonPressed, buttonReleased;
    buttons 		= get_uc(handle, UC_Buttons);
    buttonsChanged 	= get_member(id, m_afButtonLast) ^ buttons;
    buttonPressed 	= buttonsChanged & buttons;
    buttonReleased 	= buttonsChanged & ~buttons;

	if (buttonPressed & IN_ATTACK)
	{
		if (gWpnThinkStatus[id] == THINK_IDLE)
		{
			if (pev(id, pev_weaponanim) == SEQ_IDLE)
			{
				new Weapon = cs_get_user_weapon_entity(id);
				gWpnThinkStatus[id] = THINK_SHOOT;
				UTIL_PlayWeaponAnimation(id, SEQ_SHOOT);			
				set_pev(Weapon, LAWS_THINK, get_gametime());
			}
		}
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
/// END CmdStart.
/// =======================================================================================
stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence);
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player);
	write_byte(Sequence);
	write_byte(pev(Player, pev_body));
	message_end();
}

stock EffectCreateExplostion(iEnt, Float:vOrigin[3], SprExplode)
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
	emit_sound(iEnt, CHAN_STATIC, ENT_SOUNDS[SOUND_EXPLODE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
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
	write_short(gSprites[SPR_TRAIL]);
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
	write_short(gSprites[SPR_SHOCKWAVE]);
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