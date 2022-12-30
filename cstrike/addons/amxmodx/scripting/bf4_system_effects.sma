#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <csx>
#include <xs>
#include <bf4classes>
#include <bf4effects>

// Plugin Info.
new const PLUGIN_NAME			[]	= "[BF4] Effect System";
new const PLUGIN_VERSION		[]	= "0.01";
new const PLUGIN_AUTHOR			[]	= "Aoi.Kagase";
new const PLUGIN_URL			[]	= "github.com/AoiKagase";
new const PLUGIN_DESC			[]	= "BattleField 4 Mod: Effect System.";

#define MAX_EXPLOSION_DECALS 			3
#define MAX_BLOOD_DECALS 				10
new gDecalIndexExplosion	[MAX_EXPLOSION_DECALS];
new gDecalIndexBlood		[MAX_BLOOD_DECALS];
new gNumDecalsExplosion;
new gNumDecalsBlood;

enum E_CVARS
{
	CVAR_FRIENDLY_FIRE,
	CVAR_VIOLENCE_HBLOOD,
}

enum _:E_SPRITES
{
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
	"sprites/fexplo.spr"		,		// 0: EXPLOSION
	"sprites/eexplo.spr"		,		// 1: EXPLOSION
	"sprites/WXplo1.spr"		,		// 2: WATER EXPLOSION
	"sprites/shockwave.spr"		,		// 3: BLAST
	"sprites/steam1.spr"		,		// 4: SMOKE
	"sprites/bubble.spr"		,		// 5: BUBBLE
	"sprites/blood.spr"			,		// 6: BLOOD SPLASH
	"sprites/bloodspray.spr"			// 7: BLOOD SPRAY	
}
new gCvar[E_CVARS];
new gSpriteIndex			[E_SPRITES];
// =====================================================================
// Plugin Initialize.
// =====================================================================
public plugin_init()
{
	register_plugin	(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR, PLUGIN_URL, PLUGIN_DESC);
	bind_pcvar_num		(get_cvar_pointer("mp_friendlyfire"),	gCvar[CVAR_FRIENDLY_FIRE]);							// Friendly fire. 0 or 1
	bind_pcvar_num		(get_cvar_pointer("violence_hblood"),	gCvar[CVAR_VIOLENCE_HBLOOD]);							// Friendly fire. 0 or 1
}

public plugin_precache() 
{
	LoadDecals();

	for (new i = 0; i < E_SPRITES; i++)
		gSpriteIndex[i] = precache_model(ENT_SPRITES[i]);

}

public plugin_natives()
{
	register_library("bf4_effect_natives");
	register_native("BF4EffectExplosion", 		"_bf4_explosion");
	register_native("BF4EffectExplosionDamage", "_bf4_explosion_damage");
	register_native("BF4EffectScreenShake", 	"_bf4_screen_shake");
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

public _bf4_explosion(iPlugins, iParams)
{
	new iBlastColor[4];
	get_array(4, iBlastColor, sizeof(iBlastColor));
	explosion(get_param(1), get_param_f(2), get_param_f(3), iBlastColor, get_param(5));
}

public _bf4_explosion_damage(iPlugins, iParams)
{
	create_explosion_damage(get_param(1), get_param(2), get_param(3), get_param_f(4), get_param_f(5));	
}

public _bf4_screen_shake(iPlugins, iParams)
{
	new iEnt = get_param(1);
	new Float:vOrigin[3];
	pev(iEnt, pev_origin, vOrigin);
	UTIL_ScreenShake(vOrigin, get_param_f(2), get_param_f(3), get_param_f(4), get_param_f(5)); 	
}

// mines_mines_explosion(id, iMinesId, iEnt);
stock explosion(const iEnt, const Float:damage, const Float:radius, const iBlastColor[4], const iBlastWidth, const iFlags = TE_EXPLFLAG_NONE)
{
	static Float:vOrigin[3];

	pev(iEnt, pev_origin, 	vOrigin);
	if(engfunc(EngFunc_PointContents, vOrigin) != CONTENTS_WATER) 
	{
		create_explosion		(vOrigin, damage, radius, iBlastColor, iBlastWidth, iFlags);
		create_smoke			(vOrigin, damage, radius);
	}
	else 
	{
		create_water_explosion	(vOrigin, damage, radius, iFlags);
		create_bubbles			(vOrigin, damage, radius);
	}
	// decals
	create_explosion_decals(vOrigin);
}

stock create_explosion(
	const Float:vOrigin[3], 
	const Float:fDamage, 
	const Float:fRadius, 
	const iBlastColor[4],
	const iBlastWidth,
	const iFlags = TE_EXPLFLAG_NONE
)
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
	write_short	(gSpriteIndex[SPR_EXPLOSION_1]);
	write_byte	(iIntensity);
	write_byte	(24);
	write_byte	(iFlags);
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
	write_short	(gSpriteIndex[SPR_EXPLOSION_2]);
	write_byte	(iIntensity);
	write_byte	(20);
	write_byte	(iFlags);
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
	write_short	(gSpriteIndex[SPR_BLAST]);
	write_byte	(0);
	write_byte	(2);
	write_byte	(iIntensity);
	write_byte	(iBlastWidth);
	write_byte	(0);
	write_byte	(iBlastColor[0]);
	write_byte	(iBlastColor[1]);
	write_byte	(iBlastColor[2]);
	write_byte	(iBlastColor[3]);
	write_byte	(0);
	message_end	();
}

