
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] HK23"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M249)
#define FIRE1_DAMAGE	((M249_DAMAGE + 1.0) / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:HK23_ANIMS
{
	HK23_IDLE,
	HK23_SHOOT1,
	HK23_SHOOT2,
	HK23_RELOAD,
	HK23_DRAW,
};

enum _:HK23_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/hk23-1.wav",
};

enum _:HK23_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_hk23.mdl",
	"models/bf4_ranks/weapons/p_hk23.mdl",
	"models/bf4_ranks/weapons/w_hk23.mdl",
};

new Weapon;
// new CAmmo;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("hk23", Rifle, "HK23");

	// CAmmo   = CreateAmmo(200, 100, 200);
	// SetAmmoName(CAmmo, "762Natobox");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_hk23");
	BuildWeaponDeploy			(Weapon, HK23_DRAW, 1.0);
	BuildWeaponReload			(Weapon, HK23_RELOAD, 4.6);
	BuildWeaponAmmunition		(Weapon, 100, Ammo_556NatoBox);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, HK23_SHOOT1, HK23_SHOOT2);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_SUPPORT, 
		BF4_WEAPONCLASS_LMGS,
		Weapon,
		"HK23",
		"hk23",
		_:Ammo_556NatoBox,
		"556NatoBox",
		100,200
	);		
}
