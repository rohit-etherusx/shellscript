#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  Shellscape — Fedora terminal ricing installer
#
#  Usage:  ./install.sh [options]
#    -y, --yes          answer yes to every prompt (unattended)
#        --skip NAME    skip a module (repeatable). NAME = "30-zsh", "zsh" or "30"
#        --only NAME    run only these modules (repeatable)
#    -l, --list         list modules and exit
#    -h, --help         this help
#
#  Modules live in modules/NN-name.sh and run in numeric order. Each one is
#  idempotent: re-running install.sh is safe and only does what's missing.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SHELLSCAPE_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
export SHELLSCAPE_DIR
# shellcheck source=lib/common.sh
source "$SHELLSCAPE_DIR/lib/common.sh"

usage() { sed -n '3,14p' "$0" | sed -e 's/^#  \{0,1\}//' -e 's/^#$//'; }

# ── Args ──────────────────────────────────────────────────────────────────────
SKIP=(); ONLY=(); LIST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes)  ASSUME_YES=1 ;;
    --skip)    [[ $# -ge 2 ]] || die "--skip needs a module name"; SKIP+=("$2"); shift ;;
    --only)    [[ $# -ge 2 ]] || die "--only needs a module name"; ONLY+=("$2"); shift ;;
    -l|--list) LIST=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1 (try --help)" ;;
  esac
  shift
done
export ASSUME_YES

# ── Module discovery ──────────────────────────────────────────────────────────
mapfile -t MODULES < <(find "$SHELLSCAPE_DIR/modules" -maxdepth 1 -name '[0-9][0-9]-*.sh' -printf '%f\n' | sort)
[[ ${#MODULES[@]} -gt 0 ]] || die "No modules found in $SHELLSCAPE_DIR/modules"

module_desc() { sed -n 's/^# desc: //p' "$SHELLSCAPE_DIR/modules/$1" | head -1; }

# matches <file> <name>: "30-zsh.sh" matches "30-zsh", "zsh" and "30"
matches() {
  local m=${1%.sh} n=$2
  [[ "$m" == "$n" || "${m#*-}" == "$n" || "${m%%-*}" == "$n" ]]
}
selected() {
  local m=$1 n
  for n in "${SKIP[@]}";  do matches "$m" "$n" && return 1; done
  [[ ${#ONLY[@]} -eq 0 ]] && return 0
  for n in "${ONLY[@]}";  do matches "$m" "$n" && return 0; done
  return 1
}

# ── Banner ────────────────────────────────────────────────────────────────────
printf '%s' "${BOLD}${CYAN}"
cat <<'BANNER'
   _____ __         ____
  / ___// /_  ___  / / /_____________ _____  ___
  \__ \/ __ \/ _ \/ / / ___/ ___/ __ `/ __ \/ _ \
 ___/ / / / /  __/ / (__  ) /__/ /_/ / /_/ /  __/
/____/_/ /_/\___/_/_/____/\___/\__,_/ .___/\___/
                                   /_/   Fedora terminal ricing
BANNER
printf '%s\n' "$RESET"

if [[ $LIST == 1 ]]; then
  for m in "${MODULES[@]}"; do printf '  %-18s %s\n' "${m%.sh}" "$(module_desc "$m")"; done
  exit 0
fi

info "Project dir : $SHELLSCAPE_DIR"
info "Log file    : $LOG"
echo
echo "Modules to run:"
for m in "${MODULES[@]}"; do
  if selected "$m"; then printf '  %s %-18s %s\n' "${GREEN}✔${RESET}" "${m%.sh}" "$(module_desc "$m")"
  else                   printf '  %s %-18s %s\n' "${YELLOW}–${RESET}" "${m%.sh}" "(skipped)"; fi
done
echo
ask_yes_no "Start the installation?" y || { note "Aborted."; exit 0; }

# ── sudo: ask once, keep alive for the whole run ──────────────────────────────
[[ $EUID -ne 0 ]] || die "Run install.sh as your normal user, not as root (it will call sudo when needed)."
need_cmd sudo || die "sudo is required."
echo "${ACTION} sudo is needed for dnf. Enter your password once:"
sudo -v || die "sudo authentication failed."
( while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE=$!
trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT

# ── Run modules ───────────────────────────────────────────────────────────────
declare -A RESULT
for m in "${MODULES[@]}"; do
  if ! selected "$m"; then RESULT[$m]="SKIPPED"; continue; fi
  section "${m%.sh} — $(module_desc "$m")"
  if bash "$SHELLSCAPE_DIR/modules/$m"; then
    RESULT[$m]="OK"
  else
    RESULT[$m]="FAILED"
    error "Module ${m%.sh} failed — see $LOG"
    if [[ "$m" == 00-* ]]; then die "Preflight failed; aborting."; fi
  fi
done

# ── Summary ───────────────────────────────────────────────────────────────────
section "Summary"
FAILED=0
for m in "${MODULES[@]}"; do
  case "${RESULT[$m]}" in
    OK)      printf '  %s  %s\n' "${GREEN}OK     ${RESET}" "${m%.sh}" ;;
    SKIPPED) printf '  %s  %s\n' "${YELLOW}SKIPPED${RESET}" "${m%.sh}" ;;
    *)       printf '  %s  %s\n' "${RED}FAILED ${RESET}" "${m%.sh}"; FAILED=1 ;;
  esac
done
echo
if [[ $FAILED == 1 ]]; then
  warn "Some modules failed. Check ${LOG} and re-run ./install.sh — it only redoes what's missing."
else
  ok "Shellscape installed successfully!"
fi

cat <<WALK

${BOLD}Next steps${RESET}
  1. Log out and back in (or run ${CYAN}exec zsh${RESET}) so zsh becomes your shell.
  2. Open ${CYAN}kitty${RESET} — the agnosterzak prompt needs the Nerd Font kitty is configured with.
  3. Try:  ${CYAN}ls${RESET} (eza icons)  ${CYAN}Ctrl-R${RESET} (fzf history)  ${CYAN}z <dir>${RESET} (zoxide)
           ${CYAN}fastfetch${RESET}  ${CYAN}pokemon-colorscripts -r${RESET}  ${CYAN}tmux${RESET} (prefix is Ctrl-a; prefix+I installs plugins)
  4. Edit configs in ${CYAN}$SHELLSCAPE_DIR/config/${RESET} — they are symlinked, changes apply immediately.
  5. Change the startup banner:  SHELLSCAPE_BANNER= fastfetch | pokemon | none  in config/zsh/.zshrc
  Undo everything with ${CYAN}./uninstall.sh${RESET}.
WALK
