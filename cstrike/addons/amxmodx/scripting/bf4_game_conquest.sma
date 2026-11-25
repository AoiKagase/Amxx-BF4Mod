#pragma tabsize 	4
#pragma semicolon 	1

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <reapi>

enum _:E_SPRITES
{
	RING,
	POINT,
	GUAGE,
}

new const ENT_SPRITES[E_SPRITES][] = 
{
	"sprites/bf4_ranks/conquest/ring.spr",
	"sprites/bf4_ranks/conquest/point.spr",
	"sprites/bf4_ranks/conquest/guage.spr",
};

// Plugin Info.
new const PLUGIN_NAME			[]	= "[BF4] GameRules Conquest";
new const PLUGIN_VERSION		[]	= "0.01";
new const PLUGIN_AUTHOR			[]	= "Aoi.Kagase";
new const PLUGIN_URL			[]	= "github.com/AoiKagase";
new const PLUGIN_DESC			[]	= "BattleField 4 Mod";

new gSpriteIndex[E_SPRITES];

new g_MsgSync;
// =====================================================================
// Plugin Initialize.
// =====================================================================
public plugin_init()
{
	register_plugin	(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR, PLUGIN_URL, PLUGIN_DESC);

	plugin_forward();
	create_point_flag();

	RegisterHam(Ham_Spawn, "player", "TEST", true);
	g_MsgSync = CreateHudSyncObj();
       
}
public TEST(id)
{
	set_hudmessage(255, 255, 102, -1.0, 0.16 , 0 , 2.0 ,3.0,2.0,2.0 );
    ShowSyncHudMsg(id,g_MsgSync, "Test color");
}
// =====================================================================
// Native Functions.
// =====================================================================
public plugin_natives()
{
}

// =====================================================================
// Forward Functions.
// =====================================================================
public plugin_forward()
{
}

// =====================================================================
// Plugin Precache.
// =====================================================================
public plugin_precache() 
{
	for (new i = 0; i < E_SPRITES; i++)
		gSpriteIndex[i] = precache_model(ENT_SPRITES[i]);

}

create_point_flag()
{
	new flag_ring  = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"));
	new flag_point = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"));
	new flag_guage = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"));
			
	if(pev_valid(flag_ring)) 
	{
		engfunc(EngFunc_SetOrigin, flag_ring,  {0.0,100.0,100.0});
		engfunc(EngFunc_SetOrigin, flag_point, {0.0,100.0,100.0});
		engfunc(EngFunc_SetOrigin, flag_guage, {0.0,100.0,100.0});
		set_pev(flag_ring,  pev_model, ENT_SPRITES[RING]);
		set_pev(flag_point, pev_model, ENT_SPRITES[POINT]);
		set_pev(flag_guage, pev_model, ENT_SPRITES[GUAGE]);

		set_pev(flag_ring, pev_rendermode, kRenderTransTexture);
		set_pev(flag_ring, pev_renderamt, 100.0);
		set_pev(flag_ring, pev_rendercolor, {255.0,255.0,255.0});

		set_pev(flag_point, pev_rendermode, kRenderTransTexture);
		set_pev(flag_point, pev_renderamt, 100.0);
		set_pev(flag_point, pev_rendercolor, {255.0,255.0,255.0});

		set_pev(flag_guage, pev_rendermode, kRenderTransTexture);
		set_pev(flag_guage, pev_renderamt, 100.0);
		set_pev(flag_guage, pev_rendercolor, {255.0,255.0,255.0});

		set_pev(flag_ring,  pev_framerate, 1.0);
		set_pev(flag_point, pev_framerate, 1.0);
		set_pev(flag_guage, pev_framerate, 1.0);

		dllfunc(DLLFunc_Spawn, flag_ring);
		dllfunc(DLLFunc_Spawn, flag_point);
		dllfunc(DLLFunc_Spawn, flag_guage);
	}
}