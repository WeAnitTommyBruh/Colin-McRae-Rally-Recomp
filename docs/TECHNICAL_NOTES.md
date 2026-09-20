# Technical notes

Findings and decisions from bringing up Colin McRae Rally (USA, SCUS-94474) on psxrecomp.
"Verified" means observed; everything else is stated as such.

## Status

| Item | State |
|---|---|
| Recompile (generate) from the disc | Works; 460 functions, about 341k lines of C in 9 files |
| Linux build | Boots, loads the disc, plays the intro video (checked under a virtual display with software OpenGL) |
| Widescreen gameplay | Reported working by a player on Linux |
| Windows build | Cross-compiled and checked to be a PE32+ exe importing only system DLLs; **never run** |
| Menus after the latest detection changes | Not verified |
| Full playthrough, audio, saves, overlays | Not verified |

## The boot executable

- `SCUS_944.74`: 978,944 bytes, loads at `0x80013000`, entry `0x800EC4D4`.
- `0x80013000`-`0x800BF000` is data. Real code is roughly `0x800C0000`-`0x800E9000`, plus a little
  around the entry point.
- The default whole-image discovery decodes that data as instructions and the emitter runs out of
  memory (it was killed at over 3.7 GB). `game.toml` sets `discovery = "reachable"`, which follows calls from the
  entry point instead.
- `seeds/ghidra_funcs.txt` holds first-pass JAL targets. About 60 fall inside data; the generator
  reports "fails the boundary check" and treats them as aliases. Harmless.
- The analyzer reported about 120 unresolved indirect jump sites. Not yet investigated. Whether the
  game loads code from disc at runtime (overlays) has not been checked.

## Widescreen

The framework has no generic aspect-ratio setting in this version; display views belong to
game-owned mods. This project ships one: `mods/preloaded/packages/colinmcrae.widescreen`, with
`colin_widescreen_plugin.c` as its implementation. Options: View (16:9, 21:9, adaptive), Menus and
2D screens (keep 4:3 / stretch), Gameplay detection (strict / normal / any 3D).

Findings that shaped the settings:

- **Classifier.** `gte_game_mode = true` calls any frame projecting 3 or more GTE vertices
  "gameplay" (with a 45-frame hold). This game's title screen spins a globe through the GTE, so
  menus were widened and rendered with doubled or mirrored text. Patch 002 adds an overhang gate
  (a frame only counts as gameplay if polygons also run past the screen edge). Patch 003 adds a
  minimum-polygon count so a menu backdrop cannot trip it; "strict" uses 16 (a guess based on
  another game's census, not measured here).
- **HUD corner anchoring** (`nw_hud_corners`) was tried and left off: it split HUD elements that
  span a third boundary.
- **Screen-edge cull scan.** `psxrecomp-analyze --scan-widescreen` proposed three sites. Reading the
  code, they are display-mode / viewport setup, not culls, so `auto_screen_x` is not enabled.
- **2D stretch.** The framework pins 2D frames to a 4:3 pillarbox. Patch 001 adds an option to
  stretch them instead (distorts horizontally); it defaults to off.
- Not done: per-title sprite tagging and edge-cull address lists. Expect stretched billboards or
  pop-in near the screen edges in some places.

## Other settings

- PGXP is pinned off (`geometry_correction`, `perspective_texturing`, `pgxp_cpu_mode` = false, and
  the `_pgxp` build variant disabled). `pgxp_tolerance = 3.5` only matters if PGXP is turned on; any
  value of 1.0 or more behaves as "no clamp".
- `hud_sprt_squash` and `auto_ui_squash` are off.

## Patches (psxrecomp 1a0897ca)

Applied in filename order by `tools/apply_patches.py`, which records state in
`psxrecomp/.psxrecomp_applied_patches` and adopts patches already present in the tree.

1. `001-psxrecomp-stretch-2d-frames.patch`: presenter option and `psx_mod_set_stretch_2d_frames()`.
2. `002-psxrecomp-gte-overhang-gate.patch`: `psx_mod_set_gte_scene_overhang_gate()`.
3. `003-psxrecomp-overhang-min-prims.patch`: `psx_mod_set_scene_overhang_min_prims()`.

Without the patches the game still builds and runs; the plugin references the new functions weakly
and the corresponding options do nothing.

## Release builds

Release builds have no TCP debug server (`-DPSX_DEBUG_TOOLS=ON` adds one). The `psxrecomp-analyze`
tool (`cmake --build build-recompiler --target psxrecomp-analyze`) is useful for coverage reports.
