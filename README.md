# Colin McRae Rally (USA) - static recompilation with psxrecomp

An experimental static recompilation of *Colin McRae Rally* (PlayStation, USA, SCUS-94474) built on
[psxrecomp](https://github.com/mstan/psxrecomp), with widescreen support and a launcher
([recomp-ui](https://github.com/RetroPortingToolKit/recomp-ui)).

**You must build it yourself from your own disc.** This repository has no game data and there are no
downloadable executables: the recompiled code is derived from the game, so it can't be shared.

> **Status: experimental.** It boots and plays on Linux and widescreen gameplay has been reported
> working. The Windows build has never been run and there has been no full playthrough. See
> [docs/TECHNICAL_NOTES.md](docs/TECHNICAL_NOTES.md).

## What you need

- Your own dump of the USA disc as a `.cue` plus its `.bin` files (or a folder holding them). File
  names don't matter. Only `track 1` is required; the other tracks are CD audio (music).
- Nothing else for a BIOS: an open-source one (OpenBIOS) is bundled. You may use your own retail BIOS.
- About 4 GB of free disk space, an internet connection (the first build downloads SDL3 and other
  libraries from GitHub) and roughly 20-30 minutes.

## Build

Easiest way, one script per OS. Each installs the tools it needs, then runs the builder:

- **Windows:** double-click `build_windows.bat`, or drag your disc folder (or its `.cue`) onto it.
  It installs [MSYS2](https://www.msys2.org) with `winget` if you don't have it, so the project
  folder must be in a path without spaces (for example `C:\cmrr`).
- **Linux:** `./build_linux.sh --disc /path/to/your/dump` (asks before installing packages; use
  `-y` to skip the question, `--no-deps` if you already have them, `--dry-run` to preview,
  `--windows` to also cross-compile a Windows exe).

Or run the builder directly (the scripts above just wrap this):

```sh
python3 tools/setup_and_build.py --disc /path/to/your/dump
```

It fetches psxrecomp and recomp-ui at the tested versions, applies the patches, stages your disc,
generates the game's C code from it and builds into `build-release/`. Run
`build-release/ColinMcRaeRally_Recompiled` (`.exe` on Windows). Re-running skips finished steps;
`--force` redoes them. Options: `--windows` (also cross-compile a Windows exe from Linux),
`--skip-build`.

### Requirements

**Linux (Debian/Ubuntu names):**
```sh
sudo apt install git cmake ninja-build gcc g++ python3 \
  libx11-dev libxext-dev libxcursor-dev libxi-dev libxrandr-dev libxss-dev libxfixes-dev \
  libxtst-dev libxinerama-dev libxxf86vm-dev libxkbcommon-dev libwayland-dev wayland-protocols \
  libdrm-dev libgbm-dev libegl-dev libgl-dev libasound2-dev libpulse-dev libudev-dev \
  libdbus-1-dev libdecor-0-dev libibus-1.0-dev
```
For `--windows` also: `gcc-mingw-w64-x86-64-posix g++-mingw-w64-x86-64-posix binutils-mingw-w64-x86-64`.

**Windows:** install [MSYS2](https://www.msys2.org), open the **MSYS2 MinGW x64** shell and run
```sh
pacman -S --needed git mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake \
      mingw-w64-x86_64-ninja mingw-w64-x86_64-python
```
then the build command above from that same shell. Keep the project in a path without spaces.
If a generated file fails with "too many sections", add `-Wa,-mbig-obj` to its compile options.

macOS is untested.

## Running

Start the executable and pick your disc in the launcher (or pass `--no-launcher --disc your.cue`).
Widescreen: launcher -> **Mods -> Colin McRae Rally Widescreen**, enable it and choose a view; it
applies on the next start. Menus keep 4:3 by default. If the track ever stays 4:3, set *Gameplay
detection* to *Normal*.

## Known issues

- Windows build not yet run. `build_windows.bat` was tested only against a stand-in for MSYS2, so
  the real winget/MSYS2 install has not been exercised. `build_linux.sh` package installs are
  tested on Debian/Ubuntu only. No full playthrough, audio or save-game testing.
- Widescreen is untuned for this game: expect stretched billboards or objects popping in near the
  side edges in places. The HUD stays at its 4:3 position.
- It has not been checked whether the game loads code from disc at runtime.

## Layout

| Path | What |
|---|---|
| `game.toml`, `game_options.toml`, `seeds/` | recompiler and runtime configuration |
| `mods/`, `colin_widescreen_plugin.c` | widescreen mod and its plugin |
| `patches/` | three small patches to psxrecomp (see the notes) |
| `build_windows.bat`, `build_linux.sh` | one-step scripts: install tools + build |
| `tools/` | `setup_and_build.py`, `msys2_build.sh`, `stage_disc.py`, `apply_patches.py`, `build_release.py` |
| `toolchains/` | MinGW-w64 cross-compile toolchain file |
| `docs/TECHNICAL_NOTES.md` | findings, decisions, what is and isn't verified |

## Legal

Bring your own legally obtained disc. No game data, BIOS dump or generated code is distributed here.
Licensed under PolyForm Noncommercial 1.0.0 to match psxrecomp (see `LICENSE` and `NOTICE.md`).
Not affiliated with or endorsed by the game's rights holders.
