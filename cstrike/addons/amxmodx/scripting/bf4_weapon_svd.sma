
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] PGM Hecate-II"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_G3SG1)
#define FIRE1_DAMAGE	((G3SG1_DAMAGE + 1.0) / AWP_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:SVD_ANIMS
{
	SVD_IDLE,
	SVD_SHOOT1,
	SVD_SHOOT2,
	SVD_RELOAD,
	SVD_DRAW,
};

enum _:SVD_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/svd-1.wav",
};

enum _:SVD_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_svd.mdl",
	"models/bf4_ranks/weapons/p_svd.mdl",
	"models/bf4_ranks/weapons/w_svd.mdl",
};

new Weapon;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("svd", Rifle, "Snaiperskaya Vintovka Dragunova");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_svd");
	BuildWeaponDeploy			(Weapon, SVD_DRAW, 1.0);
	BuildWeaponReload			(Weapon, SVD_RELOAD, 3.2);
	BuildWeaponAmmunition		(Weapon, 10, Ammo_762Nato);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, SVD_SHOOT1, SVD_SHOOT2);
	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_SniperB);
	BuildWeaponFlags			(Weapon, WFlag_AutoSniper);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_RU, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON, 
		BF4_WEAPONCLASS_DMRS,
		Weapon,
		"Snaiperskaya Vintovka Dragunova",
		"svd",
		_:Ammo_762Nato,
		"762Nato"
	);		
}
