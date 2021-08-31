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

enum _:E_BF4_RANK
{
	BF4_RNK_MARKSMAN 	= 0,
	BF4_RNK_HEADSHOT,
	BF4_RNK_PISTOL	,
	BF4_RNK_ASSAULT ,
	// BF4_RNK_CARBIN	, // M4A1 only...
	BF4_RNK_SNIPER	,
	BF4_RNK_LMG		,
	BF4_RNK_DMR		,
	// BF4_RNK_PDW 	, // P90 only...
	BF4_RNK_SMG		, // PDW Alternative
	BF4_RNK_SHOTGUN	,
	BF4_RNK_MELEE	,
	BF4_RNK_ASSIST	,
	BF4_RNK_AVENGER	,
	BF4_RNK_SAVIOR	,
	BF4_RNK_MVP		,
	BF4_RNK_MEDIKIT	,
	BF4_RNK_AMMOBOX	,
	BF4_RNK_REVIVE	, 
	BF4_RNK_CTF_CAP	,
	BF4_RNK_CTF_WIN	,
	BF4_RNK_MAX
};

enum _:E_BF4_CLASS
{
	BF4_CLASS_ASSAULT,
	BF4_CLASS_RECON,
	BF4_CLASS_SUPPORT,
	BF4_CLASS_ENGINEER,
}

native BF4BuyRivivekit(id);
native BF4CtfCapture(id);
native BF4CtfWin(team);
native BF4ReviveBonus(id);


native BF4TriggerGetRibbon(const client, const ribbon, const comment[]);
native GetBF4PlayerClass(const client);