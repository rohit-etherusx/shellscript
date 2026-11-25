#!/usr/bin/env bash
# desc: Shellscape shell — Quickshell desktop: bar, launcher, dashboard, notifications, lock screen, OSDs
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
# Source: desktop/shell (rebranded caelestia-shell, see desktop/UPSTREAM).

# The shell needs Quickshell's git build, not the tagged release Fedora ships.
enable_copr errornointernet/quickshell
if pkg_installed quickshell && ! pkg_installed quickshell-git; then
  run_logged "Replacing Fedora quickshell with ${YELLOW}quickshell-git${RESET}" \
    sudo -n dnf swap -y quickshell quickshell-git || die "quickshell swap failed"
fi
install_pkgs ImageMagick quickshell-git qt6-qtdeclarative qt6-qtsvg qt6-qtimageformats \
  cava aubio libqalculate ddcutil brightnessctl NetworkManager lm_sensors swappy grim \
  gcc-c++ pkgconf-pkg-config pipewire-devel aubio-devel wayland-devel wayland-protocols-devel

SHELL_SRC="$DESKTOP_DIR/shell"
LIB=/usr/lib/shellscape
CPP="$SHELL_SRC/assets/cpp"

# Beat detector (audio visualiser beats) — PipeWire + aubio
if [[ -x "$LIB/beat_detector" && "$LIB/beat_detector" -nt "$CPP/beat-detector.cpp" ]]; then
  info "beat_detector is up to date"
else
  run_logged "Compiling ${YELLOW}beat_detector${RESET}" bash -c \
    'g++ -std=c++17 -O2 $(pkg-config --cflags libpipewire-0.3 aubio) "$1" -o "$2" $(pkg-config --libs libpipewire-0.3 aubio)' \
    _ "$CPP/beat-detector.cpp" "$BUILD_DIR/beat_detector" || die "beat_detector build failed"
  sudo -n install -Dm755 "$BUILD_DIR/beat_detector" "$LIB/beat_detector" && ok "Installed $LIB/beat_detector"
fi

# Idle inhibitor (the dashboard's "keep awake" toggle) — needs headers generated from the protocol XML
if [[ -x "$LIB/inhibit_idle" && "$LIB/inhibit_idle" -nt "$CPP/idle-inhibitor.cpp" ]]; then
  info "inhibit_idle is up to date"
else
  XML="$(pkg-config --variable=pkgdatadir wayland-protocols)/unstable/idle-inhibit/idle-inhibit-unstable-v1.xml"
  B="$BUILD_DIR/idle-inhibitor"; mkdir -p "$B"
  run_logged "Compiling ${YELLOW}inhibit_idle${RESET}" bash -c '
    set -e
    wayland-scanner client-header "$1" "$2/idle-inhibitor.h"
    wayland-scanner private-code  "$1" "$2/idle-inhibitor.c"
    gcc -O2 -c "$2/idle-inhibitor.c" -o "$2/protocol.o"
    g++ -std=c++17 -O2 -I"$2" "$3" "$2/protocol.o" -o "$2/inhibit_idle" $(pkg-config --libs wayland-client)' \
    _ "$XML" "$B" "$CPP/idle-inhibitor.cpp" || die "inhibit_idle build failed"
  sudo -n install -Dm755 "$B/inhibit_idle" "$LIB/inhibit_idle" && ok "Installed $LIB/inhibit_idle"
fi

# Fonts the shell's UI uses: Material Symbols (icons) + CaskaydiaCove Nerd Font (mono text)
FDIR="$HOME/.local/share/fonts"
# Only the Rounded family is referenced by the QML (upstream also fetched Outlined/Sharp).
download "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.ttf" \
  "$FDIR/MaterialSymbols/MaterialSymbolsRounded.ttf"
if fc-list | grep -i 'CaskaydiaCove Nerd Font' >/dev/null; then
  info "CaskaydiaCove Nerd Font already installed. Skipping..."
else
  download "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip" "$BUILD_DIR/CascadiaCode.zip"
  mkdir -p "$FDIR/CaskaydiaCoveNerdFont"
  run_logged "Extracting ${YELLOW}CaskaydiaCove Nerd Font${RESET}" unzip -o -q "$BUILD_DIR/CascadiaCode.zip" -d "$FDIR/CaskaydiaCoveNerdFont" -x 'LICENSE*' 'README*'
fi
run_logged "Rebuilding font cache" fc-cache -f

link_dotfile "$SHELL_SRC" "$HOME/.config/quickshell/shellscape"
mkdir -p "$HOME/Pictures/Wallpapers"
# First run: start from Fedora's own wallpaper so the desktop (and its colour scheme) isn't blank.
DEFAULT_WALL="$HOME/Pictures/Wallpapers/fedora-default.jpg"
SRC_WALL=/usr/share/backgrounds/images/default-dark.jxl
if [[ ! -s "$HOME/.local/state/shellscape/wallpaper/path.txt" && -e "$SRC_WALL" ]]; then
  [[ -s "$DEFAULT_WALL" ]] || run_logged "Converting Fedora's default wallpaper" magick "$SRC_WALL" -resize 3840x3840 -quality 92 "$DEFAULT_WALL"
  if [[ -s "$DEFAULT_WALL" ]] && shellscape wallpaper -f "$DEFAULT_WALL" >>"$LOG" 2>&1; then
    ok "Wallpaper → $DEFAULT_WALL (colour scheme generated from it)"
  else
    warn "Could not set a default wallpaper; pick one later with: shellscape wallpaper -f <image>"
  fi
fi
ok "Wallpapers folder: ~/Pictures/Wallpapers (pick one with Super → '>wallpaper' or: shellscape wallpaper -f <file>)"
