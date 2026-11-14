#!/usr/bin/env bash
# desc: Fastfetch — system info banner with Fedora logo (configs ported from Arch-Hyprland)
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

install_pkgs fastfetch chafa   # chafa = image fallback for terminals without the kitty graphics protocol

FF_SRC="$CONFIG_DIR/fastfetch"

# Logo: prefer the one shipped in the repo; otherwise grab Fedora's own from fedora-logos.
if [[ ! -s "$FF_SRC/fedora.png" ]]; then
  for cand in /usr/share/icons/hicolor/256x256/apps/fedora-logo-icon.png /usr/share/pixmaps/fedora-logo.png; do
    if [[ -s "$cand" ]]; then cp "$cand" "$FF_SRC/fedora.png"; ok "Copied Fedora logo from $cand"; break; fi
  done
fi
[[ -s "$FF_SRC/fedora.png" ]] || warn "No fedora.png found — fastfetch will use its built-in ASCII logo"

link_dotfile "$FF_SRC" "$HOME/.config/fastfetch"
