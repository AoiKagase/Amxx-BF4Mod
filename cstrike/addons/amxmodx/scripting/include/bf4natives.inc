#if defined _bf4_ranksystem_natives_included
    #endinput
#endif
#define _bf4_ranksystem_natives_included
#if AMXX_VERSION_NUM >= 175
	#pragma reqlib bf4_ranksystem_natives
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib bf4_ranksystem_natives
	#endif
#else
	#pragma library bf4_ranksystem_natives
#endif
native BF4BuyRivivekit(id);
native BF4CtfCapture(id);
native BF4CtfWin(team);
native BF4ReviveBonus(id);

// CS Frags Forwarder
forward csf_flag_taken(id);
forward csf_round_won(team);
forward csf_match_won(team);

