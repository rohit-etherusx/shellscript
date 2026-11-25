#!/usr/bin/env bash
# Self-check for install.sh module selection (--skip / --only / --with, "# optional" modules).
cd "$(dirname "$0")/.." && SHELLSCAPE_DIR=$PWD
eval "$(sed -n '/^module_desc()/,/^# ── Banner/p' install.sh | sed '$d')"
fail=0
t() { SKIP=(); ONLY=(); WITH=(); eval "$1"; r=$(selected "$2" && echo run || echo skip)
      [[ $r == "$3" ]] || { echo "FAIL [$1] $2 → $r (want $3)"; fail=1; }; }
t ""                    90-hyprland.sh run
t ""                    95-vscode.sh   skip
t "WITH=(vscode)"       95-vscode.sh   run
t "WITH=(vscode)"       96-browser.sh  skip
t "ONLY=(browser)"      96-browser.sh  run
t "ONLY=(browser)"      30-zsh.sh      skip
t "SKIP=(zsh)"          30-zsh.sh      skip
t "SKIP=(95) WITH=(95)" 95-vscode.sh   skip
[[ $fail == 0 ]] && echo "selection: all ok"; exit $fail
