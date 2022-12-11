
#include <amxmodx>
#include <bf4weapons>
#include <fakemeta>
#include <reapi>
#include <xs>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] PKM"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M249)
#define FIRE1_DAMAGE	((M249_DAMAGE + 1.0) / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:PKM_ANIMS
{
	PKM_IDLE,
	PKM_SHOOT1,
	PKM_SHOOT2,
	PKM_RELOAD,
	PKM_DRAW,
};

enum _:PKM_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/pkm-1.wav",
};

enum _:PKM_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_pkm.mdl",
	"models/p_m249.mdl",
	"models/w_m249.mdl",
};

new Weapon;
new CAmmo;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon  = CreateWeapon("pkm", Rifle, "PKM");

	CAmmo   = CreateAmmo(200, 100, 200);
	SetAmmoName(CAmmo, "762Natobox");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_pkm");
	BuildWeaponDeploy			(Weapon, PKM_DRAW, 1.0);
	BuildWeaponReload			(Weapon, PKM_RELOAD, 4.7);
	BuildWeaponAmmunition		(Weapon, 150, CAmmo);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, PKM_SHOOT1, PKM_SHOOT2);
	BuildWeaponSecondaryAttack	(Weapon, A2_Burst, 3);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_SUPPORT, 
		BF4_WEAPONCLASS_LMGS,
		Weapon,
		"PKM",
		"pkm",
		CAmmo,
		"762Natobox",
		100,200
	);		
}
