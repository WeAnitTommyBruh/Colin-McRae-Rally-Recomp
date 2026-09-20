#!/usr/bin/env bash
# Linux: install the build dependencies for your distro, then build the game.
#
#   ./build_linux.sh --disc /path/to/your/dump          # install deps (asks first) + build
#   ./build_linux.sh --disc /path/to/dump --windows     # also cross-compile the Windows .exe
#   ./build_linux.sh --no-deps                          # skip the install step
#   ./build_linux.sh --dry-run                          # show what would run, change nothing
#   ./build_linux.sh -y                                 # don't ask before installing packages
#
# Package installs are tested on Debian/Ubuntu only; the dnf and pacman lists are best effort.
# The build itself is tools/setup_and_build.py (see README.md).
set -euo pipefail
cd "$(dirname "$0")"

DISC="" ; WINDOWS=0 ; DEPS=1 ; DRY=0 ; YES=0 ; EXTRA=()
while [ $# -gt 0 ]; do
  case "$1" in
    --disc)     DISC="${2:?--disc needs a path}"; shift 2 ;;
    --windows)  WINDOWS=1; shift ;;
    --no-deps)  DEPS=0; shift ;;
    --dry-run)  DRY=1; shift ;;
    -y|--yes)   YES=1; shift ;;
    -h|--help)  sed -n '2,12p' "$0"; exit 0 ;;
    *)          EXTRA+=("$1"); shift ;;   # passed to setup_and_build.py (e.g. --force)
  esac
done

say()  { printf '\n=== %s\n' "$*"; }
run()  { printf '+ %s\n' "$*"; [ "$DRY" = 1 ] || "$@"; }
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

APT_PKGS="git cmake ninja-build gcc g++ python3 libx11-dev libxext-dev libxcursor-dev libxi-dev \
libxrandr-dev libxss-dev libxfixes-dev libxtst-dev libxinerama-dev libxxf86vm-dev libxkbcommon-dev \
libwayland-dev wayland-protocols libdrm-dev libgbm-dev libegl-dev libgl-dev libasound2-dev \
libpulse-dev libudev-dev libdbus-1-dev libdecor-0-dev libibus-1.0-dev"
APT_WIN="gcc-mingw-w64-x86-64-posix g++-mingw-w64-x86-64-posix binutils-mingw-w64-x86-64"
DNF_PKGS="git cmake ninja-build gcc gcc-c++ python3 libX11-devel libXext-devel libXcursor-devel \
libXi-devel libXrandr-devel libXScrnSaver-devel libXfixes-devel libXtst-devel libXinerama-devel \
libXxf86vm-devel libxkbcommon-devel wayland-devel wayland-protocols-devel libdrm-devel \
mesa-libgbm-devel mesa-libEGL-devel mesa-libGL-devel alsa-lib-devel pulseaudio-libs-devel \
systemd-devel dbus-devel libdecor-devel ibus-devel"
PACMAN_PKGS="git cmake ninja gcc python libx11 libxext libxcursor libxi libxrandr libxss libxfixes \
libxtst libxinerama libxkbcommon wayland wayland-protocols libdrm mesa libglvnd alsa-lib libpulse \
systemd-libs dbus libdecor ibus"

# shellcheck disable=SC2086  # package lists are intentionally word-split
install_deps() {
  if command -v apt-get >/dev/null; then MGR=apt; PKGS="$APT_PKGS"; [ "$WINDOWS" = 1 ] && PKGS="$PKGS $APT_WIN"
  elif command -v dnf >/dev/null;   then MGR=dnf; PKGS="$DNF_PKGS"
  elif command -v pacman >/dev/null; then MGR=pacman; PKGS="$PACMAN_PKGS"
  else echo "No apt, dnf or pacman found. Install the packages listed in README.md by hand, then re-run with --no-deps."; exit 1
  fi
  if [ "$WINDOWS" = 1 ] && [ "$MGR" != apt ]; then
    echo "--windows cross-compiling is only scripted for apt-based systems; install MinGW-w64 (posix threads) yourself."
  fi
  say "Installing build dependencies with $MGR"
  echo "Packages: $PKGS"
  if [ "$YES" = 0 ] && [ "$DRY" = 0 ]; then
    read -r -p "Install these now (uses ${SUDO:-root})? [y/N] " a
    case "$a" in y|Y|yes|YES) ;; *) echo "Skipped. Re-run with --no-deps once they are installed."; exit 1 ;; esac
  fi
  case "$MGR" in
    apt)    run $SUDO apt-get update; run $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $PKGS ;;
    dnf)    run $SUDO dnf install -y $PKGS ;;
    pacman) run $SUDO pacman -S --needed --noconfirm $PKGS ;;
  esac
}

[ "$DEPS" = 1 ] && install_deps

if [ -z "$DISC" ] && [ ! -f disc/game.cue ]; then
  read -r -p "Path to your disc dump (a folder, .cue or .bin): " DISC
  DISC="${DISC//\'/}"; DISC="${DISC/#\~/$HOME}"
fi

ARGS=()
[ -n "$DISC" ] && ARGS+=(--disc "$DISC")
[ "$WINDOWS" = 1 ] && ARGS+=(--windows)
say "Building"
run python3 tools/setup_and_build.py ${ARGS[@]+"${ARGS[@]}"} ${EXTRA[@]+"${EXTRA[@]}"}
