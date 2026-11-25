#!/usr/bin/env bash
# desc: Shellscape CLI — `shellscape` command: Material You schemes, wallpapers, screenshots, recording, clipboard, emoji
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
# Source: desktop/cli (rebranded caelestia-cli, see desktop/UPSTREAM).

install_pkgs git gcc-c++ python3 python3-devel python3-pip python3-build python3-installer python3-hatchling python3-hatch-vcs

CLI="$DESKTOP_DIR/cli"
OUT="$BUILD_DIR/cli-dist"
# desktop/cli has no .git of its own, so pin the version hatch-vcs would read.
VER="0.0.0+$(awk '/caelestia-fedora-cli /{print $2}' "$DESKTOP_DIR/UPSTREAM")"
rm -rf "$OUT"
run_logged "Building ${YELLOW}shellscape-cli${RESET} wheel" \
  env SETUPTOOLS_SCM_PRETEND_VERSION="$VER" python3 -m build --wheel --no-isolation --outdir "$OUT" "$CLI" \
  || die "Wheel build failed"
WHEEL="$(ls "$OUT"/*.whl)"

# System-wide so Hyprland/Quickshell (which don't read ~/.local/bin) can run it.
run_logged "Installing ${YELLOW}$(basename "$WHEEL")${RESET}" \
  sudo -n python3 -m pip install --upgrade --force-reinstall --break-system-packages "$WHEEL" \
  || die "pip install failed"
sudo -n install -Dm644 "$CLI/completions/shellscape.fish" /usr/share/fish/vendor_completions.d/shellscape.fish

need_cmd shellscape && python3 -c 'import materialyoucolor' 2>/dev/null \
  && ok "shellscape CLI → $(command -v shellscape)" || die "shellscape CLI not usable after install"
