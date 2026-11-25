"""Compile every shipped Pawn plugin with explicit, reproducible include roots."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
REAPI_COMMIT = "4516d1efdfd8a686a66c191c441981b720b0a7c5"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiler", type=Path, default=ROOT.parent / "amxmodx/build/packages/base/addons/amxmodx/scripting/amxxpc.exe")
    parser.add_argument("--amxx-include", type=Path, default=ROOT.parent / "amxmodx/plugins/include")
    parser.add_argument("--reapi-include", type=Path, default=ROOT / f"build/dependencies/ReAPI-{REAPI_COMMIT}/reapi/extra/amxmodx/scripting/include")
    parser.add_argument("--source-root", type=Path, default=ROOT / "cstrike/addons/amxmodx/scripting")
    parser.add_argument("--output", type=Path, default=ROOT / "build/plugins")
    parser.add_argument("--only", nargs="*", help="Compile these plugin stems instead of all plugins")
    args = parser.parse_args()
    args.compiler = args.compiler.resolve()
    for name in ("compiler", "amxx_include", "reapi_include", "source_root"):
        path = getattr(args, name)
        if not path.exists():
            parser.error(f"{name}: missing {path}")
    args.output.mkdir(parents=True, exist_ok=True)
    args.output = args.output.resolve()
    sources = sorted(args.source_root.glob("*.sma"))
    if args.only:
        names = set(args.only)
        sources = [p for p in sources if p.stem in names]
        if {p.stem for p in sources} != names:
            parser.error("--only contains unknown plugin names")
    if not sources:
        parser.error("no plugin sources found")
    records = []
    for source in sources:
        output = args.output / (source.stem + ".amxx")
        # Compile to a fresh temporary name so old artifacts cannot masquerade as success.
        pending = args.output / (source.stem + ".pending.amxx")
        if pending.exists():
            pending.unlink()
        command = [str(args.compiler), str(source.resolve()), f"-o{pending}"]
        command += [f"-i{p.resolve()}" for p in (args.source_root / "include", args.amxx_include, args.reapi_include)]
        result = subprocess.run(command, cwd=args.compiler.parent, capture_output=True, timeout=90)
        text = (result.stdout + result.stderr).decode("utf-8", errors="replace")
        (args.output / (source.stem + ".log")).write_text(text, encoding="utf-8")
        errors = re.findall(r"(?m)^.*(?:fatal )?error \d+.*$", text)
        warnings = re.findall(r"(?m)^.*warning \d+.*$", text)
        success = result.returncode == 0 and pending.exists() and not errors
        if success:
            pending.replace(output)
        elif output.exists():
            output.unlink()
        records.append({"plugin": source.name, "success": success, "returncode": result.returncode,
                        "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                        "errors": errors, "warnings": warnings})
        print(f"{'PASS' if success else 'FAIL'} {source.name}: {len(errors)} errors, {len(warnings)} warnings", flush=True)
    report = {"compiler": str(args.compiler), "compiler_sha256": hashlib.sha256(args.compiler.read_bytes()).hexdigest(),
              "amxx_include": str(args.amxx_include.resolve()), "reapi_commit": REAPI_COMMIT,
              "source_root": str(args.source_root.resolve()), "plugins": records}
    (args.output / "report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    failed = sum(not r["success"] for r in records)
    print(f"Compiled {len(records) - failed}/{len(records)} plugins; report: {args.output / 'report.json'}")
    return int(failed != 0)


if __name__ == "__main__":
    sys.exit(main())
