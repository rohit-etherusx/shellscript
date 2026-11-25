#!/usr/bin/env bash
# desc: Browser — Shellscape userChrome for Firefox / Zen + native host so the CaelestiaFox add-on follows the scheme
# optional
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

install_pkgs fish jq inotify-tools

# chrome_into <profile dir> <userChrome.css>  → link CSS + enable legacy stylesheets once
chrome_into() {
  link_dotfile "$2" "$1/chrome/userChrome.css"
  grep -qs 'legacyUserProfileCustomizations' "$1/user.js" \
    || echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >>"$1/user.js"
}
found=0
for p in "$HOME"/.mozilla/firefox/*.default*/; do
  [[ -d "$p" ]] && { chrome_into "${p%/}" "$CONFIG_DIR/firefox/userChrome.css"; found=1; }
done
# Zen (Flatpak or native)
for p in "$HOME"/.var/app/app.zen_browser.zen/.zen/*.Default*/ "$HOME"/.zen/*.Default*/; do
  [[ -d "$p" ]] && { chrome_into "${p%/}" "$CONFIG_DIR/zen/userChrome.css"; found=1; }
done
[[ $found == 1 ]] || warn "No Firefox/Zen profile found — start the browser once, then re-run: ./install.sh --only browser"

# Native-messaging host. The id stays "caelestiafox" because the published add-on looks for it by name.
LIBD="$HOME/.local/lib/shellscape"
link_dotfile "$CONFIG_DIR/zen/native_app/app.fish" "$LIBD/caelestiafox"
mkdir -p "$HOME/.mozilla/native-messaging-hosts"
sed "s|{{ \$lib }}|$LIBD|g" "$CONFIG_DIR/zen/native_app/manifest.json" >"$HOME/.mozilla/native-messaging-hosts/caelestiafox.json"
ok "Native host installed. Add the add-on: https://addons.mozilla.org/en-US/firefox/addon/caelestiafox"
note "Flatpak browsers cannot launch native hosts without extra sandbox holes; colours sync only in the RPM Firefox."
