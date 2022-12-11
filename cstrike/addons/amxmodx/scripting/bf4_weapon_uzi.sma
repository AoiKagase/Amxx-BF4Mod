
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>
#include <bf4weapons>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] Uzi"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_MP5NAVY)
#define FIRE1_DAMAGE	(MP5N_DAMAGE / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.14

enum _:UZI_ANIMS
{
	UZI_IDLE,
	UZI_RELOAD,
	UZI_DRAW,
	UZI_SHOOT1,
	UZI_SHOOT2,
	UZI_SHOOT3,
};

enum _:UZI_SOUNDS
{
	SND_FIRE1,
	SND_FIRE2,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/uzi-1.wav",
	"bf4_ranks/weapons/uzi-2.wav",
};

enum _:UZI_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_uzi.mdl",
	"models/p_mac10.mdl",
	"models/w_mac10.mdl",
};

new Weapon;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon 		= CreateWeapon("uzi", Rifle, "Uzi");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_uzi");
	BuildWeaponDeploy			(Weapon, UZI_DRAW, 0.0);
	BuildWeaponReload			(Weapon, UZI_RELOAD, 3.6);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_9MM);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, UZI_SHOOT1, UZI_SHOOT2, UZI_SHOOT3);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_RU, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SMGS, 
		Weapon,
		"Uzi",
		"uzi",
		_:Ammo_9MM,
		"9mm",
		30,120
	);	
}
