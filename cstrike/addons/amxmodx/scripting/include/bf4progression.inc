#if defined _bf4progression_included
	#endinput
#endif
#define _bf4progression_included

// V2 returns false/-1 while the identity is loading or persistence is unavailable.
// RankSystem.ini is read directly; no crxranks provider is required. Existing
// XP rewards and independent BF4 bonus values are both retained once/event.
// Rank/XP API is read-only until a successful load, including for a missing key.
// Storage: SQL bf4_progression_v2 (VARBINARY64 player_key) OR BF4Ranks_v2 vault.
// SQL failure never changes stores; pending snapshots are locally journaled.
// Canonical keys use steam:/nick:/ip:/bot: and preserve exact UTF-8 bytes/spaces.
// Migration: place validated player_key<TAB>xp<TAB>38-count-CSV in data/;
// with no players connected, run bf4_import_progression filename.tsv from the
// SERVER console. Full validation/conflict preflight precedes any inserts.
// Identical rows are idempotent; conflicts are refused, old stores untouched.
// A storage failure during inserts is resumable by rerunning the same file.
native bool:BF4ProgressionReadyV2(id);
native BF4GetXPV2(id);
native bool:BF4GiveXPV2(id, amount);
native BF4GetLevelV2(id);
native BF4GetRankV2(id, name[], length);
native BF4GetPlayerKeyV2(id, key[], length);
// Stable keys: marksman, headshot, pistol, assault, sniper, lmg, dmr, smg,
// shotgun, melee, assist, avenger, savior, mvp, medikit, ammobox, revive,
// ctf_capture, ctf_win. Numeric legacy ordinals are not a V2 interface.
native bool:BF4TriggerGetRibbonV2(id, const award_key[], const caption[] = "");
