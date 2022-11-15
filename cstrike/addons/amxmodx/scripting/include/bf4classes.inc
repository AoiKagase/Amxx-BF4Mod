#if defined _bf4_classes_natives_included
    #endinput
#endif
#define _bf4_classes_natives_included
#if AMXX_VERSION_NUM >= 175
	#pragma reqlib bf4_classes_natives
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib bf4_classes_natives
	#endif
#else
	#pragma library bf4_classes_natives
#endif


native BF4_CLASS:BF4GetUserClass(id, stack = false);
native BF4_TEAM:BF4GetUserTeam(id, stack = false);
native bool:BF4FirstJoinTeam(id);

forward BF4ForwardTeamChanged(id);
forward BF4ForwardClassChanged(id);