stock create_water_explosion(const Float:vOrigin[3], const Float:fDamage, const Float:fRadius, const iFlags) 
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
	write_short		(gSpriteIndex[SPR_EXPLOSION_WATER]);
	write_byte		(iIntensity);
	write_byte		(16);
	write_byte		(iFlags);
	message_end		();
}

stock create_smoke(const Float:vOrigin[3], const Float:fDamage, const Float:fRadius)
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
	write_short	(gSpriteIndex[SPR_SMOKE]);
	write_byte	(iIntensity);
	write_byte	(4);
	message_end	();
}

stock create_bubbles(const Float:vOrigin[3], const Float:flDamageMax, const Float:flDamageRadius) 
{
	new Float:flMaxSize = floatclamp((flDamageMax + (flDamageRadius * 1.5)) / 13.0, 24.0, 164.0);
	new Float:vMins[3], Float:vMaxs[3];
	new Float:vTemp[3];

	vTemp[0] = vTemp[1] = vTemp[2] = flMaxSize;

	xs_vec_sub(vOrigin, vTemp, vMins);
	xs_vec_add(vOrigin, vTemp, vMaxs);

	UTIL_Bubbles(vMins, vMaxs, 80);
}

stock create_hblood(const Float:vOrigin[3], const iDamageMax)
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
	write_short(gSpriteIndex[SPR_BLOOD_SPRAY]);
	write_short(gSpriteIndex[SPR_BLOOD_SPLASH]);
	write_byte(248);
	write_byte(clamp(iDamageMax / 13, 5, 16));
	message_end();

	return;
}

stock create_explosion_decals(const Float:vOrigin[3]) 
{
	engfunc		(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte	(TE_WORLDDECAL);
	engfunc		(EngFunc_WriteCoord, vOrigin[0]);
	engfunc		(EngFunc_WriteCoord, vOrigin[1]);
	engfunc		(EngFunc_WriteCoord, vOrigin[2]);
	write_byte	(gDecalIndexExplosion[random(gNumDecalsExplosion)]);
	message_end	();
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

stock UTIL_Bubbles(const Float:vMins[3], const Float:vMaxs[3], const iCount)
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
	write_short(gSpriteIndex[SPR_BUBBLE]);
	write_byte(iCount);
	engfunc(EngFunc_WriteCoord, 8.0);
	message_end();
}

//====================================================
// Explosion Damage.
//====================================================
stock create_explosion_damage(const csx_wpnid, const iEnt, const iAttacker, const Float:dmgMax, const Float:radius)
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
			{
				if (!equali(tClassName, "func_breakable"))
					continue;
			} else
			{
				// is alive?
				if (!is_user_alive(rEnt))
					continue;
				
				// friendly fire
				if (!is_valid_takedamage(iAttacker, rEnt))
					continue;
			}
		}


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

			if (floatround(tmpDmg) > 0)
			{
				if (is_user_alive(rEnt))
					custom_weapon_dmg(csx_wpnid, iAttacker, rEnt, floatround(tmpDmg), 0);
				if (iEnt != rEnt)
					// Damage Effect, Damage, Killing Logic.
					ExecuteHamB(Ham_TakeDamage, rEnt, iEnt, iAttacker, tmpDmg, DMG_MORTAR);
			}
		}
	}
	return;
}
//====================================================
// Friendly Fire Method.
//====================================================
stock bool:is_valid_takedamage(iAttacker, iTarget)
{
	if (iAttacker == iTarget)
		return true;

	static friendlyfire;
	if (!friendlyfire)
		friendlyfire = get_cvar_pointer("mp_friendlyfire");

	if (get_pcvar_num(friendlyfire))
		return true;

	if (is_user_connected(iAttacker) && is_user_connected(iTarget))
	{
		if (BF4GetUserTeam(iAttacker) != BF4GetUserTeam(iTarget))
			return true;
	}

	return false;
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

			if((pev(iPlayer, pev_flags) & FL_ONGROUND) == 0)
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

				engfunc(EngFunc_MessageBegin, MSG_ONE, iMsgIDScreenShake, {0,0,0}, iPlayer);
				write_short(iAmplitude);
				write_short(iDuration);
				write_short(iFrequency);
				message_end();
			}
		}
	}
}