
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>
#include <bf4weapons>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] USAS-12"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_XM1014)
#define FIRE1_DAMAGE	(M3_DAMAGE / XM1014_DAMAGE)
#define FIRE1_RECOIL 	1.5

enum _:USAS12_ANIMS
{
	USAS12_IDLE,
	USAS12_DRAW,
	USAS12_RELOAD_1,
	USAS12_SHOOT1,
	USAS12_SHOOT2,
	USAS12_RELOAD_2,
	USAS12_RELOAD_3,
	USAS12_RELOAD_4,
};

enum _:USAS12_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/usas-1.wav",
};

enum _:USAS12_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_usas.mdl",
	"models/bf4_ranks/weapons/p_usas.mdl",
	"models/bf4_ranks/weapons/w_usas.mdl",
};

new Weapon;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon 		= CreateWeapon("usas", Shotgun, "USAS-12");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_usas12");
	BuildWeaponDeploy			(Weapon, USAS12_DRAW, 0.0);
	BuildWeaponReload			(Weapon, USAS12_RELOAD_2, 4.5);
	BuildWeaponAmmunition		(Weapon, 20, Ammo_12Gauge);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, USAS12_SHOOT1, USAS12_SHOOT2);
	BuildWeaponReloadShotgun	(Weapon, 4.5, WShotgunReload_TypeRifleStyle);
	// BuildWeaponFlags			(Weapon, WFlag_DisableReload);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SHOTGUNS,
		Weapon,
		"USAS-12",
		"usas12",
		_:Ammo_12Gauge,
		"buckshot",
		20,32
	);	
}
