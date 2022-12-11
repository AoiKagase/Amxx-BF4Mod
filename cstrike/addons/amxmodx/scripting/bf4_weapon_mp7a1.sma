
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>
#include <bf4weapons>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] MP7A1"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_MP5NAVY)
#define FIRE1_DAMAGE	(MP5N_DAMAGE / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.14

enum _:MP7A1_ANIMS
{
	MP7A1_IDLE,
	MP7A1_RELOAD,
	MP7A1_DRAW,
	MP7A1_SHOOT1,
	MP7A1_SHOOT2,
	MP7A1_SHOOT3,
	MP7A1_CHANGE,
	MP7A1_CARBIN_IDLE,
	MP7A1_CARBIN_RELOAD,
	MP7A1_CARBIN_DRAW,
	MP7A1_CARBIN_SHOOT1,
	MP7A1_CARBIN_SHOOT2,
	MP7A1_CARBIN_SHOOT3,
	MP7A1_CARBIN_CHANGE,
};

enum _:MP7A1_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/mp7-1.wav",
};

enum _:MP7A1_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_mp7a1.mdl",
	"models/bf4_ranks/weapons/p_mp7a1.mdl",
	"models/bf4_ranks/weapons/w_mp7a1.mdl",
};

new Weapon;
new CAmmo;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon 		= CreateWeapon("mp7a1", Rifle, "H&K MP7A1");
	CAmmo 		= CreateAmmo(75, 20, 80);

	SetAmmoName					(CAmmo, "4.6x30mm");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_mp7a1");
	BuildWeaponDeploy			(Weapon, MP7A1_DRAW, 0.0);
	BuildWeaponReload			(Weapon, MP7A1_RELOAD, 3.6);
	BuildWeaponAmmunition		(Weapon, 20, CAmmo);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponFlags			(Weapon, WFlag_SwitchMode_NoText);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, MP7A1_SHOOT1, MP7A1_SHOOT2, MP7A1_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Switch, 
		MP7A1_CHANGE, 5.0, 					// SwitchAnim, SwitchAnimDuration
		MP7A1_CARBIN_CHANGE, 5.0,			// ReturnAnim, ReturnAnimDuration
		MP7A1_CARBIN_IDLE, 					// IdleAnim
		MP7A1_CARBIN_DRAW, 0.0, 			// DrawAnim, DrawAnimDuration
		MP7A1_CARBIN_SHOOT1, FIRE1_RATE, 	// ShootAnim, ShootAnimDuration,
		MP7A1_CARBIN_RELOAD, 3.7, 			// ReloadAnim, ReloadAnimDuration
		FIRE1_RATE + 0.2,					// Delay,
		FIRE1_DAMAGE - 0.2, 				// Damage,
		FIRE1_RECOIL - 0.3,					// Recoil
		gSound[SND_FIRE1]					// FireSound
	);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SMGS, 
		Weapon,
		"H&K MP7A1",
		"mp7a1",
		CAmmo,
		"4.6x30mm",
		20,80
	);	
}
