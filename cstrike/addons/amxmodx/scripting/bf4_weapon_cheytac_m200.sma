
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] Cheytac M200"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_AWP)
#define FIRE1_DAMAGE	((AWP_DAMAGE - 2.0) / AWP_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:M200_ANIMS
{
	M200_IDLE,
	M200_SHOOT1,
	M200_SHOOT2,
	M200_SHOOT3,
	M200_RELOAD,
	M200_DRAW,
};

enum _:M200_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/m400-1.wav",
};

enum _:M200_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_m400.mdl",
	"models/bf4_ranks/weapons/p_m400.mdl",
	"models/bf4_ranks/weapons/w_m400.mdl",
};

new Weapon;
// new CAmmo;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("m400", Sniper, "Cheytac M200");
	// CAmmo	= CreateAmmo(100, 5, 50);

	// SetAmmoName					(CAmmo, ".50 BGM");
	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_m400");
	BuildWeaponDeploy			(Weapon, M200_DRAW, 1.0);
	BuildWeaponReload			(Weapon, M200_RELOAD, 2.9);
	BuildWeaponAmmunition		(Weapon, 10, Ammo_338Magnum);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, M200_SHOOT1, M200_SHOOT2, M200_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_SniperB);
//	BuildWeaponFlags			(Weapon, WFlag_AutoSniper);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON, 
		BF4_WEAPONCLASS_SNIPERS,
		Weapon,
		"Cheytac M200",
		"m400",
		_:Ammo_338Magnum,
		"338Magnum",
		10,
		30
	);		
}
