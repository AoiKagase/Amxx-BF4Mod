
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

#define PLUGIN		"[BF4 Weapons] H&K G11"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(30.0 / 32.0)
#define RECOIL 			1.56

#define FIRE_RATE		GetWeaponDefaultDelay(CSW_M4A1)

enum _:G11_ANIMS
{
	G11_IDLE,
	G11_RELOAD,
	G11_DRAW,
	G11_SHOOT1,
	G11_SHOOT2,
	G11_SHOOT3,
};

enum _:G11_SOUNDS
{
	SND_CLIPIN1,
	SND_CLIPIN2,
	SND_CLIPOUT,
	SND_DRAW,
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/g11_clipin1.wav",
	"bf4_ranks/weapons/g11_clipin2.wav",
	"bf4_ranks/weapons/g11_clipout.wav",
	"bf4_ranks/weapons/g11_draw.wav",
	"bf4_ranks/weapons/g11-1.wav",
};

enum _:G11_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_g11.mdl",
	"models/p_famas.mdl",
	"models/w_famas.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon      = CreateWeapon("g11", Rifle, "H&K G11");
	new CAmmo	= CreateAmmo(150, 50, 100);
	SetAmmoName(CAmmo, "4.73x33mm");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, G11_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 50, CAmmo);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_g11");
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, G11_RELOAD, 3.8);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, G11_SHOOT1);
	BuildWeaponSecondaryAttack(Weapon, A2_Burst, 3);

	PrecacheWeaponModelSounds(Weapon);
	for(new i = 0; i < sizeof(gSound); i++)
		precache_sound(gSound[i]);

	PrecacheWeaponListSprites(Weapon);


	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS, 
		Weapon,
		"H&K G11",
		"g11",
		CAmmo,
		"4.73x33mm"
	);
}
