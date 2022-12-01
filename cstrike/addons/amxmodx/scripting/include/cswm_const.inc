/* CSWM Incude File */

#if defined CSWM_CONST
	#endinput
#endif
#define CSWM_CONST


enum _:
{
	CSWM_IGNORED,
	CSWM_SUPERCEDE,
}

enum Ammo
{
	Ammo_None,
	Ammo_338Magnum,
	Ammo_762Nato,
	Ammo_556NatoBox,
	Ammo_556Nato,
	Ammo_BuckShot,
	Ammo_12Gauge = 5,
	Ammo_45ACP,
	Ammo_57MM,
	Ammo_50AE,
	Ammo_357SIG,
	Ammo_9MM,
	Ammo_FLASHBANG,
	Ammo_HEGRENADE,
	Ammo_SMOKEGRENADE,
	Ammo_C4,
};

enum WType
{
	Pistol,
	Shotgun,
	SMG,
	Rifle = 2,
	Machinegun = 2,
	Sniper,
}

enum WShotgunReload
{
	WShotgunReload_TypeM3Style,
	WShotgunReload_TypeXM1014Style,
	WShotgunReload_TypeRifleStyle,
};

enum
{
	Zoom_Rifle, // AUG/SG552 ZOOM
	Zoom_SniperF, // SNIPER FIRST ZOOM
	Zoom_SniperS, // SNIPER SECOND ZOOM
	Zoom_SniperB, // SNIPER BOTH ZOOM
};

enum WAttack2
{
/*
 No Parameters
*/
	A2_None,
/*
 ZoomType
*/
	A2_Zoom,
/*
 SwitchAnim
 SwitchAnimDuration
 ReturnAnim
 ReturnAnimDuration
 IdleAnim
 DrawAnim
 DrawAnimDuration
 ShootAnim
 ShootAnimDuration,
 ReloadAnim
 ReloadAnimDuration
 Delay,
 Damage,
 Recoil
 FireSound
*/
	A2_Switch,
/*
 BurstCount
*/
	A2_Burst,
/*
 MultishotCount
*/
	A2_MultiShot,
/*
 Anim
 Delay
 Recoil
*/
	A2_AutoPistol,
/*
 Animation
 Delay
 Duration
 Radius
 DamageMin
 DamageMax
 Knockback
 Sound
*/
	A2_KnifeAttack,
/*
 ShootAnim
 Delay
 Damage
 Recoil
 SwitchName
 ReturnName
*/
	A2_InstaSwitch,
/*
 It's All About You
*/
	A2_Custom,
};

/* Forward Can Be Blocked Via Returning CSWM_SUPERCEDE Value */
enum WForward
{
	WForward_SpawnPre,
	WForward_SpawnPost,
	WForward_DeployPre,
	WForward_DeployPrePost,
	WForward_DeployPost,
	WForward_PrimaryAttackPre,
	WForward_PrimaryAttackPrePost,
	WForward_PrimaryAttackPost,
	WForward_SecondaryAttackPre,
	WForward_SecondaryAttackPost,
	WForward_ReloadPre,
	WForward_ReloadPost,
	WForward_HolsterPost,
	WForward_DropPost,
	WForward_DamagePre,
	WForward_DamagePost,
};

enum WData
{
	WD_VModel,
	WD_PModel,
	WD_Model,
	WD_Name,
	WD_FireSound,
	WD_WModel,
	WD_GModel,
	WD_Type,
	WD_AnimD,
	WD_AnimS,
	WD_AnimR,
	WD_Clip,
	WD_AmmoID,
	WD_Deploy,
	WD_Reload,
	WD_Delay,
	WD_Damage,
	WD_Recoil,
	WD_Flags,
	WD_A2I,
	WD_Speed,
	WD_Forwards,
	WD_DurationList,
};

enum WEData
{
	WED_Custom,
	WED_FID,
	WED_Key,
	WED_CurBurst,
	WED_A2,
	WED_A2_Offset,
	WED_INA2,
	WED_INA2_Delay,
	WED_INBurst,
	WED_Flags,
};

enum WFlag
{
	// Use default HUD (WeaponList)
	WFlag_NoHUD = BIT(0),
	// Auto Reload After Shoot
	WFlag_AutoReload = BIT(1),
	// Do not place decals on shoot
	WFlag_NoDecal = BIT(2),
	// Do not show smoke effect on shoot
	WFlag_NoSmoke = BIT(3),
	// Do not emit original reload sound of shotgun
	WFlag_ShotGunCustomReloadSound = BIT(4),
	// Some of functions will be ignored when shooting
	WFlag_CustomPrimaryAttack = BIT(5),
	// If weapon is Sniper but auto use this for fixing zoom
	WFlag_AutoSniper = BIT(6),
	// Custom idle animation, use natives to set animation index
	WFlag_CustomIdleAnim = BIT(7),
	// Has only ammo as clip (Example Weapon: 'Dragon Cannon')
	WFlag_SoloClip = BIT(8),
	// Prevent weapon from reloading
	WFlag_DisableReload = BIT(9),
	// Keep FOV on reload, do not reset
	ReloadKeepFOV = BIT(10),

	WFlag_Zoom_NoSound = BIT(10),
	WFlag_ZoomCustom_NoSound = BIT(10),

