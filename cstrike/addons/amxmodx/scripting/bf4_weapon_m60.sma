
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] M60"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M249)
#define FIRE1_DAMAGE	((M249_DAMAGE + 1.0) / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:M60_ANIMS
{
	M60_IDLE,
	M60_SHOOT1,
	M60_SHOOT2,
	M60_RELOAD,
	M60_DRAW,
};

enum _:M60_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/m60-1.wav",
	"bf4_ranks/weapons/m60-2.wav",
};

enum _:M60_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_m60.mdl",
	"models/bf4_ranks/weapons/p_m60.mdl",
	"models/bf4_ranks/weapons/w_m60.mdl",
};

new Weapon;
new CAmmo;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("m60", Rifle, "M60");

	CAmmo   = CreateAmmo(200, 100, 200);
	SetAmmoName(CAmmo, "762Natobox");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_m60");
	BuildWeaponDeploy			(Weapon, M60_DRAW, 1.0);
	BuildWeaponReload			(Weapon, M60_RELOAD, 5.8);
	BuildWeaponAmmunition		(Weapon, 100, CAmmo);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, M60_SHOOT1, M60_SHOOT2);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_SUPPORT, 
		BF4_WEAPONCLASS_LMGS,
		Weapon,
		"M60",
		"m60",
		CAmmo,
		"762Natobox",
		100,200
	);		
}
