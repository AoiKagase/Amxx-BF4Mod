"""Compile a pure Pawn fixture, unpack AMXX, and execute it with explicit native bindings."""
from __future__ import annotations

import argparse
from pathlib import Path
import struct
import subprocess
import sys
import zlib

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--runner", type=Path, default=ROOT / "build/pawn_test_runner.exe")
    parser.add_argument("--compiler", type=Path, default=ROOT.parent / "amxmodx/build/packages/base/addons/amxmodx/scripting/amxxpc.exe")
    parser.add_argument("--amxx-include", type=Path, default=ROOT.parent / "amxmodx/plugins/include")
    args = parser.parse_args()
    if not args.runner.is_file() or not args.compiler.is_file():
        parser.error("build the Pawn runner and supply an AMXX compiler first")
    output = ROOT / "build/pawn-tests" / (args.source.stem + ".amxx")
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists():
        output.unlink()
    compiled = subprocess.run([str(args.compiler.resolve()), str(args.source.resolve()), f"-o{output}", "-C-",
                               f"-i{ROOT / 'cstrike/addons/amxmodx/scripting/include'}", f"-i{args.amxx_include.resolve()}"],
                              cwd=args.compiler.resolve().parent, capture_output=True, timeout=60)
    log = (compiled.stdout + compiled.stderr).decode("utf-8", errors="replace")
    output.with_suffix(".log").write_text(log, encoding="utf-8")
    if compiled.returncode or not output.is_file():
        print(log)
        return 1
    data = output.read_bytes()
    magic, version, count = struct.unpack_from("<IHB", data)
    if magic != 0x414D5858 or version != 0x0300 or count < 1:
        raise ValueError("unsupported AMXX image")
    cellsize, disksize, imagesize, memsize, offset = struct.unpack_from("<BIIII", data, 7)
    if cellsize != 4 or imagesize > 64 * 1024 * 1024 or memsize > 64 * 1024 * 1024:
        raise ValueError("unsupported Pawn cell or image size")
    raw = zlib.decompress(data[offset:offset + disksize])
    if len(raw) != imagesize:
        raise ValueError("AMXX decompression length mismatch")
    amx = output.with_suffix(".amx")
    amx.write_bytes(raw)
    return subprocess.run([str(args.runner.resolve()), str(amx)], timeout=30).returncode


if __name__ == "__main__":
    sys.exit(main())