	// Switch Attack2 Flag: Show progress bar when switching
	WFlag_SwitchMode_BarTime = BIT(10),
	// Switch Attack2 Flag: Do not show show text while switching
	WFlag_SwitchMode_NoText = BIT(11),

	AutoPistol_NoSceenShake = BIT(10),

	// KnifeAttack Flag: Shake screen when perfromed.
	WFlag_KnifeAttack_ScreenShake = BIT(10),
	// KnfieAttack Flag: Penetrate (Damage through wall)
	WFlag_KnifeAttack_Penetration = BIT(11),
	// KnifeAttack Flag: Accurately perform damage
	WFlag_KnifeAttack_Accurate = BIT(12),
	// KnifeAttack Flag: Knockback unit when damaged
	WFlag_KnifeAttack_Knockback = BIT(13),

	KnifeAttack_NoSound = BIT(14),
};

enum RDFlag
{
	// Radius Damage Flag: Penetrate through walls
	RDFlag_Penetration = BIT(0),
	// Radius Damage Flag: Ignore caster (Attacker)
	RDFlag_IgnoreSelf = BIT(1),
	// Radius Damage Flag: Knockback units
	RDFlag_Knockback = BIT(2),
	// Radius Damage Flag: Knockback any player
	RDFlag_KnockAny = BIT(3),
};

enum ACT
{
	ACT_INVALID = -1,
	ACT_RESET = 0,
	ACT_IDLE,
	ACT_GUARD,
	ACT_WALK,
	ACT_RUN,
	ACT_FLY,
	ACT_SWIM,
	ACT_HOP,
	ACT_LEAP,
	ACT_FALL,
	ACT_LAND,
	ACT_STRAFE_LEFT,
	ACT_STRAFE_RIGHT,
	ACT_ROLL_LEFT,
	ACT_ROLL_RIGHT,
	ACT_TURN_LEFT,
	ACT_TURN_RIGHT,
	ACT_CROUCH,
	ACT_CROUCHIDLE,
	ACT_STAND,
	ACT_USE,
	ACT_SIGNAL1,
	ACT_SIGNAL2,
	ACT_SIGNAL3,
	ACT_TWITCH,
	ACT_COWER,
	ACT_SMALL_FLINCH,
	ACT_BIG_FLINCH,
	ACT_RANGE_ATTACK1,
	ACT_RANGE_ATTACK2,
	ACT_MELEE_ATTACK1,
	ACT_MELEE_ATTACK2,
	ACT_RELOAD,
	ACT_ARM,
	ACT_DISARM,
	ACT_EAT,
	ACT_DIESIMPLE,
	ACT_DIEBACKWARD,
	ACT_DIEFORWARD,
	ACT_DIEVIOLENT,
	ACT_BARNACLE_HIT,
	ACT_BARNACLE_PULL,
	ACT_BARNACLE_CHOMP,
	ACT_BARNACLE_CHEW,
	ACT_SLEEP,
	ACT_INSPECT_FLOOR,
	ACT_INSPECT_WALL,
	ACT_IDLE_ANGRY,
	ACT_WALK_HURT,
	ACT_RUN_HURT,
	ACT_HOVER,
	ACT_GLIDE,
	ACT_FLY_LEFT,
	ACT_FLY_RIGHT,
	ACT_DETECT_SCENT,
	ACT_SNIFF,
	ACT_BITE,
	ACT_THREAT_DISPLAY,
	ACT_FEAR_DISPLAY,
	ACT_EXCITED,
	ACT_SPECIAL_ATTACK1,
	ACT_SPECIAL_ATTACK2,
	ACT_COMBAT_IDLE,
	ACT_WALK_SCARED,
	ACT_RUN_SCARED,
	ACT_VICTORY_DANCE,
	ACT_DIE_HEADSHOT,
	ACT_DIE_CHESTSHOT,
	ACT_DIE_GUTSHOT,
	ACT_DIE_BACKSHOT,
	ACT_FLINCH_HEAD,
	ACT_FLINCH_CHEST,
	ACT_FLINCH_STOMACH,
	ACT_FLINCH_LEFTARM,
	ACT_FLINCH_RIGHTARM,
	ACT_FLINCH_LEFTLEG,
	ACT_FLINCH_RIGHTLEG,
	ACT_FLINCH,
	ACT_LARGE_FLINCH,
	ACT_HOLDBOMB,
	ACT_IDLE_FIDGET,
	ACT_IDLE_SCARED,
	ACT_IDLE_SCARED_FIDGET,
	ACT_FOLLOW_IDLE,
	ACT_FOLLOW_IDLE_FIDGET,
	ACT_FOLLOW_IDLE_SCARED,
	ACT_FOLLOW_IDLE_SCARED_FIDGET,
	ACT_CROUCH_IDLE,
	ACT_CROUCH_IDLE_FIDGET,
	ACT_CROUCH_IDLE_SCARED,
	ACT_CROUCH_IDLE_SCARED_FIDGET,
	ACT_CROUCH_WALK,
	ACT_CROUCH_WALK_SCARED,
	ACT_CROUCH_DIE,
	ACT_WALK_BACK,
	ACT_IDLE_SNEAKY,
	ACT_IDLE_SNEAKY_FIDGET,
	ACT_WALK_SNEAKY,
	ACT_WAVE,
	ACT_YES,
	ACT_NO,
};
