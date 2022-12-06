
#include <amxmodx>
#include <cswm>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] SL8"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_G3SG1)
#define FIRE1_DAMAGE	(41.0 / 32.0)
#define FIRE1_RECOIL 	1.33

enum _:SL8_ANIMS
{
	SL8_IDLE,
	SL8_SHOOT1,
	SL8_SHOOT2,
	SL8_RELOAD,
	SL8_DRAW,
};

enum _:SL8_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/sl8-1.wav",
};

enum _:SL8_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_sl8.mdl",
	"models/bf4_ranks/weapons/p_sl8.mdl",
	"models/bf4_ranks/weapons/w_sl8.mdl",
};

new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon = CreateWeapon("sl8", Sniper, "SL8");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_sl8");
	BuildWeaponDeploy			(Weapon, SL8_DRAW, 0.0);
	BuildWeaponReload			(Weapon, SL8_RELOAD, 3.4);
	BuildWeaponAmmunition		(Weapon, 20, Ammo_556Nato);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, SL8_SHOOT1, SL8_SHOOT2);
	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_SniperB);
	BuildWeaponFlags			(Weapon, WFlag_AutoSniper);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_RECON, 
		BF4_WEAPONCLASS_SNIPERS,
		Weapon,
		"H&K SL8",
		"sl8",
		_:Ammo_556Nato,
		"556nato"
	);		
}
