#!/usr/bin/env python3
"""One command from a fresh checkout to a built game.

    python3 tools/setup_and_build.py --disc /path/to/your/dump

Steps (each is skipped when already done, unless --force):
  1. check the tools you need are installed
  2. fetch psxrecomp and recomp-ui at the versions in framework_pins.txt (git)
  3. apply this project's patches to psxrecomp
  4. stage your disc as disc/game.cue + disc/game_trackN.bin (any file names work)
  5. build the recompiler tools
  6. generate the game's C code from YOUR disc
  7. build the game into build-release/

Needs your own disc dump (.cue + .bin files, or a folder holding them). Nothing here downloads or
contains game data. On Windows run it from the "MSYS2 MinGW x64" shell.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
PY = sys.executable
FRAMEWORKS = [
    # (folder, git url, pin name in framework_pins.txt, init submodules?)
    ("psxrecomp", "https://github.com/mstan/psxrecomp.git", "psxrecomp", True),
    ("recomp-ui", "https://github.com/RetroPortingToolKit/recomp-ui.git", "recomp-ui", False),
]


def say(msg):
    print(f"\n=== {msg}", flush=True)


def die(msg):
    sys.exit(f"\nerror: {msg}")


def run(*cmd, cwd=root, check=True):
    print("+", " ".join(str(c) for c in cmd), flush=True)
    return subprocess.run([str(c) for c in cmd], cwd=cwd, check=check)


def pins():
    out = {}
    for line in (root / "framework_pins.txt").read_text().splitlines():
        m = re.match(r"([\w.-]+)=\S+\s+\(([0-9a-f]{40})\)", line.strip())
        if m:
            out[m.group(1)] = m.group(2)
    return out


def preflight(want_windows_cross):
    say("Checking tools")
    if sys.version_info < (3, 8):
        die("Python 3.8 or newer is required")
    missing = []
    for tool, hint in [("git", "git"), ("cmake", "cmake"), ("ninja", "ninja / ninja-build"),
                       ("bash", "bash (MSYS2 has it)")]:
        if not shutil.which(tool):
            missing.append(hint)
    if not any(shutil.which(c) for c in ("gcc", "clang", "cc")):
        missing.append("a C compiler (gcc or clang)")
    if not any(shutil.which(c) for c in ("g++", "clang++", "c++")):
        missing.append("a C++ compiler (g++ or clang++)")
    if os.name == "nt" and not os.environ.get("MSYSTEM"):
        die("On Windows, run this from the 'MSYS2 MinGW x64' shell (see README.md).")
    if want_windows_cross and not shutil.which("x86_64-w64-mingw32-gcc-posix"):
        missing.append("MinGW-w64 cross compiler (gcc-mingw-w64-x86-64-posix, g++-mingw-w64-x86-64-posix, "
                       "binutils-mingw-w64-x86-64) for --windows")
    if missing:
        die("missing: " + ", ".join(missing) + "\nSee the Requirements section of README.md.")
    print("ok")


def ensure_repo(folder, url, sha, submodules):
    d = root / folder
    if not (d / ".git").exists():
        if d.exists() and any(d.iterdir()):
            die(f"{folder}/ exists but is not a git checkout. Delete it and re-run.")
        if d.exists():
            d.rmdir()
        say(f"Cloning {folder}")
        run("git", "clone", url, folder)
    head = subprocess.run(["git", "-C", str(d), "rev-parse", "HEAD"], capture_output=True, text=True).stdout.strip()
    if head != sha:
        say(f"Checking out {folder} @ {sha[:8]}")
        if run("git", "-C", d, "checkout", "--detach", sha, check=False).returncode:
            run("git", "-C", d, "fetch", "origin", sha)
            run("git", "-C", d, "checkout", "--detach", sha)
    if submodules:
        run("git", "-C", d, "submodule", "update", "--init", "--recursive")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--disc", help="folder / .cue / .bin of your own disc dump (needed the first time)")
    ap.add_argument("--windows", action="store_true",
                    help="also cross-compile the Windows .exe from Linux (adds it to build-release/)")
    ap.add_argument("--skip-build", action="store_true", help="stop after generating the C code")
    ap.add_argument("--force", action="store_true", help="redo steps that look finished")
    a = ap.parse_args()

    preflight(a.windows)
    pin = pins()

    for folder, url, name, subs in FRAMEWORKS:
        if name not in pin:
            die(f"framework_pins.txt has no full commit for {name}")
        ensure_repo(folder, url, pin[name], subs)

    say("Applying patches to psxrecomp")
    run(PY, "tools/apply_patches.py")

    staged = root / "disc" / "game.cue"
    if a.disc:
        say("Staging your disc")
        run(PY, "tools/stage_disc.py", a.disc, "--out", "disc")
    elif not staged.exists():
        die("no disc yet. Re-run with --disc /path/to/your/dump (a folder, .cue or .bin).")

    tools_built = any((root / "build-recompiler").glob("psxrecomp-game*"))
    if a.force or not tools_built:
        say("Building the recompiler tools")
        run("bash", "psxrecomp/tools/ci/build_emitters.sh")

    say("Generating the game's C code from your disc")
    run(PY, "psxrecomp/psxrecomp_cli.py", "generate", "--config", "game.toml",
        "--project-root", ".", "--no-toolchain-download")

    if a.skip_build:
        return
    say("Building build-release/")
    cmd = [PY, "tools/build_release.py"]
    if a.windows:
        cmd.append("--windows")
    run(*cmd)

    exe = "ColinMcRaeRally_Recompiled" + (".exe" if os.name == "nt" else "")
    say("Done")
    print(f"Run: build-release/{exe}")
    print("Widescreen: launcher -> Mods -> Colin McRae Rally Widescreen (applies on next start).")


if __name__ == "__main__":
    main()
