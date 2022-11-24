
#include <amxmodx>
#include <hamsandwich>
#include <bf4weapons>
#include <fakemeta>
#include <reapi>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] Kriss Super V"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_MP5NAVY)
#define FIRE1_DAMAGE	(30.0 / 36.0)
#define FIRE1_RECOIL 	1.14


enum _:KRISS_ANIMS
{
	KRISS_IDLE,
	KRISS_RELOAD,
	KRISS_DRAW,
	KRISS_SHOOT1,
	KRISS_SHOOT2,
	KRISS_SHOOT3,
	KRISS_SILENCER_ADD,
	KRISS_SIL_IDLE,
	KRISS_SIL_RELOAD,
	KRISS_SIL_DRAW,
	KRISS_SIL_SHOOT1,
	KRISS_SIL_SHOOT2,
	KRISS_SIL_SHOOT3,
	KRISS_SILENCER_REM,
};

enum _:KRISS_SOUNDS
{
	SND_FIRE1,
	SND_SIL_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/kriss-1.wav",
	"bf4_ranks/weapons/kriss_sil-1.wav"
};

enum _:KRISS_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};

new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_kriss.mdl",
	"models/bf4_ranks/weapons/p_kriss.mdl",
	"models/bf4_ranks/weapons/w_kriss.mdl",
};

new Weapon;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon = CreateWeapon("kriss", Rifle, "Kriss Super V");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy			(Weapon, KRISS_DRAW, 0.0);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_45ACP);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_kriss");
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload			(Weapon, KRISS_RELOAD, 3.7);
	BuildWeaponFlags			(Weapon, WFlag_SwitchMode_NoText);

	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, KRISS_SHOOT1, KRISS_SHOOT2, KRISS_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Switch, 
		KRISS_SILENCER_ADD, 2.5, 		// SwitchAnim, SwitchAnimDuration
		KRISS_SILENCER_REM, 2.0,		// ReturnAnim, ReturnAnimDuration
		KRISS_SIL_IDLE, 				// IdleAnim
		KRISS_SIL_DRAW, 0.0, 			// DrawAnim, DrawAnimDuration
		KRISS_SIL_SHOOT1, FIRE1_RATE, 	// ShootAnim, ShootAnimDuration
		KRISS_SIL_RELOAD, 3.7, 			// ReloadAnim, ReloadAnimDuration
		FIRE1_RATE,						// Delay
		FIRE1_DAMAGE - 0.2, 			// Damage
		FIRE1_RECOIL + 0.1, 			// Recoil
		gSound[SND_SIL_FIRE1]			// FireSound
	);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SMGS, 
		Weapon,
		"Kriss Super V",
		"kriss",
		_:Ammo_45ACP,
		"45acp"
	);	
}

