
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] PSG-1"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_G3SG1)
#define FIRE1_DAMAGE	((G3SG1_DAMAGE) / AWP_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:PSG1_ANIMS
{
	PSG1_IDLE,
	PSG1_SHOOT1,
	PSG1_SHOOT2,
	PSG1_RELOAD,
	PSG1_DRAW,
};

enum _:PSG1_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/psg1-1.wav",
};

enum _:PSG1_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_psg1.mdl",
	"models/p_g3sg1.mdl",
	"models/w_g3sg1.mdl",
};

new Weapon;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("psg1", Rifle, "PSG-1");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_psg1");
	BuildWeaponDeploy			(Weapon, PSG1_DRAW, 1.0);
	BuildWeaponReload			(Weapon, PSG1_RELOAD, 3.6);
	BuildWeaponAmmunition		(Weapon, 5, Ammo_762Nato);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, PSG1_SHOOT1, PSG1_SHOOT2);
	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_SniperB);
	BuildWeaponFlags			(Weapon, WFlag_AutoSniper);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_US, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON, 
		BF4_WEAPONCLASS_DMRS,
		Weapon,
		"PSG-1",
		"psg1",
		_:Ammo_762Nato,
		"762Nato",
		5,90
	);		
}
