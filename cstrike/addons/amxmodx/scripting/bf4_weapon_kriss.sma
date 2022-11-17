
#include <amxmodx>
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <bf4weapons>
#include <reapi>
#include <cstrike>
#include <cswm>
#include <cswm_const>

#pragma semicolon 1
#pragma compress 1

#define CANNON_NEXTATTACK EV_FL_fuser4

#define PLUGIN		"[BF4 Weapons] Kriss Super V"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(30.0 / 36.0)
#define RECOIL 			1.14

#define FIRE_RATE		GetWeaponDefaultDelay(CSW_MP5NAVY)

enum _:KRISS_ANIMS
{
	KRISS_IDLE,
	KRISS_RELOAD,
	KRISS_DRAW,
	KRISS_SHOOT1,
	KRISS_SHOOT2,
	KRISS_SHOOT3,
	KRISS_SILENCER_ADD,
};

enum _:KRISS_SOUNDS
{
	SND_CLIPIN,
	SND_CLIPON,
	SND_CLIPOUT,
	SND_DRAW,
	SND_FOLEY1,
	SND_FOLEY2,
	SND_FIRE1,
	SND_SIL_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/kriss_clipin.wav",
	"bf4_ranks/weapons/kriss_clipon.wav",
	"bf4_ranks/weapons/kriss_clipout.wav",
	"bf4_ranks/weapons/kriss_draw.wav",
	"bf4_ranks/weapons/kriss_foley1.wav",
	"bf4_ranks/weapons/kriss_foley2.wav",
	"bf4_ranks/weapons/kriss-1.wav",
	"bf4_ranks/weapons/kriss_sil-1.wav"
};

enum _:KRISS_MODELS
{
	V_MODEL,
	V_MODEL_SIL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_kriss.mdl",
	"models/bf4_ranks/weapons/v_kriss_2.mdl",
	"models/bf4_ranks/weapons/p_kriss.mdl",
	"models/bf4_ranks/weapons/w_kriss.mdl",
};

new Weapon;
new bool:gSilencer[MAX_PLAYERS + 1];
new gSilModel;
new gNonSilModel;
new gWpnSystemId;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	RegisterHamPlayer(Ham_Spawn, "PlayerSpawn", true);

	register_forward	(FM_EmitSound, 				"FireSound");
}

public client_putinserver(id)
{
	gSilencer[id] = false;
}

public plugin_precache()
{
	Weapon    = CreateWeapon("kriss", Rifle, "Kriss Super V");

	gNonSilModel = PrecacheWeaponModelEx("models/bf4_ranks/weapons/v_kriss.mdl");
	gSilModel 	 = PrecacheWeaponModelEx("models/bf4_ranks/weapons/v_kriss_2.mdl");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, KRISS_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 30, Ammo_45ACP);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_kriss");
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, KRISS_RELOAD, 3.7);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, KRISS_SHOOT1);
/*
 SwitchAnim
 SwitchAnimDuration
 ReturnAnim
 ReturnAnimDuration
 IdleAnim
 DrawAnim
 DrawAnimDuration
 ShootAnim
 ShootAnimDuration,
 ReloadAnim
 ReloadAnimDuration
 Delay,
 Damage,
 Recoil
 FireSound
*/
	// BuildWeaponSecondaryAttack(Weapon, A2_InstaSwitch, KRISS_SHOOT1, FIRE_RATE, FIRE1_DAMAGE - 0.2, RECOIL, "", "");
	BuildWeaponSecondaryAttack(Weapon, A2_Switch, 
		KRISS_SILENCER_ADD, 3.0, 
		KRISS_SILENCER_ADD, 3.0, 
		KRISS_IDLE, 
		KRISS_IDLE, 0.0, 
		KRISS_SHOOT1, FIRE_RATE, 
		KRISS_RELOAD, 3.7, 
		FIRE_RATE,
		FIRE1_DAMAGE - 0.2, 
		RECOIL, 
		gSound[SND_SIL_FIRE1]
	);
	BuildWeaponFlags(Weapon, WFlag_SwitchMode_NoText);
	PrecacheWeaponModelSounds(Weapon);
	PrecacheWeaponListSprites(Weapon);
	precache_sound(gSound[SND_FIRE1]);
	precache_sound(gSound[SND_SIL_FIRE1]);

	RegisterWeaponForward(Weapon, WForward_PrimaryAttackPre, "PrimaryAttack");
	RegisterWeaponForward(Weapon, WForward_SecondaryAttackPre, "SecondaryAttack");

	gWpnSystemId = BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SMGS, 
		Weapon,
		Ammo_45ACP,
		"Kriss Super V",
		"kriss");	
}

public PlayerSpawn(id)
{
	if (is_user_alive(id))
	{
		new weaponname1[33];
		pev(id, pev_viewmodel2, weaponname1, charsmax(weaponname1));
		if (equali(weaponname1, "models/bf4_ranks/weapons/v_kriss") || equali(weaponname1, "models/bf4_ranks/weapons/v_kriss_2"))
		{
			if (gSilencer[id])
				SetPlayerViewModel(id, gSilModel);
			else
				SetPlayerViewModel(id, gNonSilModel);
		}
	}
}

public SecondaryAttack(Entity)
{
	new Player = get_member(Entity, m_pPlayer);
	SendWeaponAnim(Entity, KRISS_SILENCER_ADD);
	gSilencer[Player] = !gSilencer[Player];
	if (gSilencer[Player])
	{
		set_task(2.5, "ModelChange", Player + 22102);
		// SetNextAttack(Entity, 2.5, true);
	}
	else
	{
		set_task(2.0, "ModelChange", Player + 22102);
		// SetNextAttack(Entity, 2.0, true);
	}

}

public ModelChange(id)
{
	id -= 22102;
	if (is_user_alive(id))
	{
		new weaponname1[33];
		pev(id, pev_viewmodel2, weaponname1, charsmax(weaponname1));
		if (equali(weaponname1, "models/bf4_ranks/weapons/v_kriss") || equali(weaponname1, "models/bf4_ranks/weapons/v_kriss_2"))
		{
			if (gSilencer[id])
				SetPlayerViewModel(id, gSilModel);
			else
				SetPlayerViewModel(id, gNonSilModel);
		}
	}
}

