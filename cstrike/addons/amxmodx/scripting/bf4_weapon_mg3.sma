
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] MG3"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M249)
#define FIRE1_DAMAGE	((M249_DAMAGE + 1.0) / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:MG3_ANIMS
{
	MG3_IDLE,
	MG3_SHOOT1,
	MG3_SHOOT2,
	MG3_RELOAD,
	MG3_DRAW,
};

enum _:MG3_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/mg3-1.wav",
};

enum _:MG3_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_mg3.mdl",
	"models/bf4_ranks/weapons/p_mg3.mdl",
	"models/bf4_ranks/weapons/w_mg3.mdl",
};

new Weapon;
new CAmmo;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("mg3", Rifle, "MG3");

	CAmmo   = CreateAmmo(200, 100, 200);
	SetAmmoName(CAmmo, "762Natobox");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_mg3");
	BuildWeaponDeploy			(Weapon, MG3_DRAW, 1.0);
	BuildWeaponReload			(Weapon, MG3_RELOAD, 4.7);
	BuildWeaponAmmunition		(Weapon, 100, CAmmo);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, MG3_SHOOT1, MG3_SHOOT2);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_SUPPORT, 
		BF4_WEAPONCLASS_LMGS,
		Weapon,
		"MG3",
		"mg3",
		CAmmo,
		"762Natobox",
		100,200
	);		
}
