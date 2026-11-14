# vim:ft=zsh ts=2 sw=2 sts=2
#
# Shellscape theme — agnosterzak's layout with rounded "pill" segments and a
# Catppuccin Mocha palette. Needs a Nerd Font (install.sh installs JetBrainsMono).
#
#  ✘  Mon  9 Nov - 19:32  ~/projects/linux-ricing/Shellscape   main ✔
#  @rohit  ❯

### Palette (Catppuccin Mocha) — terminal must support truecolor (kitty/ptyxis do)
typeset -gA SS
SS=(
  base     '#1e1e2e'  crust    '#11111b'  surface  '#45475a'  overlay  '#585b70'
  text     '#cdd6f4'  subtext  '#a6adc8'
  blue     '#89b4fa'  mauve    '#cba6f7'  green    '#a6e3a1'  yellow   '#f9e2af'
  red      '#f38ba8'  peach    '#fab387'  teal     '#94e2d5'  sky      '#89dceb'
)

### Glyphs
SS_LEFT=""     #  left half-circle   (Nerd Font / powerline-extra)
SS_RIGHT=""    #  right half-circle
SS_BRANCH=""   # 
SS_CROSS="✘"    # ✘
SS_BOLT="⚡"     # ⚡
SS_GEAR="⚙"     # ⚙

CURRENT_BG='NONE'

# prompt_segment <bg> <fg> [text]
#   First segment on a line gets a rounded left cap; following segments are
#   joined with a rounded right cap drawn in the previous colour.
prompt_segment() {
  local bg="$1" fg="$2"
  if [[ $CURRENT_BG == 'NONE' ]]; then
    print -n "%{%k%F{$bg}%}$SS_LEFT%{%K{$bg}%F{$fg}%}"
  elif [[ $bg != $CURRENT_BG ]]; then
    print -n "%{%K{$bg}%F{$CURRENT_BG}%}$SS_RIGHT%{%F{$fg}%} "
  else
    print -n "%{%K{$bg}%F{$fg}%} "
  fi
  CURRENT_BG=$bg
  [[ -n $3 ]] && print -n "$3"
}

# Close the open segment with a rounded right cap.
prompt_end() {
  if [[ $CURRENT_BG != 'NONE' ]]; then
    print -n "%{%k%F{$CURRENT_BG}%}$SS_RIGHT"
  fi
  print -n "%{%k%f%b%}"
  CURRENT_BG='NONE'
}

### Segments

# Status: last command failed / running as root / background jobs
prompt_status() {
  local -a symbols
  [[ $RETVAL -ne 0 ]]              && symbols+="%F{$SS[red]}$SS_CROSS"
  [[ $UID -eq 0 ]]                 && symbols+="%F{$SS[yellow]}$SS_BOLT"
  [[ $(jobs -l | wc -l) -gt 0 ]]   && symbols+="%F{$SS[sky]}$SS_GEAR"
  [[ -n "$symbols" ]] && prompt_segment "$SS[surface]" "$SS[text]" "${(j: :)symbols}"
}

prompt_time() {
  prompt_segment "$SS[overlay]" "$SS[text]" "%B%D{%a %e %b - %H:%M}%b"
}

prompt_dir() {
  prompt_segment "$SS[blue]" "$SS[crust]" "%B%~%b"
}

prompt_virtualenv() {
  [[ -n $VIRTUAL_ENV && -n $VIRTUAL_ENV_DISABLE_PROMPT ]] || return
  prompt_segment "$SS[teal]" "$SS[crust]" "($(basename "$VIRTUAL_ENV"))"
}

prompt_context() {
  if [[ -n "$SSH_CLIENT" ]]; then
    prompt_segment "$SS[peach]" "$SS[crust]" "%B$USER@%m%b"
  else
    prompt_segment "$SS[mauve]" "$SS[crust]" "%B@$USER%b"
  fi
}

# Git: branch, ahead/behind, and a compact status summary
prompt_git() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  local ref bg="$SS[green]" fg="$SS[crust]" st
  local status_lines ahead behind n

  ref=$(git symbolic-ref --short HEAD 2>/dev/null) || ref="➦ $(git rev-parse --short HEAD 2>/dev/null)"
  status_lines=$(git status --porcelain 2>/dev/null)

  if [[ -n $status_lines ]]; then
    bg="$SS[yellow]"
    n=$(grep -c '^??'  <<<"$status_lines"); (( n > 0 )) && st+=" ${n}?"
    n=$(grep -c '^.M'  <<<"$status_lines"); (( n > 0 )) && { st+=" ${n}●"; bg="$SS[red]"; }
    n=$(grep -c '^.D'  <<<"$status_lines"); (( n > 0 )) && { st+=" ${n}✖"; bg="$SS[red]"; }
    n=$(grep -c '^[MADR]' <<<"$status_lines"); (( n > 0 )) && st+=" ${n}✚"
  else
    st=" ✔"
  fi

  if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    ahead=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)
    behind=$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null)
    (( ahead  > 0 )) && st+=" ↑$ahead"
    (( behind > 0 )) && st+=" ↓$behind"
  fi

  local repo_path; repo_path=$(git rev-parse --git-dir 2>/dev/null)
  local mode=''
  if   [[ -e "$repo_path/BISECT_LOG" ]]; then mode=' <B>'
  elif [[ -e "$repo_path/MERGE_HEAD" ]]; then mode=' >M<'
  elif [[ -e "$repo_path/rebase" || -e "$repo_path/rebase-apply" || -e "$repo_path/rebase-merge" ]]; then mode=' >R>'
  fi

  prompt_segment "$bg" "$fg" "%B$SS_BRANCH $ref%b$mode$st"
}

### Main prompt
build_prompt() {
  RETVAL=$?
  print -n "\n"
  prompt_status
  prompt_time
  prompt_virtualenv
  prompt_dir
  prompt_git
  prompt_end
  print -n "\n"
  prompt_context
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
