#!/usr/bin/env bash
# desc: Desktop apps — foot + fish + starship, btop, micro, qt5ct/qt6ct, adw-gtk3 + Papirus, all following the wallpaper scheme
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

enable_copr atim/starship
install_pkgs foot fish starship btop nvtop htop micro qt5ct qt6ct adw-gtk3-theme papirus-icon-theme

link_dotfile "$CONFIG_DIR/foot"          "$HOME/.config/foot"
link_dotfile "$CONFIG_DIR/fish"          "$HOME/.config/fish"
link_dotfile "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
link_dotfile "$CONFIG_DIR/btop"          "$HOME/.config/btop"
link_dotfile "$CONFIG_DIR/micro"         "$HOME/.config/micro"
link_dotfile "$CONFIG_DIR/qt5ct"         "$HOME/.config/qt5ct"
link_dotfile "$CONFIG_DIR/qt6ct"         "$HOME/.config/qt6ct"
need_cmd zed && link_dotfile "$CONFIG_DIR/zed" "$HOME/.config/zed"   # zed isn't packaged for Fedora

# GTK apps: adw-gtk3 + Papirus, dark (the shellscape CLI rewrites gtk.css on every scheme change)
if need_cmd gsettings && ask_yes_no "Switch GTK apps to adw-gtk3-dark + Papirus-Dark (also affects them under KDE)?" y; then
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  ok "GTK theme → adw-gtk3-dark, icons → Papirus-Dark"
fi
note "Default login shell stays zsh. Try fish any time with: fish  (and foot as a second terminal)."

# GNOME Settings exits outside GNOME ("only supported under GNOME and Unity"). A local
# desktop entry shadows the system one and starts it with a GNOME desktop name.
GS="$HOME/.local/share/applications/org.gnome.Settings.desktop"
if [[ -f /usr/share/applications/org.gnome.Settings.desktop ]] && ! grep -qs 'X-Shellscape' "$GS"; then
  mkdir -p "$(dirname "$GS")"
  sed -e '/^OnlyShowIn=/d' -e 's|^Exec=gnome-control-center|Exec=env XDG_CURRENT_DESKTOP=GNOME gnome-control-center|' \
      -e 's|^\[Desktop Entry\]|[Desktop Entry]\nX-Shellscape=true|' \
      /usr/share/applications/org.gnome.Settings.desktop > "$GS"
  ok "GNOME Settings now opens under Hyprland"
fi
