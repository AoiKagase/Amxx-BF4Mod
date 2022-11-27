
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] QBZ-95B"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_AK47)
#define FIRE1_DAMAGE	(GALIL_DAMAGE / AK47_DAMAGE)
#define FIRE1_RECOIL 	0.98

enum _:FNC_ANIMS
{
	FNC_IDLE,
	FNC_RELOAD,
	FNC_DRAW,
	FNC_SHOOT1,
	FNC_SHOOT2,
	FNC_SHOOT3,
};

enum _:FNC_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/qbz95b-1.wav",
};

enum _:FNC_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};

new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_qbz95b.mdl",
	"models/p_ak47.mdl",
	"models/w_ak47.mdl",
};

new Weapon;
// new CAmmo;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon 	= CreateWeapon("fnc", Rifle, "QBZ-95B");
	// CAmmo	= CreateAmmo(150, 30, 90);

	// SetAmmoName					(CAmmo, "5.45x39mm");
	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy			(Weapon, FNC_DRAW, 0.0);
	BuildWeaponReload			(Weapon, FNC_RELOAD, 2.5);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_556Nato);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_qbz95b");
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, FNC_SHOOT1, FNC_SHOOT2, FNC_SHOOT3);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS, 
		Weapon,
		"QBZ-95B",
		"qbz95b",
		_:Ammo_556Nato,
		"556nato"
	);
}

