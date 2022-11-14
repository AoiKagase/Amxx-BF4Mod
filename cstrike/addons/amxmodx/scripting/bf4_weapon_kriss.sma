
#include <amxmodx>
#include <amxmodx>
#include <cswm>
#include <cswm_const>
#include <hamsandwich>
#include <fakemeta>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define CANNON_NEXTATTACK EV_FL_fuser4

#define PLUGIN		"[BF4 Weapons] Kriss Super V"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(30.0 / 36.0)
#define RECOIL 			0.14

#define FIRE_RATE		GetWeaponDefaultDelay(CSW_MP5NAVY)

enum _:KRISS_ANIMS
{
	KRISS_IDLE,
	KRISS_RELOAD,
	KRISS_DRAW,
	KRISS_SHOOT1,
	KRISS_SHOOT2,
	KRISS_SHOOT3,
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
};

enum _:KRISS_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_kriss.mdl",
	"models/p_mp5.mdl",
	"models/w_mp5.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
//	RegisterHamPlayer(Ham_Spawn, "PlayerSpawn", true);
}

public plugin_precache()
{
	Weapon      = CreateWeapon("kriss", Rifle, "Kriss Super V");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, KRISS_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 30, Ammo_45ACP);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_kriss");
	BuildWeaponSecondaryAttack(Weapon, A2_None);
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, KRISS_RELOAD, 3.5);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, KRISS_SHOOT1);

	RegisterWeaponForward(Weapon, WForward_ReloadPost, 			"KRISS_ReloadPost");
	RegisterWeaponForward(Weapon, WForward_HolsterPost, 		"KRISS_HolsterPost");
	PrecacheWeaponModelSounds(Weapon);
	for(new i = 0; i < sizeof(gSound); i++)
		precache_sound(gSound[i]);

	PrecacheWeaponListSprites(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
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
	    GiveWeaponByID(id, Weapon);
}

public KRISS_ReloadPost(Entity)
{
	set_task(0.8, "ReloadSound1", Entity);
}

public ReloadSound1(task)
{
	emit_sound(task, CHAN_STATIC, gSound[SND_CLIPOUT], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	set_task(0.4, "ReloadSound2", task);
}
public ReloadSound2(task)
{
	emit_sound(task, CHAN_STATIC, gSound[SND_CLIPIN], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	set_task(0.8, "ReloadSound3", task);
}
public ReloadSound3(task)
{
	emit_sound(task, CHAN_STATIC, gSound[SND_CLIPON], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	set_task(0.4, "ReloadSound4", task);
}
public ReloadSound4(task)
{
	emit_sound(task, CHAN_STATIC, gSound[SND_DRAW], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public KRISS_HolsterPost(Entity)
{
	if (task_exists(Entity))
		remove_task(Entity);
}