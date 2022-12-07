
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] Barrett M95"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_AWP)
#define FIRE1_DAMAGE	((AWP_DAMAGE + 2.0) / AWP_DAMAGE)
#define FIRE1_RECOIL 	1.33

enum _:M95_ANIMS
{
	M95_IDLE,
	M95_SHOOT1,
	M95_SHOOT2,
	M95_SHOOT3,
	M95_RELOAD,
	M95_DRAW,
};

enum _:M95_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/m95-1.wav",
};

enum _:M95_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_m95.mdl",
	"models/bf4_ranks/weapons/p_m95.mdl",
	"models/bf4_ranks/weapons/w_m95.mdl",
};

new Weapon;
new CAmmo;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("m95", Sniper, "Barrett M95");
	CAmmo	= CreateAmmo(100, 5, 50);

	SetAmmoName					(CAmmo, ".50 BGM");
	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_m95");
	BuildWeaponDeploy			(Weapon, M95_DRAW, 1.0);
	BuildWeaponReload			(Weapon, M95_RELOAD, 3.9);
	BuildWeaponAmmunition		(Weapon, 5, CAmmo);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, M95_SHOOT1, M95_SHOOT2, M95_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_SniperB);
//	BuildWeaponFlags			(Weapon, WFlag_AutoSniper);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_US, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON, 
		BF4_WEAPONCLASS_SNIPERS,
		Weapon,
		"Barrett M95",
		"m95",
		CAmmo,
		"50bgm"
	);		
}
