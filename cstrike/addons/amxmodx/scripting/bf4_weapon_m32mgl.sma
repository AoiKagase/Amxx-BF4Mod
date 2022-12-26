#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <bf4classes>
#include <bf4effects>
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

static const PLUGIN_NAME	[] 			= "[BF4 Weapons] M32 MGL";
static const PLUGIN_AUTHOR	[] 			= "Aoi.Kagase";
static const PLUGIN_VERSION	[]			= "0.1";

#define M32_BOUNCED						pev_iuser1
#define M32_ITEM_TEAM  					pev_iuser2
#define M32_THINK						pev_fuser1
#define M32_TIME						pev_fuser2
static const Float:M32_DAMAGE = 100.0;
static const Float:M32_RADIUS = 250.0;
static const Float:M32_EXPTIME= 2.0;

enum _:E_SOUNDS
{
	SOUND_RELOAD_START,
	SOUND_RELOAD_INSERT,
	SOUND_RELOAD_AFTER,
	SOUND_FIRE,
	SOUND_BOUNCE1,
	SOUND_HIT1,
	SOUND_HIT2,
	SOUND_HIT3,
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
	SEQ_SHOOT_1,
	SEQ_SHOOT_2,
	SEQ_INSERT,
	SEQ_RELOAD_AFTER,
	SEQ_RELOAD_START,
	SEQ_DRAW,
}

enum _:E_THINK
{
	THINK_IDLE,
	THINK_DRAW,
	THINK_SHOOT,
	THINK_RELOAD_START,
	THINK_RELOAD_INSERT,
	THINK_RELOAD_AFTER,
}

enum _:E_SPRITES_GEN
{
	SPR_WEAPONLIST,
	SPR_HUD1,
	SPR_HUD2,
	SPR_SCOPE,
}

enum _:E_SPRITES_MDL
{
	SPR_TRAIL,
}

new const MESSAGES[E_MESSAGES][] = 
{
	"WeaponList",
	"ScreenShake",
};

new const ENT_MODELS[E_MODELS][] = 
{
	"models/bf4_ranks/weapons/v_m32.mdl",
	"models/p_m3.mdl",
	"models/w_m3.mdl",
	"models/bf4_ranks/weapons/shell_40mm.mdl",
};

new const ENT_SOUNDS[E_SOUNDS][] = 
{
	"bf4_ranks/weapons/m32_start_reload.wav",
	"bf4_ranks/weapons/m32_insert.wav",
	"bf4_ranks/weapons/m32_after_reload.wav",
	"bf4_ranks/weapons/m32-1.wav",
	"weapons/he_bounce-1.wav",
	"weapons/grenade_hit1.wav",
	"weapons/grenade_hit2.wav",
	"weapons/grenade_hit3.wav",
};

new const ENT_SPRITES_GEN[E_SPRITES_GEN][] =
{
	"sprites/bf4_ranks/weapons/weapon_m32.txt",
	"sprites/bf4_ranks/weapons/cso_640hud75.spr",
	"sprites/bf4_ranks/weapons/cso_640hud7.spr",
	"sprites/bf4_ranks/weapons/cso_scope_grenade.spr",
};

new const ENT_SPRITES_MDL[E_SPRITES_MDL][] =
{
	"sprites/smoke.spr",
};

new const ENT_CLASS_C4[]		= "weapon_c4";
new const ENT_CLASS_BREAKABLE[] = "func_breakable";
new const ENT_CLASS_ROCKET[]	= "40mmG";

new g_msg_data		[E_MESSAGES];

new gWpnSystemId;
new gCSXID;
new gWpnThinkStatus	[MAX_PLAYERS + 1];
new gSprites		[E_SPRITES_MDL];
new gCAmmo;

stock set_ammo_type(item, type)	
	set_ent_data(item, "CBasePlayerWeapon", "m_iPrimaryAmmoType", type);
stock set_ammo_clip(item, clip)
	set_ent_data(item, "CBasePlayerWeapon", "m_iClip", clip);
stock get_ammo_clip(item)
	return get_ent_data(item, "CBasePlayerWeapon", "m_iClip");
stock set_bpammo(client, ammoType, ammo)
	set_ent_data(client, "CBasePlayer", "m_rgAmmo", ammo, ammoType);
