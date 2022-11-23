
#include <amxmodx>
#include <amxmodx>
#include <bf4const>
#include <cswm>
#include <cswm_const>
#include <hamsandwich>
#include <fakemeta>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define CANNON_NEXTATTACK EV_FL_fuser4

#define PLUGIN		"[BF4 Weapons] AmmoBox Briefcase"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(30.0 / 32.0)
#define RECOIL 			1.56

#define FIRE_RATE		10

enum _:AMMOBOX_ANIMS
{
	AMMOBOX_IDLE,
	AMMOBOX_DRAW,
	AMMOBOX_HOLSTER,
	AMMOBOX_USE,
};

enum _:AMMOBOX_SOUNDS
{
	SND_DEPLOY,
	SND_OPEN,
	SND_USE,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/briefcase_deploy.wav",
	"bf4_ranks/weapons/briefcase_open.wav",
	"bf4_ranks/weapons/briefcase_use.wav",
};

enum _:AMMOBOX_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_briefcase.mdl",
	"models/bf4_ranks/weapons/p_briefcase.mdl",
	"models/bf4_ranks/weapons/w_briefcase.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon      = CreateWeapon("briefcase", Pistol, "AmmoBox Briefcase");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, AMMOBOX_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 0, Ammo_None);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_briefcase");
	BuildWeaponSecondaryAttack(Weapon, A2_None);
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, AMMOBOX_RELOAD, 2.2);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, AMMOBOX_SHOOT1);
	RegisterWeaponForward(Weapon, WForward_PrimaryAttackPost, 	"AMMOBOX_PrimaryPost");

	PrecacheWeaponModelSounds(Weapon);
	for(new i = 0; i < sizeof(gSound); i++)
		precache_sound(gSound[i]);

	PrecacheWeaponListSprites(Weapon);


	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_REQUIRE | BF4_CLASS_SUPPORT,
		BF4_WEAPONCLASS_EXTRA,
		Weapon,
		"AmmoBox Briefcase",
		"ammobox_briefcase",
		_:Ammo_None,
		""
	);
}

public AMMOBOX_PrimaryPost(Entity)
{
	if (GetWeaponClip(Entity) <= 0)
		SendWeaponAnim(Entity, AMMOBOX_SHOOT_LAST);
}
