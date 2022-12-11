
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>
#include <bf4weapons>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] UTS-15"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_XM1014)
#define FIRE1_DAMAGE	(XM1014_DAMAGE / XM1014_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:UTS15_ANIMS
{
	UTS15_IDLE,
	UTS15_SHOOT1,
	UTS15_SHOOT2,
	UTS15_INSERT,
	UTS15_AFTER_RELOAD,
	UTS15_START_RELOAD,
	UTS15_DRAW,
}

enum _:UTS15_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/uts15-1.wav",
};

enum _:UTS15_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_uts15.mdl",
	"models/p_xm1014.mdl",
	"models/w_xm1014.mdl",
};

new Weapon;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon 		= CreateWeapon("uts15", Shotgun, "UTS-15");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_uts15");
	BuildWeaponDeploy			(Weapon, UTS15_DRAW, 1.0);
	BuildWeaponReload			(Weapon, UTS15_INSERT, 4.5);
	BuildWeaponAmmunition		(Weapon, 16, Ammo_12Gauge);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, UTS15_SHOOT1, UTS15_SHOOT2);
	BuildWeaponReloadShotgun	(Weapon, 0.53, WShotgunReload_TypeM3Style);
	// BuildWeaponFlags			(Weapon, WFlag_DisableReload);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SHOTGUNS,
		Weapon,
		"UTS-15",
		"uts15",
		_:Ammo_12Gauge,
		"buckshot",
		16,32
	);	
}
