
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] AN-94"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_AK47)
#define FIRE1_DAMAGE	((AK47_DAMAGE) / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.14

enum _:AN94_ANIMS
{
	AN94_IDLE,
	AN94_RELOAD,
	AN94_DRAW,
	AN94_SHOOT1,
	AN94_SHOOT2,
	AN94_SHOOT3,
};

enum _:AN94_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/an94-1.wav",
};

enum _:AN94_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};

new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_an94.mdl",
	"models/bf4_ranks/weapons/p_an94.mdl",
	"models/bf4_ranks/weapons/w_an94.mdl",
};

new Weapon;
new CAmmo;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon 	= CreateWeapon("an94", Rifle, "AN-94");
	CAmmo	= CreateAmmo(150, 30, 90);

	SetAmmoName					(CAmmo, "5.45x39mm");
	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy			(Weapon, AN94_DRAW, 0.0);
	BuildWeaponReload			(Weapon, AN94_RELOAD, 2.3);
	BuildWeaponAmmunition		(Weapon, 30, CAmmo);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_an94");
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, AN94_SHOOT1, AN94_SHOOT2, AN94_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Burst, 2);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_RU, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS, 
		Weapon,
		"AN-94",
		"an94",
		CAmmo,
		"5.45x39mm",
		30,
		90
	);
}

