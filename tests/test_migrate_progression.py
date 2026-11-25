"""Regression fixtures for lossless legacy progression migration."""
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / 'tools' / 'migrate_progression.py'


class MigrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.folder = Path(self.temp.name)

    def run_tool(self, xp=None, counters=None, *extra):
        (self.folder / 'xp.json').write_text(json.dumps(xp if xp is not None else [{'Player': 'STEAM_0:1:7', 'XP': 12345}]), encoding='utf-8')
        (self.folder / 'counts.json').write_text(json.dumps(counters if counters is not None else [{'authid': 'STEAM_0:1:7', 'type': 0, 'rank_id': 18, 'value': 1234567}]), encoding='utf-8')
        return subprocess.run([sys.executable, str(TOOL), '--xp', str(self.folder / 'xp.json'), '--counters', str(self.folder / 'counts.json'), '--save-key', 'steamid', *extra], text=True, capture_output=True)

    def test_readonly_default_reports_counts_and_large_values(self):
        result = self.run_tool()
        self.assertEqual(result.returncode, 0, result.stderr)
        report = json.loads(result.stdout)
        self.assertEqual(report['players'], 1)
        self.assertEqual(report['counter_total'], 1234567)
        self.assertEqual(sorted(p.name for p in self.folder.iterdir()), ['counts.json', 'xp.json'])

    def test_output_is_deterministic_and_refuses_existing_different_file(self):
        out = self.folder / 'out.tsv'
        for _ in range(2):
            result = self.run_tool(None, None, '--output', str(out))
            self.assertEqual(result.returncode, 0, result.stderr)
        expected = 'steam:STEAM_0:1:7\t12345\t' + ','.join(['0'] * 18 + ['1234567'] + ['0'] * 19) + '\n'
        self.assertEqual(out.read_text(), expected)
        out.write_text('preserve')
        self.assertNotEqual(self.run_tool(None, None, '--output', str(out)).returncode, 0)
        self.assertEqual(out.read_text(), 'preserve')

    def test_duplicate_players_and_counter_ids_fail(self):
        xp = [{'Player': 'STEAM_0:1:7', 'XP': 4}] * 2
        self.assertNotEqual(self.run_tool(xp).returncode, 0)
        row = {'authid': 'STEAM_0:1:7', 'type': 0, 'rank_id': 1, 'value': 4}
        self.assertNotEqual(self.run_tool(None, [row, row]).returncode, 0)

    def test_invalid_counter_and_xp_fail(self):
        for field, value in [('rank_id', -1), ('rank_id', 19), ('type', 2), ('value', -1), ('value', '2.5'), ('value', 2147483648)]:
            row = {'authid': 'STEAM_0:1:7', 'type': 0, 'rank_id': 1, 'value': 4}
            row[field] = value
            with self.subTest(field=field, value=value):
                self.assertNotEqual(self.run_tool(None, [row]).returncode, 0)
        self.assertNotEqual(self.run_tool([{'Player': 'STEAM_0:1:7', 'XP': True}]).returncode, 0)

    def test_missing_xp_and_unknown_schema_fail(self):
        self.assertNotEqual(self.run_tool([]).returncode, 0)
        self.assertNotEqual(self.run_tool([{'Player': 'STEAM_0:1:7', 'points': 7}]).returncode, 0)

    def test_nvault_fixture_and_truncation_journal_unknown_version_fail(self):
        # NVault.h and NVault.cpp: LE magic/version/count; stamp/keylen/vallen/key/value.
        vault = self.folder / 'old.vault'
        data = bytes.fromhex('544c566e000201000000000000000d0400') + b'STEAM_0:1:7' # deliberately malformed key length
        vault.write_bytes(data)
        self.assertNotEqual(self.run_tool(None, None, '--xp', str(vault), '--xp-format', 'oci310-nvault').returncode, 0)
        key, value = b'STEAM_0:1:7', b'12345'
        vault.write_bytes(bytes.fromhex('544c566e000201000000') + struct.pack('<iBH', 0, len(key), len(value)) + key + value)
        result = self.run_tool(None, None, '--xp', str(vault), '--xp-format', 'oci310-nvault')
        self.assertEqual(result.returncode, 0, result.stderr)
        vault.with_suffix('.journal').write_bytes(b'pending')
        self.assertNotEqual(self.run_tool(None, None, '--xp', str(vault), '--xp-format', 'oci310-nvault').returncode, 0)
        vault.with_suffix('.journal').unlink()
        vault.write_bytes(bytes.fromhex('544c566e000301000000'))
        self.assertNotEqual(self.run_tool(None, None, '--xp', str(vault), '--xp-format', 'oci310-nvault').returncode, 0)

    def test_nonsteam_keys_require_explicit_mapping_and_preserve_names(self):
        xp = [{'Player': 'Player Name', 'XP': 9}]
        self.assertNotEqual(self.run_tool(xp, None, '--save-key', 'nickname').returncode, 0)
        mapping = self.folder / 'map.json'
        mapping.write_text(json.dumps({'STEAM_0:1:7': 'Player Name'}))
        out = self.folder / 'out.tsv'
        result = self.run_tool(xp, None, '--save-key', 'nickname', '--identity-map', str(mapping), '--output', str(out))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(out.read_text().startswith('nick:Player Name\t9\t'))

    def test_bf4_nvault_preserves_both_counter_banks(self):
        vault = self.folder / 'BF4Ranks.vault'
        fixture = bytes.fromhex('544c566e000202000000')
        for key, value in [(b'STEAM_0:1:7_0_0', b'1234567'), (b'STEAM_0:1:7_1_18', b'9876543')]:
            fixture += struct.pack('<iBH', 1700000000, len(key), len(value)) + key + value
        vault.write_bytes(fixture)
        out = self.folder / 'out.tsv'
        result = self.run_tool(None, None, '--counters', str(vault), '--counter-format', 'bf4-nvault', '--output', str(out))
        self.assertEqual(result.returncode, 0, result.stderr)
        values = out.read_text().split('\t')[2].strip().split(',')
        self.assertEqual((values[0], values[37]), ('1234567', '9876543'))
        self.assertEqual(vault.read_bytes(), fixture)

    def test_empty_counter_rows_are_valid_but_unsafe_keys_and_collisions_fail(self):
        self.assertEqual(self.run_tool(None, []).returncode, 0)
        for key in ['', 'name\tbreak', 'x' * 64]:
            self.assertNotEqual(self.run_tool([{'Player': key, 'XP': 0}], [], '--save-key', 'nickname').returncode, 0)
        self.assertNotEqual(self.run_tool([{'Player': 'Name', 'XP': 1}, {'Player': 'name', 'XP': 1}], [], '--save-key', 'nickname').returncode, 0)

    def test_mapping_collision_refused_even_with_valid_sources(self):
        mapping = self.folder / 'map.json'
        mapping.write_text(json.dumps({'STEAM_0:1:7': 'same', 'STEAM_0:1:8': 'same'}))
        self.assertNotEqual(self.run_tool([{'Player': 'same', 'XP': 2}], [], '--save-key', 'nickname', '--identity-map', str(mapping)).returncode, 0)


if __name__ == '__main__':
    unittest.main()
