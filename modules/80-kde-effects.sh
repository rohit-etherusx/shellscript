#!/usr/bin/env bash
# desc: KDE effects — window animations (glide, wobbly, magic lamp), blur + translucency for terminals
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
# Plasma's counterpart to the Hyprland animations/blur in Arch-Hyprland.

if ! need_cmd kwriteconfig6; then
  info "kwriteconfig6 not found (not KDE Plasma?). Skipping..."
  exit 0
fi

ask_yes_no "Enable KDE window animations (glide open/close, wobbly windows, magic lamp minimize, blur)?" y \
  || { note "Skipped KDE effects."; exit 0; }

# kwinrc [Plugins] <effect id>Enabled — ids as listed by
#   gdbus call --session --dest org.kde.KWin --object-path /Effects \
#     --method org.freedesktop.DBus.Properties.Get org.kde.kwin.Effects listOfEffects
# (Plasma 6 ids have no kwin4_effect_ prefix; "contrast" is now part of blur.)
declare -A EFFECTS=(
  [glide]=true           # windows glide in/out on open/close
  [scale]=false          #   (default open/close effect — only one may be on)
  [fade]=false
  [wobblywindows]=true   # jelly windows while dragging
  [magiclamp]=true       # genie minimize to the taskbar
  [squash]=false         #   (default minimize effect)
  [blur]=true            # blur behind translucent windows (kitty uses it)
  [translucency]=true    # windows go translucent while moved/resized
  [slide]=true           # slide between virtual desktops
  [dialogparent]=true    # dim parent when a dialog is open
)
changed=0
for id in "${!EFFECTS[@]}"; do
  want="${EFFECTS[$id]}"
  cur="$(kreadconfig6 --file kwinrc --group Plugins --key "${id}Enabled" 2>/dev/null || true)"
  [[ "$cur" == "$want" ]] && continue
  kwriteconfig6 --file kwinrc --group Plugins --key "${id}Enabled" --type bool "$want"
  changed=1
done

# Slightly springier wobble + stronger blur than stock
kwriteconfig6 --file kwinrc --group Effect-wobblywindows --key WobblynessLevel 2
kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 10
kwriteconfig6 --file kwinrc --group Effect-blur --key NoiseStrength 3
kwriteconfig6 --file kwinrc --group Effect-glide --key Duration 220

# Ptyxis: a touch of translucency (kitty already has background_opacity + blur in kitty.conf)
if need_cmd ptyxis && need_cmd gsettings; then
  for uuid in $(gsettings get org.gnome.Ptyxis profile-uuids | tr -d "[]',"); do
    gsettings set "org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$uuid/" opacity 0.92
  done
  ok "Ptyxis opacity → 92 %"
fi

# Apply live: KWin's "reconfigure" re-reads effect settings but does NOT load or
# unload effects, so toggle each one over D-Bus as well (no logout needed).
if need_cmd gdbus && gdbus call --session --dest org.kde.KWin --object-path /KWin --method org.kde.KWin.reconfigure >/dev/null 2>&1; then
  for id in "${!EFFECTS[@]}"; do
    if [[ "${EFFECTS[$id]}" == true ]]; then method=loadEffect; else method=unloadEffect; fi
    gdbus call --session --dest org.kde.KWin --object-path /Effects --method "org.kde.kwin.Effects.$method" "$id" >/dev/null 2>&1 || true
  done
  ok "KWin reconfigured — effects are live"
else
  note "Could not reach KWin over D-Bus; effects apply at next login"
fi
[[ $changed == 1 ]] && ok "KDE effects enabled: glide, wobbly windows, magic lamp, blur, translucency" || info "KDE effects were already configured"
note "Tweak them in System Settings → Window Management → Desktop Effects."
