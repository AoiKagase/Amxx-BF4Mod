
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

#define PLUGIN		"[BF4 Weapons] Python"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(30.0 / 32.0)
// P228 Recoil is +50%
#define RECOIL_P228		30.0
#define RECOIL_PYTHON	17.0
#define RECOIL 			((100.0 + (RECOIL_PYTHON - RECOIL_P228)) / 100.0)

#define FIRE_RATE		GetWeaponDefaultDelay(CSW_P228)
#define TEMP			false

enum _:PYTHON_ANIMS
{
	PYTHON_IDLE,
	PYTHON_SHOOT1,
	PYTHON_SHOOT2,
	PYTHON_SHOOT_LAST,
	PYTHON_RELOAD,
	PYTHON_DRAW,
};

enum _:PYTHON_SOUNDS
{
	SND_CLIPIN1,
	SND_CLIPOUT,
	SND_DRAW,
	SND_EMPTY,
	SND_FIRE1,
	SND_FIRE2,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/python_clipin.wav",
	"bf4_ranks/weapons/python_clipout.wav",
	"bf4_ranks/weapons/python_draw.wav",
	"bf4_ranks/weapons/python_empty.wav",
	"bf4_ranks/weapons/python-1.wav",
	"bf4_ranks/weapons/python-2.wav",
};

enum _:PYTHON_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_python.mdl",
	"models/p_deagle.mdl",
	"models/w_deagle.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	RegisterHamPlayer(Ham_Spawn, "PlayerSpawn", true);
}

public plugin_precache()
{
	Weapon      = CreateWeapon("PYTHON", Pistol, "Python");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, PYTHON_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 6, Ammo_357SIG);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_python");
	BuildWeaponSecondaryAttack(Weapon, A2_None);
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, PYTHON_RELOAD, 2.0);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, PYTHON_SHOOT1);

	RegisterWeaponForward(Weapon, WForward_PrimaryAttackPost, 	"PYTHON_PrimaryPost");
	RegisterWeaponForward(Weapon, WForward_ReloadPost, 			"PYTHON_ReloadPost");
	RegisterWeaponForward(Weapon, WForward_HolsterPost, 		"PYTHON_HolsterPost");

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

public PYTHON_PrimaryPost(Entity)
{
	if (GetWeaponClip(Entity) <= 0)
		SendWeaponAnim(Entity, PYTHON_SHOOT_LAST);
}

public PYTHON_ReloadPost(Entity)
{
	set_task(1.1, "ReloadSound", Entity);
}

public ReloadSound(task)
{
	emit_sound(task, CHAN_STATIC, gSound[SND_CLIPIN1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public PYTHON_HolsterPost(Entity)
{
	if (task_exists(Entity))
		remove_task(Entity);
}