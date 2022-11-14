
#include <amxmodx>
#include <amxmodx>
#include <reapi>
#include <bf4const>
#include <cswm>
#include <cswm_const>
#include <csx>
#include <hamsandwich>
#include <fakemeta>
#include <bf4weapons>

#pragma semicolon 1
#pragma compress 1

#define CANNON_NEXTATTACK EV_FL_fuser4

#define PLUGIN		"[BF4 Weapons] FNP-45"
#define VERSION		"0.1"
#define AUTHOR		"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_DAMAGE	(30.0 / 32.0)
#define RECOIL 			0.19

#define FIRE_RATE		GetWeaponDefaultDelay(CSW_USP)
enum _:FNP45_ANIMS
{
	FNP45_IDLE,
	FNP45_SHOOT1,
	FNP45_SHOOT2,
	FNP45_SHOOT3,
	FNP45_SHOOT_LAST,
	FNP45_RELOAD,
	FNP45_DRAW,
};

enum _:FNP45_SOUNDS
{
	SND_CLIPIN1,
	SND_CLIPIN2,
	SND_CLIPOUT,
	SND_DRAW,
	SND_FIRE1,
	SND_FIRE2,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/fnp45_clipin1.wav",
	"bf4_ranks/weapons/fnp45_clipin2.wav",
	"bf4_ranks/weapons/fnp45-clipout.wav",
	"bf4_ranks/weapons/fnp45-draw.wav",
	"bf4_ranks/weapons/fnp45-1.wav",
	"bf4_ranks/weapons/fnp45-2.wav",
};

enum _:FNP45_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_fnp45.mdl",
	"models/p_p228.mdl",
	"models/w_p228.mdl",
};
const m_pPlayer = 41;
new Weapon;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon      = CreateWeapon("fnp45", Pistol, "FNP-45");

	BuildWeaponModels(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy(Weapon, FNP45_DRAW, 0.0);
	BuildWeaponAmmunition(Weapon, 15, Ammo_45ACP);
	BuildWeaponList(Weapon, "bf4_ranks/weapons/weapon_fnp45");
	BuildWeaponSecondaryAttack(Weapon, A2_None);
	BuildWeaponFireSound(Weapon, gSound[SND_FIRE1]);
	BuildWeaponReload(Weapon, FNP45_RELOAD, 2.5);
	BuildWeaponPrimaryAttack(Weapon, FIRE_RATE, FIRE1_DAMAGE, RECOIL, FNP45_SHOOT1);
	RegisterWeaponForward(Weapon, WForward_PrimaryAttackPost, 	"FNP45_PrimaryPost");

	PrecacheWeaponModelSounds(Weapon);
	for(new i = 0; i < sizeof(gSound); i++)
		precache_sound(gSound[i]);

	PrecacheWeaponListSprites(Weapon);

	BF4RegisterWeapon(BF4_TEAM_BOTH, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_SUPPORT | BF4_CLASS_RECON | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_PISTOLS, 
		Weapon,
		Ammo_45ACP,
		"FN FNP-45",
		"fnp45");
}
public AddPlayerItem(pPlayer, pItem)
{
	rg_set_iteminfo(pItem, ItemInfo_pszName, "fnp45");
}

public FNP45_PrimaryPost(Entity)
{
	if (GetWeaponClip(Entity) <= 0)
		SendWeaponAnim(Entity, FNP45_SHOOT_LAST);
	// new Player = get_ent_data(Entity, "CBaseMonster","m_pPlayer");
	// custom_weapon_shot(gCSXID, Player);
}
