
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

#define PLUGIN		"[BF4 Weapons] M1911A1"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(30.0 / 32.0)
// P228 Recoil is +50%
#define RECOIL_P228		30.0
#define RECOIL_M1911A1	56.0
#define RECOIL 			((100.0 + (RECOIL_M1911A1 - RECOIL_P228)) / 100.0)

#define FIRE_RATE		GetWeaponDefaultDelay(CSW_P228)

enum _:M1911A1_ANIMS
{
	M1911A1_IDLE,
	M1911A1_SHOOT1,
	M1911A1_SHOOT2,
	M1911A1_SHOOT3,
	M1911A1_SHOOT_LAST,
	M1911A1_RELOAD,
	M1911A1_DRAW,
};

enum _:M1911A1_SOUNDS
{
	SND_CLIPIN,
	SND_CLIPOUT,
	SND_SLIDEBACK,
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/coltm1911a1_clipin.wav",
	"bf4_ranks/weapons/coltm1911a1_clipout.wav",
	"bf4_ranks/weapons/coltm1911a1_slideback.wav",
	"bf4_ranks/weapons/coltm1911a1-1.wav",
};

enum _:M1911A1_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_coltm1911a1.mdl",
	"models/p_p228.mdl",
	"models/w_p228.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	RegisterHamPlayer(Ham_Spawn, "PlayerSpawn", true);
}

public plugin_precache()
{
	Weapon      = CreateWeapon("coltm1911a1", Pistol, "M1911A1");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, M1911A1_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 8, Ammo_45ACP);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_coltm1911a1");
	BuildWeaponSecondaryAttack(Weapon, A2_None);
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, M1911A1_RELOAD, 2.2);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, M1911A1_SHOOT1);
	RegisterWeaponForward(Weapon, WForward_PrimaryAttackPost, 	"M1911A1_PrimaryPost");
	RegisterWeaponForward(Weapon, WForward_ReloadPost, 			"M1911A1_ReloadPost");
	RegisterWeaponForward(Weapon, WForward_HolsterPost, 		"M1911A1_HolsterPost");
	PrecacheWeaponModelSounds(Weapon);
	for(new i = 0; i < sizeof(gSound); i++)
		precache_sound(gSound[i]);

	PrecacheWeaponListSprites(Weapon);
}

public PlayerSpawn(id)
{
	if (is_user_alive(id))
	    GiveWeaponByID(id, Weapon);
}

public M1911A1_PrimaryPost(Entity)
{
	if (GetWeaponClip(Entity) <= 0)
		SendWeaponAnim(Entity, M1911A1_SHOOT_LAST);
}
public M1911A1_ReloadPost(Entity)
{
	set_task(1.0, "ReloadSound1", Entity);
}

public ReloadSound1(task)
{
	emit_sound(task, CHAN_STATIC, gSound[SND_CLIPIN], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	set_task(0.7, "ReloadSound2", task);
}
public ReloadSound2(task)
{
	emit_sound(task, CHAN_STATIC, gSound[SND_SLIDEBACK], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public M1911A1_HolsterPost(Entity)
{
	if (task_exists(Entity))
		remove_task(Entity);
}