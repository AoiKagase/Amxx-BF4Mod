
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] AKM"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_AK47)
#define FIRE1_DAMAGE	((AK47_DAMAGE + 1.0) / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.14

enum _:AKM_ANIMS
{
	AKM_IDLE,
	AKM_RELOAD,
	AKM_DRAW,
	AKM_SHOOT1,
	AKM_SHOOT2,
	AKM_SHOOT3,
};

enum _:AKM_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/akm-1.wav",
};

enum _:AKM_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};

new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_akm.mdl",
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
	Weapon 	= CreateWeapon("akm", Rifle, "AKM");
	// CAmmo	= CreateAmmo(150, 30, 90);

	// SetAmmoName					(CAmmo, "5.45x39mm");
	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy			(Weapon, AKM_DRAW, 0.0);
	BuildWeaponReload			(Weapon, AKM_RELOAD, 2.3);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_762Nato);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_akm");
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, AKM_SHOOT1, AKM_SHOOT2, AKM_SHOOT3);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_RU, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS, 
		Weapon,
		"AKM",
		"akm",
		_:Ammo_762Nato,
		"762nato"
	);
}

