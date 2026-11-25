#!/usr/bin/env python3
"""Validate offline OciXCrom 3.10/BF4 backups; optionally emit a new-store TSV.

Never opens a database connection or writes legacy sources. See docs/MIGRATION.md.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import sys

MAX_CELL = 2147483647
COUNTERS = 38
PREFIX = {'steamid': 'steam:', 'nickname': 'nick:', 'ip': 'ip:'}


class InvalidData(ValueError):
    """Input cannot be safely migrated."""


def integer(value, label):
    if isinstance(value, bool) or not re.fullmatch(r'[0-9]+', str(value)):
        raise InvalidData(f'{label}: expected a nonnegative integer')
    number = int(value)
    if number > MAX_CELL:
        raise InvalidData(f'{label}: exceeds Pawn signed cell range')
    return number


def player_key(value, mode):
    if not isinstance(value, str) or not value or any(ord(c) < 32 or ord(c) == 127 for c in value):
        raise InvalidData('player key: empty, control characters or non-string')
    key = PREFIX[mode] + value
    if len(key.encode('utf-8')) > 63:
        raise InvalidData('player key exceeds 63 UTF-8 bytes including prefix')
    if mode == 'steamid' and not re.fullmatch(r'STEAM_[0-9]+:[01]:[0-9]+', value):
        raise InvalidData(f'unsupported SteamID: {value}')
    return key


def read_json(path):
    def unique_object(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise InvalidData(f'duplicate JSON field: {key}')
            result[key] = value
        return result
    return json.loads(path.read_text(encoding='utf-8-sig'), object_pairs_hook=unique_object)


def read_vault(path, encoding):
    """AMXX NVault v0x0200, little-endian x86 snapshot; journals refused."""
    for journal in (path.with_suffix('.journal'), Path(str(path) + '.journal')):
        if journal.exists() and journal.stat().st_size:
            raise InvalidData(f'unapplied nVault journal: {journal}; stop server cleanly and recopy')
    data = path.read_bytes()
    offset = 0

    def take(size):
        nonlocal offset
        if size > len(data) - offset:
            raise InvalidData(f'{path}: truncated nVault at byte {offset}')
        result = data[offset:offset + size]
        offset += size
        return result

    magic, version, entries = struct.unpack('<IHi', take(10))
    if magic != 0x6E564C54 or version != 0x0200 or entries < 0:
        raise InvalidData(f'{path}: unsupported nVault header/version')
    result = {}
    for _ in range(entries):
        _, key_size, value_size = struct.unpack('<iBH', take(7))
        key = take(key_size).decode(encoding, errors='strict')
        value = take(value_size).decode(encoding, errors='strict')
        if not key or '\0' in key or '\0' in value or key in result:
            raise InvalidData('nVault duplicate/empty key or embedded NUL')
        result[key] = value
    if offset != len(data):
        raise InvalidData(f'{path}: unexpected trailing bytes')
    return result


def xp_rows(path, fmt, encoding):
    if fmt == 'oci310-nvault':
        return [{'Player': key, 'XP': value} for key, value in read_vault(path, encoding).items()]
    rows = read_json(path)
    if not isinstance(rows, list):
        raise InvalidData('XP SQL export must be a JSON array')
    for row in rows:
        if not isinstance(row, dict) or set(row) != {'Player', 'XP'}:
            raise InvalidData('XP SQL export requires exactly Player and XP columns')
    return rows


def counter_rows(path, fmt, encoding):
    if fmt == 'bf4-nvault':
        rows = []
        for key, value in read_vault(path, encoding).items():
            match = re.fullmatch(r'(.+)_([0-9]+)_([0-9]+)', key)
            if not match:
                raise InvalidData(f'unsupported BF4 nVault key: {key}')
            authid, kind, rank_id = match.groups()
            rows.append({'authid': authid, 'type': kind, 'rank_id': rank_id, 'value': value})
        return rows
    rows = read_json(path)
    if not isinstance(rows, list):
        raise InvalidData('BF4 SQL export must be a JSON array')
    for row in rows:
        if not isinstance(row, dict) or set(row) != {'authid', 'type', 'rank_id', 'value'}:
            raise InvalidData('BF4 SQL export requires exactly authid,type,rank_id,value')
    return rows


def migrate(args):
    inputs = [args.xp, args.counters]
    mapping = read_json(args.identity_map) if args.identity_map else {}
    if not isinstance(mapping, dict) or any(not isinstance(v, str) for v in mapping.values()):
        raise InvalidData('identity map requires authid -> original XP save-key strings')
    if len(set(mapping.values())) != len(mapping):
        raise InvalidData('identity map collision: multiple authids share one XP key')
    if args.identity_map:
        inputs.append(args.identity_map)
    players, folded = {}, set()
    for row in xp_rows(args.xp, args.xp_format, args.encoding):
        key = player_key(row['Player'], args.save_key)
        if key.casefold() in folded:
            raise InvalidData(f'duplicate/colliding XP player: {key}')
        folded.add(key.casefold())
        players[key] = (integer(row['XP'], 'XP'), [0] * COUNTERS)
    seen, with_counters = set(), set()
    for row in counter_rows(args.counters, args.counter_format, args.encoding):
        authid = row['authid']
        if not isinstance(authid, str):
            raise InvalidData('BF4 authid must be a string')
        if args.save_key != 'steamid' and authid not in mapping:
            raise InvalidData(f'missing explicit identity mapping for {authid}')
        original_key = mapping.get(authid, authid)
        key = player_key(original_key, args.save_key)
        if key not in players:
            raise InvalidData(f'counter player has no XP row: {key}')
        kind = integer(row['type'], 'type')
        rank_id = integer(row['rank_id'], 'rank_id')
        if kind > 1 or rank_id > 18:
            raise InvalidData('unknown BF4 type or rank_id (expected 0..1 / 0..18)')
        counter_id = (key, kind, rank_id)
        if counter_id in seen:
            raise InvalidData(f'duplicate counter: {counter_id}')
        seen.add(counter_id)
        with_counters.add(key)
        players[key][1][kind * 19 + rank_id] = integer(row['value'], 'counter')
    payload = ''.join(f'{key}\t{xp}\t' + ','.join(map(str, counters)) + '\n'
                      for key, (xp, counters) in sorted(players.items())).encode('utf-8')
    if args.output:
        output = args.output.resolve()
        if output in {p.resolve() for p in inputs}:
            raise InvalidData('output must not replace any input')
        if output.exists():
            if output.read_bytes() != payload:
                raise InvalidData('output already exists with different contents')
        else:
            with output.open('xb') as stream:
                stream.write(payload)
    return {'schema_version': 2, 'players': len(players), 'counter_rows': len(seen),
            'players_without_counters': len(players) - len(with_counters),
            'xp_total': sum(xp for xp, _ in players.values()),
            'counter_total': sum(sum(c) for _, c in players.values()),
            'output_sha256': hashlib.sha256(payload).hexdigest(),
            'sources': [{'file': str(p), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()} for p in inputs],
            'output': str(args.output) if args.output else None, 'dry_run': not bool(args.output)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--xp', type=Path, required=True)
    parser.add_argument('--counters', type=Path, required=True)
    parser.add_argument('--xp-format', choices=['oci310-json', 'oci310-nvault'], default='oci310-json')
    parser.add_argument('--counter-format', choices=['bf4-json', 'bf4-nvault'], default='bf4-json')
    parser.add_argument('--save-key', choices=PREFIX, required=True)
    parser.add_argument('--identity-map', type=Path)
    parser.add_argument('--encoding', default='utf-8', help='legacy nVault strings only; no replacement decoding')
    parser.add_argument('--output', type=Path, help='new canonical TSV only; omit for read-only validation')
    args = parser.parse_args()
    try:
        print(json.dumps(migrate(args), ensure_ascii=False, sort_keys=True, indent=2))
    except (InvalidData, OSError, ValueError, LookupError) as error:
        print(f'Migration refused: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
