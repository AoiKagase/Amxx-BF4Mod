#if defined _bf4_effect_natives_included
    #endinput
#endif
#define _bf4_effect_natives_included
#if AMXX_VERSION_NUM >= 175
	#pragma reqlib bf4_effect_natives
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib bf4_effect_natives
	#endif
#else
	#pragma library bf4_effect_natives
#endif
#include <bf4const>

native BF4EffectExplosion		(const iEnt, const Float:damage, const Float:radius, const iBlastColor[4], const iBlastWidth);
native BF4EffectExplosionDamage	(const csx_wpnid, const iEnt, const iAttacker, const Float:dmgMax, const Float:radius);
native BF4EffectScreenShake		(const iEnt, const Float:flAmplitude, const Float:flDuration, const Float:flFrequency, const Float:flRadius);