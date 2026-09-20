# Notices

This repository contains **no game data**: no disc image, no executable from the disc, no
generated code, no retail BIOS. You supply your own disc dump and build everything locally.

## Third-party components (fetched by `tools/setup_and_build.py`, not stored here)

| Component | Source | License |
|---|---|---|
| psxrecomp (recompiler + runtime) | https://github.com/mstan/psxrecomp | PolyForm Noncommercial 1.0.0 |
| recomp-ui (launcher) | https://github.com/RetroPortingToolKit/recomp-ui | MIT |
| OpenBIOS (bundled with psxrecomp) | see `psxrecomp/bios/OpenBIOS.LICENSE` | see that file |
| SDL3, zlib, Dear ImGui, etc. (fetched by CMake) | their own repositories | their own licenses |

`patches/*.patch` are modifications to psxrecomp source and remain under psxrecomp's license
(PolyForm Noncommercial 1.0.0, Copyright (c) 2026 Matthew Stanley). Because of that, this project
is offered under the same noncommercial terms (see `LICENSE`).

The game name, publisher and trademarks belong to their respective owners. This project is not
affiliated with or endorsed by them.
