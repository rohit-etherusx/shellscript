#!/usr/bin/env bash
# desc: Spotify — Flatpak Spotify + Spicetify with the Shellscape theme (recoloured with the wallpaper)
# optional
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

install_pkgs flatpak
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak info com.spotify.Client >/dev/null 2>&1 \
  || run_logged "Installing ${YELLOW}Spotify${RESET} (Flatpak)" flatpak install --user -y flathub com.spotify.Client
SP="$(flatpak info --show-location com.spotify.Client)/files/extra/share/spotify"
PREFS="$HOME/.var/app/com.spotify.Client/config/spotify/prefs"
[[ -f "$PREFS" ]] || { warn "Start Spotify once and log in (creates $PREFS), then re-run: ./install.sh --only spotify"; exit 0; }

if ! need_cmd spicetify && [[ ! -x "$HOME/.spicetify/spicetify" ]]; then
  download https://raw.githubusercontent.com/spicetify/cli/main/install.sh "$BUILD_DIR/spicetify-install.sh"
  run_logged "Installing ${YELLOW}spicetify${RESET}" sh "$BUILD_DIR/spicetify-install.sh"
fi
SPICE="$(command -v spicetify || echo "$HOME/.spicetify/spicetify")"

link_dotfile "$CONFIG_DIR/spicetify" "$HOME/.config/spicetify"
"$SPICE" config spotify_path "$SP" prefs_path "$PREFS" >>"$LOG" 2>&1
"$SPICE" config current_theme shellscape color_scheme shellscape >>"$LOG" 2>&1
run_logged "Applying Spicetify theme" "$SPICE" backup apply && ok "Spotify themed (re-run 'spicetify apply' after Spotify updates)"
