
#include <amxmodx>
#include <hamsandwich>
#include <bf4weapons>
#include <fakemeta>
#include <reapi>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] Kriss Super V"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_MP5NAVY)
#define FIRE1_DAMAGE	(30.0 / 36.0)
#define FIRE1_RECOIL 	1.14


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
	SND_FIRE1,
	SND_SIL_FIRE1,
};
new const gSound[][] =
{
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

#define TASK_SECONDARY 22102
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	RegisterHamPlayer(Ham_Spawn, "PlayerSpawn", true);
}

public client_putinserver(id)
{
	gSilencer[id] = false;
	ModelChange(id + TASK_SECONDARY);
}

public plugin_precache()
{
	Weapon = CreateWeapon("kriss", Rifle, "Kriss Super V");

	gNonSilModel = PrecacheWeaponModelEx("models/bf4_ranks/weapons/v_kriss.mdl");
	gSilModel 	 = PrecacheWeaponModelEx("models/bf4_ranks/weapons/v_kriss_2.mdl");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy			(Weapon, KRISS_DRAW, 0.0);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_45ACP);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_kriss");
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload			(Weapon, KRISS_RELOAD, 3.7);
	BuildWeaponFlags			(Weapon, WFlag_SwitchMode_NoText);

	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, KRISS_SHOOT1, KRISS_SHOOT2, KRISS_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Switch, 
		KRISS_SILENCER_ADD, 2.5, 	// SwitchAnim, SwitchAnimDuration
		KRISS_SILENCER_ADD, 2.0,	// ReturnAnim, ReturnAnimDuration
		KRISS_IDLE, 				// IdleAnim
		KRISS_DRAW, 0.0, 			// DrawAnim, DrawAnimDuration
		KRISS_SHOOT1, FIRE1_RATE, 	// ShootAnim, ShootAnimDuration
		KRISS_RELOAD, 3.7, 			// ReloadAnim, ReloadAnimDuration
		FIRE1_RATE,					// Delay
		FIRE1_DAMAGE - 0.2, 		// Damage
		FIRE1_RECOIL + 0.1, 		// Recoil
		gSound[SND_SIL_FIRE1]		// FireSound
	);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	RegisterWeaponForward		(Weapon, WForward_PrimaryAttackPre, 	"PrimaryAttack");
	RegisterWeaponForward		(Weapon, WForward_SecondaryAttackPost, 	"SecondaryAttack");
	RegisterWeaponForward		(Weapon, WForward_DeployPost, 			"ModelChangeDeploy");

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SMGS, 
		Weapon,
		"Kriss Super V",
		"kriss",
		_:Ammo_45ACP,
		"45acp"
	);	
}

public PlayerSpawn(id)
{
	if (is_user_alive(id))
	{
		gSilencer[id] = false;
		ModelChange(id + TASK_SECONDARY);
	}
}

public SecondaryAttack(Entity)
{
	new id = get_member(Entity, m_pPlayer);
	gSilencer[id] = !gSilencer[id];

	if (gSilencer[id])
	{
		set_task(2.5, "ModelChange", id + TASK_SECONDARY);
		SetNextAttack(Entity, 2.5, true);
	}
	else
	{
		set_task(2.0, "ModelChange", id + TASK_SECONDARY);
		SetNextAttack(Entity, 2.0, true);
	}
}

public ModelChangeDeploy(Entity)
{
	new id = get_member(Entity, m_pPlayer);
	ModelChange(id + TASK_SECONDARY);
}

public ModelChange(id)
{
	id -= TASK_SECONDARY;
	if (is_user_alive(id))
	{
		new weaponname1[33];
		pev(id, pev_viewmodel2, weaponname1, charsmax(weaponname1));
		if (equali(weaponname1, "models/bf4_ranks/weapons/v_kriss")
		 || equali(weaponname1, "models/bf4_ranks/weapons/v_kriss_2"))
		{
			if (gSilencer[id])
				SetPlayerViewModel(id, gSilModel);
			else
				SetPlayerViewModel(id, gNonSilModel);
		}
	}
}
