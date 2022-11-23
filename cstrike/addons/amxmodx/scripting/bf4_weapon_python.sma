
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] Python"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_P228)
#define FIRE1_DAMAGE	(30.0 / 32.0)
#define FIRE1_RECOIL 	1.17

enum _:PYTHON_ANIMS
{
	PYTHON_IDLE,
	PYTHON_SHOOT1,
	PYTHON_SHOOT2,
	PYTHON_SHOOT_LAST,
	PYTHON_RELOAD,
	PYTHON_DRAW,
};

enum _:PYTHON_SOUNDS
{
	SND_FIRE1,
	SND_FIRE2,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/python-1.wav",
	"bf4_ranks/weapons/python-2.wav",
};

enum _:PYTHON_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_python.mdl",
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
	Weapon = CreateWeapon("PYTHON", Pistol, "Python");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_python");
	BuildWeaponDeploy			(Weapon, PYTHON_DRAW, 0.0);
	BuildWeaponReload			(Weapon, PYTHON_RELOAD, 2.0);
	BuildWeaponAmmunition		(Weapon, 6, Ammo_357SIG);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, PYTHON_SHOOT1);
	BuildWeaponSecondaryAttack	(Weapon, A2_None);

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	RegisterWeaponForward		(Weapon, WForward_PrimaryAttackPost, 	"PYTHON_PrimaryPost");

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_PISTOLS, 
		Weapon,
		"Python",
		"python",
		_:Ammo_357SIG,
		"357sig"
	);
}

public PYTHON_PrimaryPost(Entity)
{
	if (GetWeaponClip(Entity) <= 0)
		SendWeaponAnim(Entity, PYTHON_SHOOT_LAST);
}