stock get_bpammo(client, ammoType)
	return get_ent_data(client, "CBasePlayer", "m_rgAmmo", ammoType);
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

	gCAmmo = CreateAmmo(1000, 1, 18);
	SetAmmoName(gCAmmo, "40x46mm Grenade");
	gWpnSystemId = BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON, 
		BF4_WEAPONCLASS_EQUIP, 
		-1,
		"M32 MGL",
		"c4",
		gCAmmo,
		"40x46mm Grenade",
		6,
		18
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
    register_clcmd		("bf4_ranks/weapons/weapon_m32", 			"SelectM32");
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
	RegisterHam			(Ham_Touch, ENT_CLASS_BREAKABLE, "BF4ObjectTouch");
	RegisterHam			(Ham_Think, ENT_CLASS_BREAKABLE, "BF4ObjectThink", .Post = true);
/// =======================================================================================
/// END ROCKET
/// =======================================================================================
	register_event		("CurWeapon", "Event_CurWeapon", "be", "1=1");
	for(new i = 0; i < E_MESSAGES; i++)
		g_msg_data[i] = get_user_msgid(MESSAGES[i]);

	gCSXID = custom_weapon_add("weapon_m32", 0, "M32 MGL");		
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
		write_string("bf4_ranks/weapons/weapon_m32");   // WeaponName
		write_byte(gCAmmo);                   		// PrimaryAmmoID
		write_byte(18);                   		// PrimaryAmmoMaxAmount
		write_byte(-1);                   		// SecondaryAmmoID
		write_byte(-1);                   		// SecondaryAmmoMaxAmount
		write_byte(4);                    		// SlotID (0...N)
		write_byte(11);                    		// NumberInSlot (1...N)
		write_byte(CSW_C4); 	           		// WeaponID
		write_byte(0);                    		// Flags
	}
	message_end();

	set_ammo_type	(item, gCAmmo);
	set_bpammo		(item, gCAmmo, 18);
	set_ammo_clip	(item, 6);

	return PLUGIN_CONTINUE;
}

///
/// Select Weapon.
///
public SelectM32(const client) 
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

	set_pev(Weapon, M32_THINK, get_gametime());
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

