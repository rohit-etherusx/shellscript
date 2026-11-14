#!/usr/bin/env bash
# desc: Ptyxis — point Fedora's default terminal at the Nerd Font + Catppuccin Mocha palette
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

# Ptyxis ships with Fedora Workstation/KDE. Without a Nerd Font its powerline
# glyphs render as stray letters, so switch it off the system "Monospace" font.
if ! need_cmd ptyxis; then
  info "Ptyxis not installed. Skipping..."
  exit 0
fi
need_cmd gsettings || die "gsettings not found (glib2 is required to configure Ptyxis)"

FONT="JetBrainsMono Nerd Font 11"

# Font
if [[ "$(gsettings get org.gnome.Ptyxis use-system-font)" == "false" && \
      "$(gsettings get org.gnome.Ptyxis font-name)" == "'$FONT'" ]]; then
  info "Ptyxis already uses $FONT"
else
  gsettings set org.gnome.Ptyxis use-system-font false
  gsettings set org.gnome.Ptyxis font-name "$FONT"
  ok "Ptyxis font → $FONT"
fi

# Cursor — beam + blink, same as kitty.conf
gsettings set org.gnome.Ptyxis cursor-shape 'ibeam'
gsettings set org.gnome.Ptyxis cursor-blink-mode 'on'
ok "Ptyxis cursor → blinking beam"

# Palette — Ptyxis ships "Catppuccin Mocha" built in; the id is the palette's
# file name without .palette (case and spaces matter).
PAL="Catppuccin Mocha"
for uuid in $(gsettings get org.gnome.Ptyxis profile-uuids | tr -d "[]',"); do
  SCHEMA="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$uuid/"
  if [[ "$(gsettings get "$SCHEMA" palette)" == "'$PAL'" ]]; then
    info "Ptyxis profile $uuid already uses $PAL"
  else
    gsettings set "$SCHEMA" palette "$PAL"
    ok "Ptyxis profile $uuid palette → $PAL"
  fi
done
note "Open a new Ptyxis tab/window to see the changes."
