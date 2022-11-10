
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

#define PLUGIN		"[BF4 Weapons] Automag V"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(41.0 / 32.0)
// P228 Recoil is +50%
#define RECOIL_P228		30.0
#define RECOIL_AUTOMAG	33.0
#define RECOIL 			((100.0 + (RECOIL_AUTOMAG - RECOIL_P228)) / 100.0)

#define FIRE_RATE		GetWeaponDefaultDelay(CSW_DEAGLE)
#define TEMP			false

enum _:AUTOMAG5_ANIMS
{
	AUTOMAG5_IDLE,
	AUTOMAG5_SHOOT1,
	AUTOMAG5_SHOOT2,
	AUTOMAG5_SHOOT_LAST,
	AUTOMAG5_RELOAD,
	AUTOMAG5_DRAW,
};

enum _:AUTOMAG5_SOUNDS
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
	"bf4_ranks/weapons/amg_foley1.wav",
	"bf4_ranks/weapons/amg_foley2.wav",
	"bf4_ranks/weapons/amg_foley3.wav",
	"bf4_ranks/weapons/amg_foley4.wav",
	"bf4_ranks/weapons/amg-1.wav",
	"bf4_ranks/weapons/amg-2.wav",
};

enum _:AUTOMAG5_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_automag5.mdl",
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
	Weapon      = CreateWeapon("AUTOMAG5", Pistol, "AUTOMAG V");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, AUTOMAG5_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 7, Ammo_50AE);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_automag5");
	BuildWeaponSecondaryAttack(Weapon, A2_None);
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, AUTOMAG5_RELOAD, 2.2);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, AUTOMAG5_SHOOT1);
	RegisterWeaponForward(Weapon, WForward_PrimaryAttackPost, 	"AUTOMAG5_PrimaryPost");
	RegisterWeaponForward(Weapon, WForward_ReloadPost, 			"AUTOMAG5_ReloadPost");

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

public AUTOMAG5_PrimaryPost(Entity)
{
	if (GetWeaponClip(Entity) <= 0)
		SendWeaponAnim(Entity, AUTOMAG5_SHOOT_LAST);
}

public AUTOMAG5_ReloadPost(Entity)
{
	set_task(1.0, "ReloadSound", Entity);
}

public ReloadSound(task)
{
	emit_sound(task, CHAN_STATIC, gSound[SND_CLIPIN2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}