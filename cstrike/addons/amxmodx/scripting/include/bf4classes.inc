#if defined _bf4_classes_natives_included
    #endinput
#endif
#define _bf4_classes_natives_included
#include <bf4const>
#if AMXX_VERSION_NUM >= 175
	#pragma reqlib bf4_classes_natives
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib bf4_classes_natives
	#endif
#else
	#pragma library bf4_classes_natives
#endif


native BF4_CLASS:BF4GetUserClass(id, reserve = false);
native BF4_TEAM:BF4GetUserTeam(id, reserve = false);
native bool:BF4FirstJoinTeam(id);
// V2: nonzero only for a connected slot; changes on connect and disconnect.
native BF4ClassesAPIVersion();
native BF4GetSessionV2(id);

forward BF4ForwardTeamChanged(id);
forward BF4ForwardClassChanged(id);
