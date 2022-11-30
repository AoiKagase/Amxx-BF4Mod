
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>
#include <bf4weapons>
#include <cswm>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] SPAS-12"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_M3)
#define FIRE1_DAMAGE	(M3_DAMAGE / XM1014_DAMAGE)
#define FIRE1_RECOIL 	1.0

enum _:SPAS12_ANIMS
{
	SPAS12_IDLE,
	SPAS12_SHOOT1,
	SPAS12_SHOOT2,
	SPAS12_INSERT,
	SPAS12_AFTER_RELOAD,
	SPAS12_START_RELOAD,
	SPAS12_DRAW,
	SPAS12_SHOOT3,
};

enum _:SPAS12_SOUNDS
{
	SND_FIRE1,
};

new const gSound[][] =
{
	"bf4_ranks/weapons/spas12-1.wav",
};

enum _:SPAS12_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_spas12.mdl",
	"models/p_m3.mdl",
	"models/w_m3.mdl",
};

new Weapon;
new gWpnIdx;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	// Secondary Semi-auto logic.
	RegisterHam(Ham_Item_PostFrame, "weapon_xm1014", "PrimaryAttackPre",  0);
	RegisterHam(Ham_Item_PostFrame, "weapon_xm1014", "PrimaryAttackPost", 1);	

	// RegisterHam(Ham_Weapon_Reload, "weapon_xm1014", "Reload", 1);	
}

public plugin_precache()
{
	Weapon 		= CreateWeapon("spas12", Shotgun, "SPAS-12");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_spas12");
	BuildWeaponDeploy			(Weapon, SPAS12_DRAW, 0.0);
	BuildWeaponReload			(Weapon, SPAS12_INSERT, 0.53);
	BuildWeaponAmmunition		(Weapon, 9, Ammo_12Gauge);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE1]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, SPAS12_SHOOT1, SPAS12_SHOOT2);
	BuildWeaponSecondaryAttack	(Weapon, A2_InstaSwitch, SPAS12_SHOOT1, GetWeaponDefaultDelay(CSW_XM1014), 0.85, 1.1, "Semi-auto mode.", "Manual mode.");
	BuildWeaponReloadShotgun	(Weapon, 0.53, WShotgunReload_TypeXM1014Style);
	// BuildWeaponFlags			(Weapon, WFlag_DisableReload);
	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	gWpnIdx = BF4RegisterWeapon(BF4_TEAM_BOTH,
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT | BF4_CLASS_ENGINEER, 
		BF4_WEAPONCLASS_SHOTGUNS,
		Weapon,
		"SPAS-12",
		"spas12",
		_:Ammo_12Gauge,
		"buckshot"
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
public Reload(Entity)
{
	// Safety.
	if (!pev_valid(Entity))
		return HAM_IGNORED;

	// Get Owner ID.
	new id = pev(Entity, pev_owner);
	client_print(id, print_chat, "[BF4 DEBUG] RELOAD.");
	return HAM_IGNORED;
}