#!/usr/bin/env python3
"""Build the Linux and Windows versions into ONE folder: build-release/

    python3 tools/build_release.py              # native build (Linux, or Windows under MSYS2)
    python3 tools/build_release.py --windows    # also cross-compile the Windows .exe (Linux host)

With --windows, build-release/ ends up holding both executables next to the shared assets/,
bios/, mods/ and game.toml, so the same folder runs on either OS:

    ColinMcRaeRally_Recompiled        Linux x86-64
    ColinMcRaeRally_Recompiled.exe    Windows x64 (MinGW-w64 cross build; needs the
                                      gcc-mingw-w64-x86-64-posix packages, see README.md)

Run tools/setup_and_build.py first (or the manual steps in README.md).
"""
import shutil
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
rel, win = root / "build-release", root / "build-win"
EXE = "ColinMcRaeRally_Recompiled"


def run(*cmd):
    print("+", " ".join(map(str, cmd)), flush=True)
    subprocess.run(cmd, cwd=root, check=True)


run("cmake", "-S", ".", "-B", "build-release", "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release")
run("cmake", "--build", "build-release", "--target", "psx-runtime")

if "--windows" not in sys.argv:   # (--no-windows is accepted and ignored: it is the default)
    print(f"\nbuilt build-release/{EXE}" + (".exe" if sys.platform == "win32" else ""))
    sys.exit(0)
if not shutil.which("x86_64-w64-mingw32-gcc-posix"):
    sys.exit("MinGW-w64 not found; cannot cross-compile the Windows build "
             "(sudo apt install gcc-mingw-w64-x86-64-posix g++-mingw-w64-x86-64-posix "
             "binutils-mingw-w64-x86-64)")

run("cmake", "-S", ".", "-B", "build-win", "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release",
    "-DCMAKE_TOOLCHAIN_FILE=toolchains/mingw-w64-x86_64.cmake")
run("cmake", "--build", "build-win", "--target", "psx-runtime")
shutil.copy2(win / (EXE + ".exe"), rel / (EXE + ".exe"))
print(f"\nbuild-release/ now has {EXE} (Linux) and {EXE}.exe (Windows)")
