#!/usr/bin/env bash
# desc: Preflight — checks Fedora/sudo/internet, installs git curl unzip, creates dirs
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

# Fedora?
[[ -r /etc/os-release ]] && . /etc/os-release
[[ "${ID:-}" == "fedora" ]] || die "This installer targets Fedora (detected: ${PRETTY_NAME:-unknown})."
ok "Fedora ${VERSION_ID:-?} detected"

[[ $EUID -ne 0 ]] || die "Do not run as root."
need_cmd dnf || die "dnf not found."

# Internet
if curl -fsI --max-time 10 https://github.com -o /dev/null; then
  ok "Internet connection OK"
else
  die "No internet connection (cannot reach github.com)."
fi

# Base tools every later module needs
install_pkgs git curl unzip tar

# Directories
mkdir -p "$HOME/.config" "$HOME/.local/share/fonts" "$HOME/.local/bin"
ok "Created ~/.config ~/.local/share/fonts ~/.local/bin"

run_logged "Refreshing dnf metadata" sudo -n dnf -q makecache || warn "dnf makecache failed (continuing)"
