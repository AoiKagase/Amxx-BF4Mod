"""End-to-end: legacy export -> migration CLI -> actual production Pawn import codec."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MigrationPawnIntegration(unittest.TestCase):
    def test_export_is_read_by_production_import_parser_without_value_changes(self):
        (ROOT / "build").mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=ROOT / "build") as temp:
            directory = Path(temp)
            xp = [{"Player": "STEAM_0:1:7", "XP": 32160000}, {"Player": "STEAM_0:0:9", "XP": 0}]
            counters = [{"authid": "STEAM_0:1:7", "type": kind, "rank_id": award,
                         "value": 1000000 + kind * 19 + award} for kind in range(2) for award in range(19)]
            (directory / "xp.json").write_text(json.dumps(xp), encoding="utf-8")
            (directory / "counters.json").write_text(json.dumps(counters), encoding="utf-8")
            command = [sys.executable, str(ROOT / "tools/migrate_progression.py"),
                       "--xp", str(directory / "xp.json"), "--counters", str(directory / "counters.json"),
                       "--save-key", "steamid", "--output", str(directory / "import.tsv")]
            migration = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(migration.returncode, 0, migration.stdout + migration.stderr)
            rows = (directory / "import.tsv").read_bytes().splitlines()
            self.assertEqual(len(rows), 2)
            declarations, assertions = [], []
            for number, row in enumerate(rows):
                values = [str(byte) for byte in row] + ["0"]
                lines = [",".join(values[i:i + 24]) for i in range(0, len(values), 24)]
                declarations.append(f"new const row{number}[] = {{\n" + ",\n".join(lines) + "\n};")
                key = row.split(b"\t")[0]
                expected_xp = 32160000 if key.endswith(b":7") else 0
                assertions += [f"check(StoreParseImportRow(row{number}, record), {number * 10 + 1});",
                               f"check(record[SR_TOTAL_XP] == {expected_xp}, {number * 10 + 2});"]
                if expected_xp:
                    assertions.append("for (new i; i < STORE_VALUES; i++) check(record[SR_AWARD_COUNTS + i] == 1000000 + i, 30 + i);")
                else:
                    assertions.append("for (new i; i < STORE_VALUES; i++) check(record[SR_AWARD_COUNTS + i] == 0, 80 + i);")
            fixture = "#pragma semicolon 1\nnative check(value, code);\n#include <bf4/progression_snapshot>\n"
            fixture += "\n".join(declarations)
            fixture += "\npublic main() { new record[StoreRecord];\n" + "\n".join(assertions) + "\nreturn 80; }\n"
            path = directory / "migration_pipeline.sma"
            path.write_text(fixture, encoding="ascii")
            tested = subprocess.run([sys.executable, str(ROOT / "tools/run_pawn_test.py"), str(path)], capture_output=True, text=True)
            self.assertEqual(tested.returncode, 0, tested.stdout + tested.stderr)


if __name__ == "__main__":
    unittest.main()
