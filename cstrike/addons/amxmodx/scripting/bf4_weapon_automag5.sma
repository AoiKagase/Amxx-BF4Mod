
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] Automag V"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_DEAGLE)
#define FIRE1_DAMAGE	(41.0 / 32.0)
#define FIRE1_RECOIL 	1.33


enum _:AUTOMAG5_ANIMS
{
	AUTOMAG5_IDLE,
	AUTOMAG5_SHOOT1,
	AUTOMAG5_SHOOT2,
	AUTOMAG5_SHOOT_LAST,
	AUTOMAG5_RELOAD,
	AUTOMAG5_DRAW,
};

enum _:AUTOMAG5_SOUNDS
{
	SND_FIRE1,
	SND_FIRE2,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/amg-1.wav",
	"bf4_ranks/weapons/amg-2.wav",
};

enum _:AUTOMAG5_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_automag5.mdl",
	"models/p_deagle.mdl",
	"models/w_deagle.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon = CreateWeapon("automag5", Pistol, "AUTOMAG V");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy			(Weapon, AUTOMAG5_DRAW, 0.0);
	BuildWeaponReload			(Weapon, AUTOMAG5_RELOAD, 2.2);
	BuildWeaponAmmunition		(Weapon, 7, Ammo_50AE);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_automag5");
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, AUTOMAG5_SHOOT1, AUTOMAG5_SHOOT2);
	BuildWeaponSecondaryAttack	(Weapon, A2_None);
	RegisterWeaponForward		(Weapon, WForward_PrimaryAttackPost, 	"AUTOMAG5_PrimaryPost");

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_PISTOLS, 
		Weapon,
		"AUTOMAG V",
		"automag5",
		_:Ammo_50AE,
		"50ae"
	);		
}

public AUTOMAG5_PrimaryPost(Entity)
{
	if (GetWeaponClip(Entity) <= 0)
		SendWeaponAnim(Entity, AUTOMAG5_SHOOT_LAST);
}

