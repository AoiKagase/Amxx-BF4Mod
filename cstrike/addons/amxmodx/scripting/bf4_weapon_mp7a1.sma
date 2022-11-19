
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

#define PLUGIN		"[BF4 Weapons] MP7A1"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(30.0 / 36.0)
#define RECOIL 			1.14

#define FIRE_RATE		GetWeaponDefaultDelay(CSW_MP5NAVY)

enum _:MP7A1_ANIMS
{
	MP7A1_IDLE,
	MP7A1_RELOAD,
	MP7A1_DRAW,
	MP7A1_SHOOT1,
	MP7A1_SHOOT2,
	MP7A1_SHOOT3,
	MP7A1_CHANGE,
};

enum _:MP7A1_SOUNDS
{
	SND_CLIPIN,
	SND_CLIPON,
	SND_CLIPOUT,
	SND_DRAW,
	SND_FOLEY1,
	SND_FOLEY2,
	SND_FOLEY3,
	SND_FOLEY4,
	SND_FOLEY5,
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/mp7_clipin.wav",
	"bf4_ranks/weapons/mp7_clipon.wav",
	"bf4_ranks/weapons/mp7_clipout.wav",
	"bf4_ranks/weapons/mp7_draw.wav",
	"bf4_ranks/weapons/mp7_foley1.wav",
	"bf4_ranks/weapons/mp7_foley2.wav",
	"bf4_ranks/weapons/mp7_foley2.wav",
	"bf4_ranks/weapons/mp7_foley2.wav",
	"bf4_ranks/weapons/mp7_foley2.wav",
	"bf4_ranks/weapons/mp7-1.wav",
};

enum _:MP7A1_MODELS
{
	V_MODEL,
	V_MODEL_STOCK,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_mp7a1.mdl",
	"models/bf4_ranks/weapons/v_mp7a1_2.mdl",
	"models/bf4_ranks/weapons/p_mp7a1.mdl",
	"models/bf4_ranks/weapons/w_mp7a1.mdl",
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

	register_forward	(FM_EmitSound, 				"FireSound");
}

public client_putinserver(id)
{
	gSilencer[id] = false;
	SetWeaponEntityData(Weapon, WED_A2, false);
	ModelChange(id + TASK_SECONDARY);
}

public plugin_precache()
{
	Weapon    = CreateWeapon("kriss", Rifle, "Kriss Super V");
	new CAmmo = CreateAmmo(75, 20, 80);
	SetAmmoName(CAmmo, "4.6x30mm");

	gNonSilModel = PrecacheWeaponModelEx("models/bf4_ranks/weapons/v_mp7a1.mdl");
	gSilModel 	 = PrecacheWeaponModelEx("models/bf4_ranks/weapons/v_mp7a1_2.mdl");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, MP7A1_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 20, CAmmo);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_mp7a1");
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, MP7A1_RELOAD, 3.6);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, MP7A1_SHOOT1);
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
	// BuildWeaponSecondaryAttack(Weapon, A2_InstaSwitch, MP7A1_SHOOT1, FIRE_RATE, FIRE1_DAMAGE - 0.2, RECOIL, "", "");
	BuildWeaponSecondaryAttack(Weapon, A2_Switch, 
		MP7A1_CHANGE, 5.0, 
		MP7A1_CHANGE, 5.0,
		MP7A1_IDLE, 
		MP7A1_DRAW, 0.0, 
		MP7A1_SHOOT1, FIRE_RATE, 
		MP7A1_RELOAD, 3.7, 
		FIRE_RATE + 0.2,
		FIRE1_DAMAGE - 0.2, 
		RECOIL - 0.3,
		gSound[SND_FIRE1]
	);

	BuildWeaponFlags(Weapon, WFlag_SwitchMode_NoText);
	PrecacheWeaponModelSounds(Weapon);
	PrecacheWeaponListSprites(Weapon);
	precache_sound(gSound[SND_FIRE1]);

	RegisterWeaponForward(Weapon, WForward_PrimaryAttackPre, "PrimaryAttack");
	RegisterWeaponForward(Weapon, WForward_SecondaryAttackPost, "SecondaryAttack");
	// RegisterWeaponForward(Weapon, WForward_HolsterPost, "ModelChangeDeploy");
	// RegisterWeaponForward(Weapon, WForward_SpawnPost, 	"ModelChangeDeploy");
	RegisterWeaponForward(Weapon, WForward_DeployPost, 	"ModelChangeDeploy");

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SMGS, 
		Weapon,
		"H&K MP7A1",
		"mp7a1",
		CAmmo,
		"4.6x30mm"
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
	new id        = get_member(Entity, m_pPlayer);
	gSilencer[id] = !gSilencer[id];

	set_task(5.0, "ModelChange", id + TASK_SECONDARY);
	SetNextAttack(Entity, 5.0, true);
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
		if (equali(weaponname1, "models/bf4_ranks/weapons/v_mp7a1")
		 || equali(weaponname1, "models/bf4_ranks/weapons/v_mp7a1_2"))
		{
			if (gSilencer[id])
				SetPlayerViewModel(id, gSilModel);
			else
				SetPlayerViewModel(id, gNonSilModel);
		}
	}
}
