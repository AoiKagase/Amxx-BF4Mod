"""Run production lifecycle functions in the AMX VM with explicit engine boundaries."""
from pathlib import Path
import subprocess
import sys
import unittest

from test_claymore_runtime import function_body

ROOT = Path(__file__).resolve().parents[1]


class ObjectiveRuntimeTests(unittest.TestCase):
    def test_delayed_defibrillator_does_not_respawn_an_already_deployed_player(self):
        text = (ROOT / "cstrike/addons/amxmodx/scripting/bf4_weapon_defibrillator.sma").read_text(encoding="utf-8-sig")
        fixture = r'''
#pragma semicolon 1
native check(value, code);
#define TASKID_RESPAWN 100
#define IS_RESPAWNING 0
#define Ham_CS_RoundRespawn 1
new g_player_data[33][1], bool:g_alive, g_spawns;
stock bool:BF4TaskAccept(id, const session[], taskid) { return id == 1 && session[0] == 5 && taskid == 101; }
stock bool:is_user_alive(id) { return id == 1 && g_alive; }
stock ExecuteHamB(ham, id) { g_spawns++; g_alive = true; return ham + id; }
'''
        fixture += function_body(text, "public TaskReSpawn(") + r'''
public main()
{
    new session[1] = {5};
    g_alive = true; // Objective redeployment completed before the delayed revival callback.
    TaskReSpawn(session, 101);
    check(g_spawns == 0 && g_player_data[1][IS_RESPAWNING] == 0, 1);
    g_alive = false;
    TaskReSpawn(session, 101);
    check(g_spawns == 1 && g_alive, 2);
    TaskReSpawn(session, 101);
    check(g_spawns == 1, 3);
    return 3;
}
'''
        target = ROOT / "build/pawn-tests/objective_defibrillator.sma"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(fixture, encoding="utf-8")
        result = subprocess.run([sys.executable, str(ROOT / "tools/run_pawn_test.py"), str(target)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_tick_pauses_time_but_finishes_exhausted_disconnected_team(self):
        text = (ROOT / "cstrike/addons/amxmodx/scripting/bf4_game_objectives.sma").read_text(encoding="utf-8-sig")
        fixture = r'''
#pragma semicolon 1
#include <float>
native check(value, code);
#include <bf4/objective_rules>
#define MATCH_STOPPED 0
#define MATCH_WAITING 1
#define MATCH_RUNNING 2
#define MATCH_PAUSED 3
#define MATCH_ENDED 4
#define m_iTeam 1
#define m_bFreezePeriod 1
#define m_bGameStarted 2
new g_matchState = MATCH_WAITING, g_maxPlayers = 2, g_minPlayers = 2;
new Float:g_now = 0.25, Float:g_lastTick, Float:g_activeTime, Float:g_bleedElapsed;
new Float:g_bleedInterval = 2.0, Float:g_timeLimit, g_bleedAmount = 1;
new g_pointCount = 3, bool:g_pointPresent[OBJ_MAX_POINTS], g_points[OBJ_MAX_POINTS][ObjectivePoint];
new g_deathTeam[33], Float:g_respawnAt[33], g_tickets[3];
new bool:g_connected[3] = {false, true, true}, g_updates, g_finishes;
stock Float:get_gametime() { return g_now; }
stock bool:is_user_connected(id) { return g_connected[id]; }
stock bool:is_user_hltv(id) { return id == 0; }
stock bool:is_user_alive(id) { return g_connected[id]; }
stock get_member(id, member) { return id + member - member; }
stock get_member_game(member) { return member == m_bGameStarted; }
stock ObjectiveUpdatePoints(Float:delta) { if (delta > 0.0) g_updates++; }
stock ObjectiveShowHud(Float:now) { return now > 0.0; }
stock ObjectiveFinish(winner) { g_finishes++; g_matchState = MATCH_ENDED; return winner; }
stock ObjectiveTryRespawn(id) { return id; }
stock ObjectiveSettleDebt(id, bool:redeploying) { return id + _:redeploying; }
'''
        fixture += function_body(text, "public ObjectiveTick()") + r'''
public main()
{
    g_tickets[1] = g_tickets[2] = 10;
    ObjectiveTick();
    check(g_matchState == MATCH_RUNNING && g_activeTime == 0.25 && g_updates == 1, 1);
    g_connected[2] = false;
    g_now = 0.5;
    ObjectiveTick();
    check(g_matchState == MATCH_PAUSED && g_activeTime == 0.25 && g_updates == 1, 2);
    g_now = 3.0;
    ObjectiveTick();
    check(g_activeTime == 0.25, 3);
    g_connected[2] = true;
    g_now = 3.25;
    ObjectiveTick();
    check(g_matchState == MATCH_RUNNING && g_activeTime == 0.5 && g_updates == 2, 4);
    g_connected[2] = false;
    g_tickets[2] = 0; // Disconnect can settle the team's final death debt.
    g_now = 3.5;
    ObjectiveTick();
    check(g_matchState == MATCH_ENDED && g_finishes == 1, 5);
    ObjectiveTick();
    check(g_finishes == 1, 6);
    return 6;
}
'''
        target = ROOT / "build/pawn-tests/objective_tick.sma"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(fixture, encoding="utf-8")
        result = subprocess.run([sys.executable, str(ROOT / "tools/run_pawn_test.py"), str(target)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_rank_rewards_use_independent_events_and_reject_invalid_capture(self):
        source = ROOT / "cstrike/addons/amxmodx/scripting/bf4_ranksystem.sma"
        text = source.read_text(encoding="utf-8-sig")
        signatures = ("public BF4ObjectiveCaptured(id, point, team)", "public BF4ObjectiveMatchEnded(mode, winner)")
        for signature in signatures:
            self.assertTrue(signature in text, "Rank consumer has not migrated to objective events")
        functions = "\n".join(function_body(text, signature) for signature in signatures)
        fixture = r'''
#pragma semicolon 1
native check(value, code);
#define PLUGIN_CONTINUE 0
#define m_iTeam 1
#define BF4_RNK_CTF_CAP 17
new g_ready_players = 2, g_population = 4, g_captures, g_wins, g_awardedTeam;
stock get_playersnum() { return g_population; }
stock bool:is_user_alive(id) { return id == 1; }
stock get_member(id, member) { return id + member - member; }
stock ProgressionRecordAward(id, award, const caption[]) { g_captures++; return id + award + caption[0]; }
stock ProgressionObjectiveTeamWin(team) { g_wins++; g_awardedTeam = team; }
'''
        fixture += functions + r'''
public main()
{
    BF4ObjectiveCaptured(0, 0, 1);
    BF4ObjectiveCaptured(1, -1, 1);
    BF4ObjectiveCaptured(1, 7, 1);
    BF4ObjectiveCaptured(1, 0, 2);
    check(g_captures == 0, 1);
    BF4ObjectiveCaptured(1, 0, 1);
    check(g_captures == 1, 2);
    BF4ObjectiveMatchEnded(1, 0);
    BF4ObjectiveMatchEnded(0, 1);
    check(g_wins == 0, 3);
    BF4ObjectiveMatchEnded(2, 2);
    check(g_wins == 1 && g_awardedTeam == 2, 4);
    g_population = 1;
    BF4ObjectiveCaptured(1, 0, 1);
    BF4ObjectiveMatchEnded(1, 1);
    check(g_captures == 1 && g_wins == 1, 5);
    return 5;
}
'''
        target = ROOT / "build/pawn-tests/objective_rank_events.sma"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(fixture, encoding="utf-8")
        result = subprocess.run([sys.executable, str(ROOT / "tools/run_pawn_test.py"), str(target)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_death_revive_redeploy_disconnect_and_match_notifications(self):
        source = ROOT / "cstrike/addons/amxmodx/scripting/bf4_game_objectives.sma"
        self.assertTrue(source.is_file(), "Independent objective provider is not implemented")
        text = source.read_text(encoding="utf-8-sig")
        functions = "\n".join(function_body(text, signature) for signature in (
            "stock ObjectiveClearPlayer(id)", "stock ObjectiveSpendDebt(id)",
            "stock ObjectiveSettleDebt(id, bool:redeploying)",
            "public ObjectivePlayerKilledPost(id)", "public client_disconnected(id)",
            "stock bool:ObjectivePublishMatch(winner)",
            "public CommandStart(id, level, cid)", "public ObjectiveBombPrimaryAttack()",
        ))
        fixture = r'''
#pragma semicolon 1
#include <float>
native check(value, code);
#include <bf4/objective_rules>
#define MATCH_STOPPED 0
#define MATCH_WAITING 1
#define MATCH_RUNNING 2
#define MATCH_PAUSED 3
#define MATCH_ENDED 4
#define m_iTeam 1
#define PLUGIN_HANDLED 1
#define HAM_IGNORED 0
#define HAM_SUPERCEDE 4
new g_matchState = MATCH_RUNNING, g_mode = OBJ_MODE_CONQUEST;
new bool:g_layoutReady, bool:g_manuallyStopped = true, bool:g_hasControl;
new g_resets, g_restarts;
new g_deathTeam[33], Float:g_respawnAt[33], bool:g_isRedeploying[33];
new g_spawnSelection[33], g_deployMenu[33], g_tickets[3];
new Float:g_activeTime = 10.0, Float:g_respawnDelay = 5.0;
new g_maxPlayers = 32, g_matchForward, g_matchNotices, g_lastWinner;
new bool:g_alive[33], g_team[33], g_destroyed;
stock bool:is_user_alive(id) { return g_alive[id]; }
stock get_member(id, member) { return g_team[id] + member - member; }
stock menu_destroy(menu) { g_destroyed++; return menu; }
stock ExecuteForward(handle, &result, mode, winner)
{ g_matchNotices++; g_lastWinner = winner; result = handle + mode; }
stock bool:cmd_access(id, level, cid, args) { return id + level + cid + args > 0; }
stock console_print(id, const text[]) { return id + text[0]; }
stock ObjectiveResetMatch() { g_resets++; }
stock rg_restart_round() { g_restarts++; }
'''
        fixture += functions + r'''
public main()
{
    g_deployMenu[1] = -1;
    g_team[1] = OBJ_TEAM_T;
    g_tickets[1] = 10;
    ObjectivePlayerKilledPost(1);
    check(g_deathTeam[1] == 1 && g_tickets[1] == 10 && g_respawnAt[1] == 15.0, 1);
    g_alive[1] = true;
    ObjectiveSettleDebt(1, false);
    check(g_deathTeam[1] == 0 && g_tickets[1] == 10, 2);
    g_alive[1] = false;
    ObjectivePlayerKilledPost(1);
    g_team[1] = OBJ_TEAM_CT; // A reserved team change must not move the death debt.
    g_alive[1] = true;
    ObjectiveSettleDebt(1, true);
    check(g_tickets[1] == 9 && g_deathTeam[1] == 0, 3);
    ObjectiveSettleDebt(1, true);
    check(g_tickets[1] == 9, 4);
    g_team[1] = OBJ_TEAM_T;
    g_alive[1] = false;
    ObjectivePlayerKilledPost(1);
    g_matchState = MATCH_PAUSED;
    g_spawnSelection[1] = 3;
    client_disconnected(1);
    check(g_tickets[1] == 8 && g_deathTeam[1] == 0 && g_spawnSelection[1] == 0, 5);
    client_disconnected(1);
    check(g_tickets[1] == 8, 6);
    g_deployMenu[1] = 55;
    ObjectiveClearPlayer(1);
    check(g_deployMenu[1] == -1 && g_destroyed == 1 && !g_isRedeploying[1], 7);
    g_matchState = MATCH_STOPPED;
    ObjectivePlayerKilledPost(1);
    check(!g_deathTeam[1], 8);
    g_matchState = MATCH_RUNNING;
    check(ObjectivePublishMatch(OBJ_TEAM_CT) && g_matchNotices == 1 && g_lastWinner == 2, 9);
    check(!ObjectivePublishMatch(OBJ_TEAM_CT) && g_matchNotices == 1, 10);
    g_matchState = MATCH_STOPPED;
    check(!ObjectivePublishMatch(OBJ_TEAM_T) && g_matchNotices == 1, 11);
    CommandStart(0, 0, 0);
    check(g_resets == 0 && g_restarts == 0, 12);
    g_layoutReady = true;
    CommandStart(0, 0, 0);
    check(g_resets == 1 && g_restarts == 1 && !g_manuallyStopped, 13);
    check(ObjectiveBombPrimaryAttack() == HAM_IGNORED, 14);
    g_hasControl = true;
    check(ObjectiveBombPrimaryAttack() == HAM_SUPERCEDE, 15);
    return 15;
}
'''
        target = ROOT / "build/pawn-tests/objective_lifecycle.sma"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(fixture, encoding="utf-8")
        result = subprocess.run([sys.executable, str(ROOT / "tools/run_pawn_test.py"), str(target)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
