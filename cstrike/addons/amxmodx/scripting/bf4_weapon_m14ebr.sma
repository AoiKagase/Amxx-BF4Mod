
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] M14 EBR"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_G3SG1)
#define FIRE1_DAMAGE	(37.0 / 32.0)
#define FIRE1_RECOIL 	1.24

enum _:M14EBR_ANIMS
{
	M14EBR_IDLE,
	M14EBR_RELOAD,
	M14EBR_DRAW,
	M14EBR_SHOOT1,
	M14EBR_SHOOT2,
	M14EBR_SHOOT3,
};

enum _:M14EBR_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/m14-1.wav",
};

enum _:M14EBR_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_m14.mdl",
	"models/bf4_ranks/weapons/p_m14.mdl",
	"models/bf4_ranks/weapons/w_m14.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon = CreateWeapon("m14ebr", Rifle, "M14EBR");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_m14ebr");
	BuildWeaponDeploy			(Weapon, M14EBR_DRAW, 0.0);
	BuildWeaponReload			(Weapon, M14EBR_RELOAD, 3.0);
	BuildWeaponAmmunition		(Weapon, 20, Ammo_762Nato);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, M14EBR_SHOOT1, M14EBR_SHOOT2, M14EBR_SHOOT3);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS,
		Weapon,
		"M14 EBR",
		"m14ebr",
		_:Ammo_762Nato,
		"762nato",
		20,90
	);		
}