#define m_iHideHUD				361
public Event_CurWeapon(id)
{
	static iMsgHide;
	if (!iMsgHide)
		iMsgHide = get_user_msgid("HideWeapon");

	if (SafetyCheck(id, cs_get_user_weapon_entity(id)))
	{
		set_pdata_int(id, m_iHideHUD, get_pdata_int(id, m_iHideHUD) | (1<<6));
	} 
	return PLUGIN_CONTINUE;
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
	static Float:fThink; pev(Weapon, M32_THINK, fThink); 
	static Float:fNow; fNow = get_gametime();

	switch(gWpnThinkStatus[client])
	{
		case THINK_DRAW:
		{
			if (fNow > fThink)
			{
				// RETIRED.
				if (get_ammo_clip(Weapon) <= 0 && get_bpammo(client, gCAmmo) <= 0)
				{
					ExecuteHam(Ham_Weapon_RetireWeapon, cs_get_user_weapon_entity(client));			
					set_pev(Weapon, M32_THINK, fNow + 0.1);
					return HAM_IGNORED;
				}
				// PLAY DRAW ANIMATION.
				if (pev(client, pev_weaponanim) != SEQ_DRAW)
					UTIL_PlayWeaponAnimation(client, SEQ_DRAW);

				// NEXT THINK.
				gWpnThinkStatus[client] = THINK_IDLE;

				// DRAW ANIMATION IS 3.1 sec.
				set_member(Weapon, m_Weapon_flTimeWeaponIdle, 1.0);
				set_pev(Weapon, M32_THINK, fNow + 1.0);
			}
		}
		case THINK_IDLE:
		{
			// CHECK PREVIOUS STATUS.
			if (fNow > fThink)
			{
				// PLAY IDLE ANIMATION.
				UTIL_PlayWeaponAnimation(client, SEQ_IDLE);
				set_pev(Weapon, M32_THINK, fNow + 2.0);
			}
		}
		case THINK_SHOOT:
		{
			if (fNow > fThink)
			{
				if (get_ammo_clip(Weapon) > 0)
				{
					// SHOOT.
					custom_weapon_shot(gCSXID, client);
					// CREATE ROCKET.
					BF4SpawnEntity(client);
					// USE AMMO.
					set_ammo_clip(Weapon, get_ammo_clip(Weapon) - 1);
				}

				if (get_bpammo(client, gCAmmo))
				{
					if (!get_ammo_clip(Weapon))					
					{
						// NEXT THINK.
						gWpnThinkStatus[client] = THINK_RELOAD_START;
						// SHOOT ANIMATION IS 1.00 sec.
						set_pev(Weapon, M32_THINK, fNow);
					}
					else
					{
						// NEXT THINK.
						gWpnThinkStatus[client] = THINK_IDLE;
						// SHOOT ANIMATION IS 1.00 sec.
						set_pev(Weapon, M32_THINK, fNow + 1.0);
					}
				}
				else
				{
					if (!get_ammo_clip(Weapon))					
					{
						ExecuteHam(Ham_Weapon_RetireWeapon, cs_get_user_weapon_entity(client));			
						set_pev(Weapon, M32_THINK, fNow + 0.1);
					}
				}
			}
		}
		case THINK_RELOAD_START:
		{
			// CHECK PREVIOUS STATUS.
			if (fNow > fThink)
			{
				if (!get_bpammo(client, gCAmmo))
				{
					if (!get_ammo_clip(Weapon))
					{
						ExecuteHam(Ham_Weapon_RetireWeapon, cs_get_user_weapon_entity(client));			
						set_pev(Weapon, M32_THINK, fNow + 0.1);
						return HAM_IGNORED;
					}
					// NEXT THINK.
					gWpnThinkStatus[client] = THINK_IDLE;
					// SHOOT ANIMATION IS 1.00 sec.
					set_pev(Weapon, M32_THINK, fNow);
				}
				else
				{
					// PLAY RELOAD ANIMATION.
					if (pev(client, pev_weaponanim) != SEQ_RELOAD_START)
						UTIL_PlayWeaponAnimation(client, SEQ_RELOAD_START);
					// NEXT THINK.
					gWpnThinkStatus[client] = THINK_RELOAD_INSERT;
					// RELOAD ANIMATION IS 0.73 sec.
					set_pev(Weapon, M32_THINK, fNow + 0.73);
				}
			}
		}
		case THINK_RELOAD_INSERT:
		{
			// CHECK PREVIOUS STATUS.
			if (fNow > fThink)
			{
				new clip = get_ammo_clip(Weapon);
				if (clip < 6 && get_bpammo(client, gCAmmo))
				{
					// PLAY RELOAD ANIMATION.
					UTIL_PlayWeaponAnimation(client, SEQ_INSERT);

					set_ammo_clip(Weapon, clip + 1);
					set_bpammo(client, gCAmmo, get_bpammo(client, gCAmmo) - 1);
				}

				if (clip == 6 || get_bpammo(client, gCAmmo) <= 0)
				{
					// NEXT THINK.
					gWpnThinkStatus[client] = THINK_RELOAD_AFTER;
					// INSERT ANIMATION IS 0.9 sec.
					set_pev(Weapon, M32_THINK, fNow);
					return HAM_IGNORED;
				}

				// INSERT ANIMATION IS 0.9 sec.
				set_pev(Weapon, M32_THINK, fNow + 0.9);
			}
		}
		case THINK_RELOAD_AFTER:
		{
			// CHECK PREVIOUS STATUS.
			if (fNow > fThink)
			{
				// PLAY RELOAD ANIMATION.
				if (pev(client, pev_weaponanim) != SEQ_RELOAD_AFTER)
					UTIL_PlayWeaponAnimation(client, SEQ_RELOAD_AFTER);

				// NEXT THINK.
				gWpnThinkStatus[client] = THINK_IDLE;
				// RELOAD ANIMATION IS 0.77 sec.
				set_pev(Weapon, M32_THINK, fNow + 0.77);
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
		set_pev(iEnt, pev_solid, 		SOLID_BBOX);
		// set movetype.
		set_pev(iEnt, pev_movetype, 	MOVETYPE_BOUNCE);

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
		set_pev(iEnt, pev_dmg, 			30.0);
		// set entity health.
		set_pev(iEnt, pev_health,		1.0);
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

		velocity_by_aim(id, 700, vVelocity);
//		xs_vec_mul_scalar(vVelocity, 5000.0, vVelocity);
		// set size.
		engfunc(EngFunc_SetSize, iEnt, Float:{ -1.0, -1.0, -1.0 }, Float:{ 1.0, 1.0, 1.0 } );
		set_pev(iEnt, pev_velocity,		vVelocity);
		
		set_pev(iEnt, pev_rendermode,	kRenderNormal);
		// set_pev(iEnt, pev_renderamt, 	5.0);

		// Save results to be used later.
		set_pev(iEnt, M32_ITEM_TEAM, 	BF4GetUserTeam(id));
		// think rate. hmmm....
		set_pev(iEnt, pev_nextthink, 	get_gametime() + 0.1);

		set_pev(iEnt, M32_TIME, 		get_gametime() + M32_EXPTIME);
		set_pev(iEnt, M32_BOUNCED, 		0);
		set_pev(iEnt, pev_friction, 	0.4);
		set_pev(iEnt, pev_gravity, 		0.55);

		emit_sound(iEnt, CHAN_ITEM, ENT_SOUNDS[SOUND_FIRE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

		new iColor[3];
		iColor[0] = 224;
		iColor[1] = 224;
		iColor[2] = 224;

		EffectTrail(iEnt, iColor);
	}
}

public BF4ObjectTouch(iEnt, iToucher)
{
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	new classname[MAX_NAME_LENGTH];
	pev(iEnt, pev_classname, classname, charsmax(classname));

	if (!equali(classname, ENT_CLASS_ROCKET))
		return HAM_IGNORED;

	BounceTouch(iEnt, iToucher);

	new Float:explode_time;
	pev(iEnt, M32_TIME, explode_time);

	if (get_gametime() < explode_time)
		return HAM_IGNORED;

	new iOwner, flags;
	iOwner = pev(iEnt, pev_owner);

	if (is_user_alive(iOwner))
	{
		if (iToucher == iOwner)
			return HAM_IGNORED;
	}

	new const iColor[4] = {224,224,224,255};
	BF4EffectExplosion(iEnt, M32_DAMAGE, M32_RADIUS, iColor, 30);
	// damage.
	BF4EffectExplosionDamage(gCSXID, iEnt, iOwner, M32_DAMAGE, M32_RADIUS);
	BF4EffectScreenShake(iEnt, 2.0, 2.0, 2.0, M32_RADIUS);

	// remove this.
	pev(iEnt, pev_flags, flags);
	set_pev(iEnt, pev_flags, flags | FL_KILLME);
	dllfunc(DLLFunc_Think, iEnt);

	return HAM_IGNORED;
}

public BF4ObjectThink(iEnt)
{
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	static classname[MAX_NAME_LENGTH];
	pev(iEnt, pev_classname, classname, charsmax(classname));

	if (!equali(classname, ENT_CLASS_ROCKET))
		return HAM_IGNORED;

	if (pev(iEnt, pev_flags) & FL_KILLME)
		return HAM_IGNORED;

	static Float:gametime;
	static Float:explode_time;
	gametime = get_gametime();
	pev(iEnt, M32_TIME, explode_time);

	if (pev(iEnt, pev_flags) | FL_ONGROUND)
	{
		if (floatcmp(gametime, explode_time) < 0)
		{
			set_pev(iEnt, pev_nextthink, gametime + 0.1);
			return HAM_IGNORED;
		}
	}
	else
	{
		return HAM_IGNORED;
	}

	static iOwner, flags;
	iOwner = pev(iEnt, pev_owner);

	new const iColor[4] = {224,224,224,255};
	BF4EffectExplosion(iEnt, M32_DAMAGE, M32_RADIUS, iColor, 30);
	// damage.
	BF4EffectExplosionDamage(gCSXID, iEnt, iOwner, M32_DAMAGE, M32_RADIUS);
	BF4EffectScreenShake(iEnt, 2.0, 2.0, 2.0, M32_RADIUS);

	// remove this.
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

	new Weapon = cs_get_user_weapon_entity(id);
	// static Float:fThink; pev(Weapon, M32_THINK, fThink); 
	// static Float:fNow; fNow = get_gametime();

	if (buttonPressed & IN_ATTACK)
	{
		// if (fNow > fThink)
		{
			switch(gWpnThinkStatus[id])
			{
				case THINK_IDLE:
				{
					if (get_ammo_clip(Weapon))
					{
						UTIL_PlayWeaponAnimation(id, SEQ_SHOOT_1);		

						gWpnThinkStatus[id] = THINK_SHOOT;
						set_pev(Weapon, M32_THINK, get_gametime());
					}
				}
				case THINK_RELOAD_INSERT:
				{
					if (get_ammo_clip(Weapon))
					{
						UTIL_PlayWeaponAnimation(id, SEQ_SHOOT_1);		

						gWpnThinkStatus[id] = THINK_SHOOT;
						set_pev(Weapon, M32_THINK, get_gametime());
					}
				}
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

	if (buttonPressed & IN_RELOAD)
	{
		if (gWpnThinkStatus[id] == THINK_IDLE)
		{
			new Weapon = cs_get_user_weapon_entity(id);
			if (get_ammo_clip(Weapon) < 6)
			{
				gWpnThinkStatus[id] = THINK_RELOAD_START;
				set_pev(Weapon, M32_THINK, get_gametime());
			}
		}
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

stock BounceTouch(iEnt, iToucher)
{
	new iOwner = pev(iEnt, pev_owner);
	// don't hit the guy that launched this grenade
	if (iToucher == iOwner)
		return;
	
	new classname[MAX_NAME_LENGTH];
	new Float:velocity[3];
	pev(iToucher, pev_classname, classname, charsmax(classname));
	pev(iEnt, pev_velocity, velocity);

	if (equali(classname, ENT_CLASS_BREAKABLE) && pev(iToucher, pev_rendermode) != kRenderNormal)
	{
		xs_vec_mul_scalar(velocity, -2.0, velocity);
		set_pev(iEnt, pev_velocity, velocity);
		return;
	}

	new Float:vecTestVelocity[3];

	// this is my heuristic for modulating the grenade velocity because grenades dropped purely vertical
	// or thrown very far tend to slow down too quickly for me to always catch just by testing velocity.
	// trimming the Z velocity a bit seems to help quite a bit.
	vecTestVelocity = velocity;
	vecTestVelocity[2] *= 0.7;

	if (pev(iEnt, pev_flags) & FL_ONGROUND)
	{
		// add a bit of static friction
		xs_vec_mul_scalar(velocity, 0.8, velocity);
		set_pev(iEnt, pev_velocity, velocity);
	}
	else
	{
		new bounced = pev(iEnt, M32_BOUNCED);
		if (bounced < 5)
		{
			if (pev(iEnt, pev_dmg) > 50.0)
			{
				emit_sound(iEnt, CHAN_VOICE, ENT_SOUNDS[SOUND_BOUNCE1], 0.25, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				switch(random_num(0,2))
				{
					case 0:
						emit_sound(iEnt, CHAN_VOICE, ENT_SOUNDS[SOUND_HIT1], 0.25, ATTN_NORM, 0, PITCH_NORM);
					case 1:
						emit_sound(iEnt, CHAN_VOICE, ENT_SOUNDS[SOUND_HIT2], 0.25, ATTN_NORM, 0, PITCH_NORM);
					case 2:
						emit_sound(iEnt, CHAN_VOICE, ENT_SOUNDS[SOUND_HIT3], 0.25, ATTN_NORM, 0, PITCH_NORM);
				}				
			}
		}
		
		if (bounced >= 10)
		{
			set_pev(iEnt, pev_groundentity, 0);
			set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_ONGROUND);
			set_pev(iEnt, pev_velocity, Float:{0.0,0.0,0.0});
		}
		set_pev(iEnt, M32_BOUNCED, bounced + 1);
	}
	new Float:framerate = xs_vec_len(velocity) / 200.0;
	if (framerate > 1.0)
		set_pev(iEnt, pev_framerate, 1.0);
	else if (framerate < 0.5)
		set_pev(iEnt, pev_framerate, 0.0);
	else
		set_pev(iEnt, pev_framerate, framerate);
}