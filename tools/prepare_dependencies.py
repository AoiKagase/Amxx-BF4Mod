"""Fetch hash-pinned reference headers into ignored build/dependencies (no server install)."""
import argparse
import hashlib
import json
from pathlib import Path
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--offline", action="store_true", help="Use already downloaded archives only")
    args = parser.parse_args()
    lock = json.loads((ROOT / "tools/dependencies.lock.json").read_text(encoding="utf-8"))
    build = ROOT / "build"
    target = build / "dependencies"
    target.mkdir(parents=True, exist_ok=True)
    for dependency in lock["archives"]:
        archive = build / (dependency["name"] + ".zip")
        if not archive.exists():
            if args.offline:
                parser.error(f"missing offline archive: {archive}")
            url = f'https://codeload.github.com/{dependency["repository"]}/zip/{dependency["commit"]}'
            with urllib.request.urlopen(url, timeout=40) as response:
                data = response.read(16 * 1024 * 1024 + 1)
            if len(data) > 16 * 1024 * 1024:
                raise ValueError("dependency archive exceeds size limit")
            if hashlib.sha256(data).hexdigest() != dependency["sha256"]:
                raise ValueError("downloaded dependency hash mismatch")
            archive.write_bytes(data)
        if hashlib.sha256(archive.read_bytes()).hexdigest() != dependency["sha256"]:
            raise ValueError(f"archive hash mismatch: {archive}")
        with zipfile.ZipFile(archive) as contents:
            for info in contents.infolist():
                path = (target / info.filename).resolve()
                if not path.is_relative_to(target.resolve()):
                    raise ValueError("dependency contains path traversal")
            contents.extractall(target)
        print(f'{dependency["name"]}: verified {dependency["commit"]}')
    headers = target / lock["archives"][0]["folder"] / "reapi/extra/amxmodx/scripting/include"
    (headers / "reapi_version.inc").write_text(
        "#define REAPI_VERSION_MAJOR 5\n#define REAPI_VERSION_MINOR 29\n#define REAPI_VERSION 529\n", encoding="ascii")


if __name__ == "__main__":
    main()
