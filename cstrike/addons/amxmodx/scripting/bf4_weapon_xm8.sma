
#include <amxmodx>
#include <reapi>
#include <cswm>
#include <bf4weapons>
#include <xs>
#include <fakemeta>
#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] XM8"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_SG552)
#define FIRE1_DAMAGE	(SG552_DAMAGE / AK47_DAMAGE)
#define FIRE1_RECOIL 	0.98

enum _:XM8_ANIMS
{
	XM8_IDLE,
	XM8_RELOAD,
	XM8_DRAW,
	XM8_SHOOT1,
	XM8_SHOOT2,
	XM8_SHOOT3,
};

enum _:XM8_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/xm8_carbine.wav",
};

enum _:XM8_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};

new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_xm8limit.mdl",
	"models/bf4_ranks/weapons/p_xm8.mdl",
	"models/bf4_ranks/weapons/w_xm8.mdl",
};

new Weapon;
// new CAmmo;
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon 	= CreateWeapon("xm8", Rifle, "H&K XM8");
	// CAmmo	= CreateAmmo(150, 30, 90);

	// SetAmmoName					(CAmmo, "5.45x39mm");
	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy			(Weapon, XM8_DRAW, 0.0);
	BuildWeaponReload			(Weapon, XM8_RELOAD, 3.5);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_556Nato);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_xm8");
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, XM8_SHOOT1, XM8_SHOOT2, XM8_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_Rifle);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);
	RegisterWeaponForward		(Weapon, WForward_PrimaryAttackPost, "SecondaryAttackPost");

	BF4RegisterWeapon(BF4_TEAM_RU, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS, 
		Weapon,
		"H&K XM8",
		"xm8",
		_:Ammo_556Nato,
		"556nato",
		30,90
	);
}

public SecondaryAttackPost(Weapon)
{
	new id = get_member(Weapon, m_pPlayer);
	new Float:push[3];
	if (GetWeaponClip(Weapon) > 0)
	{
		if((pev(id, pev_flags) & FL_ONGROUND))
		{
			new a2 = GetWeaponEntityData(Weapon, WED_INA2);
			// client_print(id, print_chat, "ATTACK MODE = %d", a2);
			if (a2)
			{
				pev(id, pev_punchangle, push);
				xs_vec_mul_scalar(push, 0.5, push);
				set_pev(id, pev_punchangle, push);
				SetNextAttack(Weapon, FIRE1_RATE * 2.0, true);
			}
		}
	}
}