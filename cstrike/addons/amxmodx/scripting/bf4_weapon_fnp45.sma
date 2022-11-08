
#include <amxmodx>
#include <amxmodx>
#include <bf4const>
#include <cswm>
#include <cswm_const>
#include <hamsandwich>
#include <fakemeta>

#pragma semicolon 1
#pragma compress 1

#define CANNON_NEXTATTACK EV_FL_fuser4

#define PLUGIN		"[BF4 Weapons] FNP-45"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

enum _:FNP45_ANIMS
{
	FNP45_IDLE,
	FNP45_SHOOT1,
	FNP45_SHOOT2,
	FNP45_SHOOT3,
	FNP45_SHOOT_LAST,
	FNP45_RELOAD,
	FNP45_DRAW,
};

enum _:FNP45_SOUNDS
{
	SND_CLIPIN1,
	SND_CLIPIN2,
	SND_CLIPOUT,
	SND_DRAW,
	SND_FIRE1,
	SND_FIRE2,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/fnp45_clipin1.wav",
	"bf4_ranks/weapons/fnp45_clipin2.wav",
	"bf4_ranks/weapons/fnp45-clipout.wav",
	"bf4_ranks/weapons/fnp45-draw.wav",
	"bf4_ranks/weapons/fnp45-1.wav",
	"bf4_ranks/weapons/fnp45-2.wav",
};

enum _:FNP45_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_fnp45.mdl",
	"models/bf4_ranks/weapons/p_fnp45.mdl",
	"models/bf4_ranks/weapons/w_fnp45.mdl",
};
#define TASK_RELOAD 2938510

new Weapon;
public plugin_init()
{
	register_plugin("[BF4 Weapons] FNP-45", "0.1", "Aoi.Kagase");

	RegisterHamPlayer(Ham_Spawn, "PlayerSpawn", true);
}

public plugin_precache()
{
	Weapon      = CreateWeapon("fnp45", Pistol, "FNP-45");
	// new Ammo = CreateAmmo(100, 1, 5);
	// SetAmmoName(Ammo, "40x46mm grenade");
	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, FNP45_DRAW, 0.0);
//	BuildWeaponPrimaryAttack(Weapon, 0.0, 0.0, 1.0);
	BuildWeaponAmmunition(Weapon, 15, Ammo_45ACP);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_fnp45");
//	BuildWeaponFlags(Weapon, WFlag_AutoReload);
	BuildWeaponSecondaryAttack(Weapon, A2_None);
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, FNP45_RELOAD, 2.5);
	BuildWeaponPrimaryAttack(Weapon, GetWeaponDefaultDelay(CSW_USP), 30.0, 0.19, FNP45_SHOOT1);
	RegisterWeaponForward(Weapon, WForward_ReloadPost, 			"FNP45_ReloadPre");
	RegisterWeaponForward(Weapon, WForward_PrimaryAttackPost, 	"FNP45_PrimaryPost");

	// RegisterWeaponForward(Weapon, WForward_PrimaryAttackPre, "FNP45_PrimaryAttackPre");
	PrecacheWeaponModelSounds(Weapon);

	for(new i = 0; i < sizeof(gSound); i++)
		precache_sound(gSound[i]);

	PrecacheWeaponListSprites(Weapon);
}

public PlayerSpawn(id)
{
    GiveWeaponByID(id, Weapon);
}

public FNP45_ReloadPre(Entity)
{
	emit_sound(Entity, CHAN_VOICE, gSound[SND_CLIPOUT], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	set_task(2.5, "FNP45_ReloadPost", Entity+TASK_RELOAD);
}

public FNP45_ReloadPost(Entity)
{
	Entity -= TASK_RELOAD;
	emit_sound(Entity, CHAN_VOICE, gSound[random_num(SND_CLIPIN1, SND_CLIPIN2)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public FNP45_PrimaryPost(Entity)
{
	if (GetWeaponClip(Entity) <= 0)
	{
		SetWeaponIdleAnim(Entity, FNP45_SHOOT_LAST);
	}
}
