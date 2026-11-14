#!/usr/bin/env bash
# desc: Kitty — GPU terminal with Nerd Font + Catppuccin Mocha theme
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

install_pkgs kitty
link_dotfile "$CONFIG_DIR/kitty" "$HOME/.config/kitty"

# Make kitty the terminal KDE opens with Ctrl+Alt+T / "Open Terminal Here"
if need_cmd kwriteconfig6; then
  CUR="$(kreadconfig6 --file kdeglobals --group General --key TerminalApplication 2>/dev/null || true)"
  if [[ "$CUR" == "kitty" ]]; then
    info "kitty is already KDE's default terminal"
  elif ask_yes_no "Make kitty the default terminal in KDE?" y; then
    kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
    kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop
    ok "KDE default terminal → kitty"
  fi
fi

# Ctrl+Alt+T — Konsole claims it via X-KDE-Shortcuts in its .desktop file, so move
# it to kitty. Config is persisted in kglobalshortcutsrc; the D-Bus calls make it
# live right away (the shortcut daemon lives inside kwin_wayland on Plasma 6).
if need_cmd kwriteconfig6 && [[ "$(kreadconfig6 --file kdeglobals --group General --key TerminalApplication 2>/dev/null)" == "kitty" ]]; then
  if [[ "$(kreadconfig6 --file kglobalshortcutsrc --group 'services' --group 'kitty.desktop' --key _launch 2>/dev/null)" == "Ctrl+Alt+T" ]]; then
    info "Ctrl+Alt+T already opens kitty"
  else
    kwriteconfig6 --file kglobalshortcutsrc --group services --group kitty.desktop --key _launch "Ctrl+Alt+T"
    kwriteconfig6 --file kglobalshortcutsrc --group services --group org.kde.konsole.desktop --key _launch none
    if need_cmd gdbus; then
      KGA=(gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel --method org.kde.KGlobalAccel)
      "${KGA[@]}".doRegister "['kitty.desktop','_launch','kitty','kitty']" >/dev/null 2>&1 || true
      "${KGA[@]}".setShortcut "['kitty.desktop','_launch','kitty','kitty']" "[201326676]" 6 >/dev/null 2>&1 || true   # 201326676 = Ctrl+Alt+T
      "${KGA[@]}".setForeignShortcut "['org.kde.konsole.desktop','_launch','','']" "[]" >/dev/null 2>&1 || true
    fi
    ok "Ctrl+Alt+T → kitty (was Konsole)"
  fi
fi

# xdg-terminal-exec (used by some non-KDE apps to pick "the" terminal)
XDG_TERMS="$HOME/.config/xdg-terminals.list"
if ! grep -qxF "kitty.desktop" "$XDG_TERMS" 2>/dev/null; then
  { echo "kitty.desktop"; grep -vxF "kitty.desktop" "$XDG_TERMS" 2>/dev/null || true; } > "$XDG_TERMS.tmp"
  mv "$XDG_TERMS.tmp" "$XDG_TERMS"
  ok "xdg-terminals.list → kitty first"
fi

# Start in $HOME when launched from the app menu / Ctrl+Alt+T.
# A local kitty.desktop shadows /usr/share/applications/kitty.desktop; the Path=
# key is the working directory KDE launches it with. Dolphin's "Open Terminal
# Here" sets its own working directory, so that keeps working.
DESK="$HOME/.local/share/applications/kitty.desktop"
mkdir -p "$(dirname "$DESK")"
if grep -qsF "Path=$HOME" "$DESK" && grep -qs 'X-Shellscape' "$DESK"; then
  info "kitty.desktop already starts in $HOME"
else
  sed -e "/^Path=/d" -e "/^X-Shellscape/d" -e "s|^\[Desktop Entry\]|[Desktop Entry]\nX-Shellscape=true\nPath=$HOME|" \
      /usr/share/applications/kitty.desktop > "$DESK"
  need_cmd update-desktop-database && update-desktop-database "$(dirname "$DESK")" 2>/dev/null || true
  ok "kitty.desktop → new windows start in $HOME"
fi
