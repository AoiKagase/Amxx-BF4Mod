
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] PGM Hecate-II"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_AWP)
#define FIRE1_DAMAGE	((AWP_DAMAGE + 1.0) / AWP_DAMAGE)
#define FIRE1_RECOIL 	1.33

enum _:PGM_ANIMS
{
	PGM_IDLE,
	PGM_SHOOT1,
	PGM_SHOOT2,
	PGM_SHOOT3,
	PGM_RELOAD,
	PGM_DRAW,
};

enum _:PGM_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/pgm-1.wav",
};

enum _:PGM_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_pgm.mdl",
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
	Weapon  = CreateWeapon("pgm", Sniper, "PGM Hecate-II");
	CAmmo	= CreateAmmo(100, 5, 50);

	SetAmmoName					(CAmmo, ".50 BGM");
	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_pgm");
	BuildWeaponDeploy			(Weapon, PGM_DRAW, 1.0);
	BuildWeaponReload			(Weapon, PGM_RELOAD, 3.2);
	BuildWeaponAmmunition		(Weapon, 7, CAmmo);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, PGM_SHOOT1, PGM_SHOOT2, PGM_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_SniperB);
//	BuildWeaponFlags			(Weapon, WFlag_AutoSniper);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_RU, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON, 
		BF4_WEAPONCLASS_SNIPERS,
		Weapon,
		"PGM Hecate-II",
		"pgm",
		CAmmo,
		"50bgm",
		5,50
	);		
}
