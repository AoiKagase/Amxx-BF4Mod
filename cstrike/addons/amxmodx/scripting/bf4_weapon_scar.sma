
#include <amxmodx>
#include <reapi>
#include <cswm>
#include <bf4weapons>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#pragma semicolon 1
#pragma compress 1

#define PLUGIN			"[BF4 Weapons] SCAR-L/H"
#define VERSION			"0.1"
#define AUTHOR			"Aoi.Kagase"

// P228 Damage is 32.0
#define FIRE1_RATE		GetWeaponDefaultDelay(CSW_SG552)
#define FIRE1_DAMAGE	(M4A1_DAMAGE / AK47_DAMAGE)
#define FIRE1_RECOIL 	0.75

enum _:SCAR_ANIMS
{
	SCAR_L_IDLE,
	SCAR_L_RELOAD,
	SCAR_L_DRAW,
	SCAR_L_SHOOT1,
	SCAR_L_SHOOT2,
	SCAR_L_SHOOT3,
	SCAR_L_HCHANGE,
	SCAR_H_IDLE,
	SCAR_H_RELOAD,
	SCAR_H_DRAW,
	SCAR_H_SHOOT1,
	SCAR_H_SHOOT2,
	SCAR_H_SHOOT3,
	SCAR_H_LCHANGE,
};

enum _:SCAR_SOUNDS
{
	SND_FIRE_L,
	SND_FIRE_H,
};
new const gSound[][] =
{
	"bf4_ranks/weapons/scar_l.wav",
	"bf4_ranks/weapons/scar_h.wav",
};

enum _:SCAR_MODELS
{
	V_MODEL,
	P_MODEL,
	W_MODEL,
};
new const gModels[][] =
{
	"models/bf4_ranks/weapons/v_scar.mdl",
	"models/bf4_ranks/weapons/p_scar.mdl",
	"models/bf4_ranks/weapons/w_scar.mdl",
};

new Weapon;
new gWpnIdx;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	Weapon = CreateWeapon("scar", Rifle, "SCAR-L/H");

	BuildWeaponModels			(Weapon, gModels[V_MODEL], gModels[P_MODEL], gModels[W_MODEL]);
	BuildWeaponList				(Weapon, "bf4_ranks/weapons/weapon_scar");
	BuildWeaponDeploy			(Weapon, SCAR_L_DRAW, 0.0);
	BuildWeaponReload			(Weapon, SCAR_L_RELOAD, 3.0);
	BuildWeaponAmmunition		(Weapon, 30, Ammo_556Nato);
	BuildWeaponFireSound		(Weapon, gSound[SND_FIRE_L]);
	BuildWeaponPrimaryAttack	(Weapon, FIRE1_RATE, FIRE1_DAMAGE, FIRE1_RECOIL, SCAR_L_SHOOT1, SCAR_L_SHOOT2, SCAR_L_SHOOT3);
	BuildWeaponSecondaryAttack	(Weapon, A2_Switch, 
		SCAR_L_HCHANGE, 5.7, 			// SwitchAnim, SwitchAnimDuration
		SCAR_H_LCHANGE, 5.7,			// ReturnAnim, ReturnAnimDuration
		SCAR_H_IDLE, 					// IdleAnim
		SCAR_H_DRAW, 0.0, 				// DrawAnim, DrawAnimDuration
		SCAR_H_SHOOT1, 0.85, 			// ShootAnim, ShootAnimDuration,
		SCAR_H_RELOAD, 3.7, 			// ReloadAnim, ReloadAnimDuration
		FIRE1_RATE + 0.02,				// Delay,
		FIRE1_DAMAGE + 1.2, 			// Damage,
		FIRE1_RECOIL / 1.3,				// Recoil
		gSound[SND_FIRE_H]				// FireSound
	);
	RegisterWeaponForward		(Weapon, WForward_PrimaryAttackPost, "PrimaryAttackPost");

	PrecacheWeaponModelSounds	(Weapon);
	PrecacheWeaponListSprites	(Weapon);

	gWpnIdx = BF4RegisterWeapon(BF4_TEAM_US, 
		BF4_CLASS_SELECTABLE | BF4_CLASS_ASSAULT, 
		BF4_WEAPONCLASS_ASSAULTS,
		Weapon,
		"FN SCAR-L/H",
		"scar",
		_:Ammo_556Nato,
		"556nato"
	);
}

const m_flAccuracy = 62;
public PrimaryAttackPre(Entity)
{
	new id = get_member(Entity, m_pPlayer);
	if (BF4HaveThisWeapon(id, gWpnIdx))
	{
	    // static Float:Accuracy;
	    // Accuracy = ((100.0 - 50.0) * 1.5) / 100.0;
	    // set_pdata_float(Entity, 62, Accuracy, 4);
	}
}

public PrimaryAttackPost(Entity)
{
	new id = get_member(Entity, m_pPlayer);
	new Float:push[3];
	if((pev(id, pev_flags) & FL_ONGROUND))
	{
		if (GetWeaponClip(Entity) > 0)
		{
			new a2 = GetWeaponEntityData(Entity, WED_INA2);
			// client_print(id, print_chat, "ATTACK MODE = %d", a2);
			if (a2)
			{
				pev(id, pev_punchangle, push);
				push[1] = push[1] * 2.0;
				push[0] = push[0] / 2.0;
				set_pev(id, pev_punchangle, push);
			}
		}
	}
}