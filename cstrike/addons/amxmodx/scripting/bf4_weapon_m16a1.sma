
#include <amxmodx>
#include <cswm>
#include <bf4weapons>
#include <fakemeta>
#include <hamsandwich>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] COLT M16A1"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M4A1)
#define FIRE1_DAMAGE	(M4A1_DAMAGE / AK47_DAMAGE)
#define FIRE1_RECOIL 	0.80

enum _:M16A1_ANIMS
{
	M16A1_IDLE,
	M16A1_RELOAD,
	M16A1_DRAW,
	M16A1_SHOOT1,
	M16A1_SHOOT2,
	M16A1_SHOOT3,
};

enum _:M16A1_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/m16a1-1.wav",
};

enum _:M16A1_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};

new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_m16a1.mdl",
	"models/p_m4a1.mdl",
	"models/w_m4a1.mdl",
};

new Weapon;
new gWpnIdx;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	// Secondary Semi-auto logic.
	RegisterHam(Ham_Item_PostFrame, "weapon_ak47", "PrimaryAttackPre",  0);
	RegisterHam(Ham_Item_PostFrame, "weapon_ak47", "PrimaryAttackPost", 1);
}

public plugin_precache()
{
	Weapon 	= CreateWeapon("m16a1", Rifle, "COLT M16A1");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponDeploy			(Weapon, M16A1_DRAW, 0.0);
	BuildWeaponReload			(Weapon, M16A1_RELOAD, 3.8);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_556Nato);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_m16a1");
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, M16A1_SHOOT1, M16A1_SHOOT2, M16A1_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_InstaSwitch, M16A1_SHOOT1, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, "Semi-auto mode.", "Automatic mode.");
	// RegisterWeaponForward		(Weapon, WForward_PrimaryAttackPost, "PrimaryAttack");

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	gWpnIdx = BF4RegisterWeapon(BF4_TEAM_US, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS, 
		Weapon,
		"COLT M16A1",
		"m16a1",
		_:Ammo_556Nato,
		"556nato",
		30,90
	);
}

public PrimaryAttackPre(Entity)
{
	// Safety.
	if (!pev_valid(Entity))
		return HAM_IGNORED;

	// Get Owner ID.
	new id = pev(Entity, pev_owner);

	// This Weapon?
	if (BF4HaveThisWeapon(id, gWpnIdx))
	{
		// Secondary Mode On.
		new a2 = GetWeaponEntityData(Entity, WED_INA2);
		if (a2)
		{
			// Already First shot?
			if (get_ent_data(Entity, "CBasePlayerWeapon", "m_iShotsFired")) 
			{
				// Blocked next shot.
				set_ent_data(id, "CBasePlayer", "m_bCanShoot", 0);

				// Next Attack time.
				set_ent_data_float(Entity, "CBasePlayerWeapon", "m_flNextPrimaryAttack", 0.1);
			}
		}
	}

	return HAM_IGNORED;
}

public PrimaryAttackPost(Entity)
{
	// Safety.
	if (!pev_valid(Entity))
		return HAM_IGNORED;

	// Get Owner ID.
	new id = pev(Entity, pev_owner);

	// This Weapon?
	if (BF4HaveThisWeapon(id, gWpnIdx))
	{
		// Secondary Mode On.
		new a2 = GetWeaponEntityData(Entity, WED_INA2);
		if (a2)
		{
			// Attack key Released?
			if (!(pev(id, pev_button) & IN_ATTACK))
			{
				// Unblocking shot.
				set_ent_data(id, "CBasePlayer", "m_bCanShoot", 1);
				// Reset Shot count.
				set_ent_data(Entity, "CBasePlayerWeapon", "m_iShotsFired", 0);
			}
		}
	}

	return HAM_IGNORED;
}