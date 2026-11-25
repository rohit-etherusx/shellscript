#!/usr/bin/env bash
# desc: Hyprland — compositor + idle/lock/picker/polkit, uwsm session, clipboard, screenshot & system tools
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
# Ported from caelestia-fedora/install.fish (ensure_tools, hyprptools_install, app2unit_install).

# Fedora 45 dropped Hyprland from the main repos; sdegler/hyprland tracks releases.
enable_copr sdegler/hyprland

install_pkgs \
  hyprland hypridle hyprpicker hyprpolkitagent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk uwsm \
  cliphist wl-clipboard grim slurp swappy wf-recorder fuzzel ydotool \
  fish jq socat inotify-tools libnotify trash-cli xdg-utils xdg-terminal-exec desktop-file-utils dash \
  gnome-keyring gammastep geoclue2-demos bluez bluez-tools wireplumber pavucontrol qps \
  brightnessctl ddcutil lm_sensors NetworkManager breeze-cursor-theme \
  Thunar thunar-volman thunar-archive-plugin tumbler

# app2unit — launches apps as systemd units (every Hyprland app keybind uses it). Not packaged.
if need_cmd app2unit; then
  info "app2unit already installed. Skipping..."
else
  SRC="$BUILD_DIR/app2unit"
  git_clone https://github.com/Vladimir-csp/app2unit.git "$SRC"
  # install-bin only: install-man needs scdoc, and the man page is not needed
  run_logged "Installing ${YELLOW}app2unit${RESET}" sudo -n make -C "$SRC" install-bin \
    && need_cmd app2unit && ok "app2unit installed" || die "app2unit install failed"
fi

link_dotfile "$CONFIG_DIR/hypr" "$HOME/.config/hypr"
link_dotfile "$CONFIG_DIR/uwsm" "$HOME/.config/uwsm"
link_dotfile "$CONFIG_DIR/thunar/uca.xml" "$HOME/.config/Thunar/uca.xml"
link_dotfile "$CONFIG_DIR/thunar/thunar-volman.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml"

# Per-machine overrides live outside the repo (loaded by hyprland.lua).
# Hyprland 0.57+ only reads Lua (config/hypr/hyprland.lua); overrides are Lua too.
VARS="$HOME/.config/shellscape/hypr-vars.lua"
mkdir -p "$(dirname "$VARS")"; touch "$VARS"
if ! grep -q '^V.browser' "$VARS"; then
  for b in firefox brave-browser google-chrome-stable chromium-browser; do
    if need_cmd "$b"; then echo "V.browser = \"$b\"" >>"$VARS"; ok "Super+B → $b (edit $VARS to change)"; break; fi
  done
fi
(cd /tmp && Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua" 2>&1 | grep -q '^config ok') \
  && ok "Hyprland config verified" || die "Hyprland rejected config/hypr/hyprland.lua (run: Hyprland --verify-config -c ~/.config/hypr/hyprland.lua)"
