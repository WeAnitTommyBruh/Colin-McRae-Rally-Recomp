#!/usr/bin/env bash
# Runs INSIDE the MSYS2 "MinGW x64" shell. build_windows.bat starts it for you.
#   - installs the build tools with pacman
#   - passes the disc (CMRR_DISC, a Windows path) to tools/setup_and_build.py
# Any extra arguments go to setup_and_build.py (e.g. --force).
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "${MSYSTEM:-}" != "MINGW64" ]; then
  echo "error: run this from the 'MSYS2 MinGW x64' shell (MSYSTEM=MINGW64), not '${MSYSTEM:-plain bash}'." >&2
  exit 1
fi

PKGS="git mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake mingw-w64-x86_64-ninja mingw-w64-x86_64-python"

printf '\n=== Installing build tools (MSYS2 packages)\n'
# shellcheck disable=SC2086  # PKGS is intentionally word-split
if ! pacman -S --needed --noconfirm $PKGS; then
  printf '\n=== Updating MSYS2, then retrying\n'
  pacman -Syu --noconfirm || true
  # shellcheck disable=SC2086
  pacman -S --needed --noconfirm $PKGS
fi

ARGS=()
if [ -n "${CMRR_DISC:-}" ]; then
  ARGS+=(--disc "$(cygpath -u "$CMRR_DISC")")
fi

python3 tools/setup_and_build.py ${ARGS[@]+"${ARGS[@]}"} "$@"
