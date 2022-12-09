
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] Walther WA2000"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_G3SG1)
#define FIRE1_DAMAGE	((G3SG1_DAMAGE + 1.0) / AWP_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:WA2000_ANIMS
{
	WA2000_IDLE,
	WA2000_SHOOT1,
	WA2000_SHOOT2,
	WA2000_RELOAD,
	WA2000_DRAW,
};

enum _:WA2000_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/wa2000-1.wav",
};

enum _:WA2000_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_wa2000.mdl",
	"models/bf4_ranks/weapons/p_wa2000.mdl",
	"models/bf4_ranks/weapons/w_wa2000.mdl",
};

new Weapon;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("wa2000", Rifle, "Walther WA2000");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_wa2000");
	BuildWeaponDeploy			(Weapon, WA2000_DRAW, 1.0);
	BuildWeaponReload			(Weapon, WA2000_RELOAD, 3.0);
	BuildWeaponAmmunition		(Weapon, 10, Ammo_762Nato);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, WA2000_SHOOT1, WA2000_SHOOT2);
	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_SniperB);
	BuildWeaponFlags			(Weapon, WFlag_AutoSniper);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON, 
		BF4_WEAPONCLASS_DMRS,
		Weapon,
		"Walther WA2000",
		"wa2000",
		_:Ammo_762Nato,
		"762Nato"
	);		
}
