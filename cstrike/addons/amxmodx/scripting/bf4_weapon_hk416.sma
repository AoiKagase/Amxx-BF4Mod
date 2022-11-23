
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] H&K HK416"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M4A1)
#define FIRE1_DAMAGE	(22.0 / 32.0)
#define FIRE1_RECOIL 	0.76

enum _:HK416_ANIMS
{
	HK416_SIL_IDLE,
	HK416_SIL_SHOOT1,
	HK416_SIL_SHOOT2,
	HK416_SIL_SHOOT3,
	HK416_SIL_RELOAD,
	HK416_SIL_DRAW,
	HK416_ADD_SIL,
	HK416_IDLE,
	HK416_SHOOT1,
	HK416_SHOOT2,
	HK416_SHOOT3,
	HK416_RELOAD,
	HK416_DRAW,
	HK416_DETACH_SIL,
};

enum _:HK416_SOUNDS
{
	SND_FIRE1,
	SND_SIL_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/hk416_unsil-1.wav",
	"bf4_ranks/weapons/hk416-1.wav",
};

enum _:HK416_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_hk416.mdl",
	"models/bf4_ranks/weapons/p_hk416.mdl",
	"models/bf4_ranks/weapons/w_hk416.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon = CreateWeapon("hk416", Rifle, "HK416");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_hk416");
	BuildWeaponDeploy			(Weapon, HK416_DRAW, 0.0);
	BuildWeaponReload			(Weapon, HK416_RELOAD, 3.1);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_556Nato);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, HK416_SHOOT1, HK416_SHOOT2, HK416_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Switch, 
		HK416_ADD_SIL, 2.0, 			// SwitchAnim, SwitchAnimDuration
		HK416_DETACH_SIL, 2.0,			// ReturnAnim, ReturnAnimDuration
		HK416_SIL_IDLE, 				// IdleAnim
		HK416_SIL_DRAW, 0.0, 			// DrawAnim, DrawAnimDuration
		HK416_SIL_SHOOT1, FIRE1_RATE, 	// ShootAnim, ShootAnimDuration
		HK416_SIL_RELOAD, 3.1, 			// ReloadAnim, ReloadAnimDuration
		FIRE1_RATE,						// Delay
		FIRE1_DAMAGE - 0.2, 			// Damage
		FIRE1_RECOIL + 0.1, 			// Recoil
		gSound[SND_SIL_FIRE1]			// FireSound
	);
	BuildWeaponFlags			(Weapon, WFlag_CustomIdleAnim);
	SetWeaponIdleAnim			(Weapon, HK416_IDLE);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_US, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS,
		Weapon,
		"H&K HK416",
		"hk416",
		_:Ammo_556Nato,
		"556nato"
	);		
}
