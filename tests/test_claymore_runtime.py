"""Execute the actual production beam-check function with instrumented engine boundaries."""
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]


def function_body(text, signature):
    start = text.index(signature)
    opening = text.index("{", start)
    depth = 1
    end = opening + 1
    while depth:
        if text[end] == "{":
            depth += 1
        elif text[end] == "}":
            depth -= 1
        end += 1
    return text[start:end]


class ClaymoreRuntimeTests(unittest.TestCase):
    def test_trace_handle_reused_without_changing_scan_count(self):
        source = ROOT / "cstrike/addons/amxmodx/scripting/bf4_weapon_claymore.sma"
        function = function_body(source.read_text(encoding="utf-8-sig"), "\nmines_step_beambreak(iEnt,")
        fixture = r'''
#pragma semicolon 1
#pragma rational Float
native check(value, code);
native Float:floatadd(Float:a, Float:b);
native floatcmp(Float:a, Float:b);
#define WIRE_COUNT 3
enum { CM_OWNER, CM_WIRE_SPOINT, CM_STEP, EXPLOSE_THINK, EngFunc_TraceLine, DONT_IGNORE_MONSTERS,
    TR_flFraction, TR_pHit, TR_vecEndPos, pev_flags, FL_CLIENT=1, FL_FAKECLIENT=2, FL_MONSTER=4,
    pev_enemy, pev_nextthink };
new gAlloc, gFree, gTraces, gScheduled;
new gBeamTrace;
stock create_tr2() { gAlloc++; return 17; }
stock free_tr2(trace) { gFree++; return trace; }
stock CED_GetCell(ent, key, &value) { value=1; return ent + key; }
stock CED_GetArray(ent, key, Float:value[], size) { return ent + key + size + _:value[0]; }
stock CED_SetCell(ent, key, value) { return ent + key + value; }
stock engfunc(func, const Float:origin[], const Float:target[], flags, ent, trace)
{ gTraces++; return func + flags + ent + trace + _:origin[0] + _:target[0]; }
stock get_tr2(trace, field, any:...) { return trace + field - trace - field; }
stock pev_valid(ent) { return 0 * ent; }
stock pev(ent, field) { return ent + field; }
stock is_user_alive(ent) { return ent > 0; }
stock is_valid_takedamage(owner, target) { return owner != target; }
stock get_user_godmode(ent) { return 0 * ent; }
stock set_pev(ent, field, any:value) { gScheduled++; return ent + field + value; }
stock mines_get_health(ent, &Float:value) { value=100.0; return ent; }
stock Float:random_float(Float:low, Float:high) { return 0.015; }
'''
        fixture += "\n" + function + r'''
public main()
{
    new Float:ends[3][3];
    gBeamTrace = create_tr2();
    mines_step_beambreak(40, ends, 10.0);
    mines_step_beambreak(41, ends, 11.0);
    check(gAlloc == 1, 100);
    check(gFree == 0, 101);
    check(gTraces == 6, 102);
    check(gScheduled == 2, 103);
    free_tr2(gBeamTrace);
    check(gFree == 1, 104);
    return 5;
}
'''
        target = ROOT / "build/pawn-tests/claymore_trace.sma"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(fixture, encoding="ascii")
        result = subprocess.run([sys.executable, str(ROOT / "tools/run_pawn_test.py"), str(target)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
