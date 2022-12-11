
#include <amxmodx>
#include <bf4weapons>
#include <fakemeta>
#include <reapi>
#include <xs>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] HK121"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M249)
#define FIRE1_DAMAGE	((M249_DAMAGE + 1.0) / AK47_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:HK121_ANIMS
{
	HK121_IDLE,
	HK121_SHOOT1,
	HK121_SHOOT2,
	HK121_RELOAD,
	HK121_DRAW,
};

enum _:HK121_SOUNDS
{
	SND_FIRE1,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/hk121-1.wav",
};

enum _:HK121_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_hk121.mdl",
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
	Weapon  = CreateWeapon("hk121", Rifle, "HK121");

	CAmmo   = CreateAmmo(200, 100, 200);
	SetAmmoName(CAmmo, "762Natobox");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_hk121");
	BuildWeaponDeploy			(Weapon, HK121_DRAW, 1.0);
	BuildWeaponReload			(Weapon, HK121_RELOAD, 4.7);
	BuildWeaponAmmunition		(Weapon, 100, CAmmo);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, HK121_SHOOT1, HK121_SHOOT2);

	BuildWeaponSecondaryAttack	(Weapon, A2_Zoom, Zoom_Rifle);
	RegisterWeaponForward		(Weapon, WForward_PrimaryAttackPost, "SecondaryAttackPost");
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	BF4RegisterWeapon(BF4_TEAM_US, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_SUPPORT, 
		BF4_WEAPONCLASS_LMGS,
		Weapon,
		"HK121",
		"hk121",
		CAmmo,
		"762Natobox",
		100,200
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