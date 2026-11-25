"""Run offline Python regressions and every checked-in Pawn fixture."""
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    commands = [[sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"]]
    commands += [[sys.executable, "tools/run_pawn_test.py", str(p.relative_to(ROOT))]
                 for p in sorted((ROOT / "tests").glob("*.sma"))]
    for command in commands:
        result = subprocess.run(command, cwd=ROOT)
        if result.returncode:
            return result.returncode
    print(f"Offline verification passed: Python suite + {len(commands)-1} Pawn fixtures.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
