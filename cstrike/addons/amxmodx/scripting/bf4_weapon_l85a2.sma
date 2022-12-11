
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] L85A2"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M4A1)
#define FIRE1_DAMAGE	(37.0 / 32.0)
#define FIRE1_RECOIL 	1.24

enum _:L85A2_ANIMS
{
	L85A2_IDLE,
	L85A2_RELOAD,
	L85A2_DRAW,
	L85A2_SHOOT1,
	L85A2_SHOOT2,
	L85A2_SHOOT3,
};

enum _:L85A2_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/l85-1.wav",
};

enum _:L85A2_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_l85a2.mdl",
	"models/bf4_ranks/weapons/p_l85a2.mdl",
	"models/bf4_ranks/weapons/w_l85a2.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon = CreateWeapon("l85a2", Rifle, "L85A2");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_l85a2");
	BuildWeaponDeploy			(Weapon, L85A2_DRAW, 0.0);
	BuildWeaponReload			(Weapon, L85A2_RELOAD, 3.0);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_556Nato);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, L85A2_SHOOT1, L85A2_SHOOT2, L85A2_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Burst, 3);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_US, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS,
		Weapon,
		"H&K L85A2",
		"l85a2",
		_:Ammo_556Nato,
		"556nato",
		30,90
	);		
}
