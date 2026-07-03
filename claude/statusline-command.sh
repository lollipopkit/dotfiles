#!/bin/sh
# Claude Code status line — hydro-style prompt rebuilt in pure sh.
# We do NOT call "fish -c 'fish_prompt'" because:
#  1. config.fish sources conda + orbstack init scripts (very slow / may hang)
#  2. hydro's internal variables ($__hydro_*) are absent in a one-shot fish -c
#  3. non-interactive fish may not lazy-load the fish_prompt function at all
# Instead we reconstruct the same visual elements using fast shell commands.

input=$(cat)

# --- hydro-style prompt parts ---
# pwd: use cwd from JSON input (avoids running pwd in a potentially wrong dir)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
# Abbreviate home directory to ~
home="$HOME"
case "$cwd" in
  "$home"*) cwd="~${cwd#$home}" ;;
esac

# git branch + dirty flag (hydro shows "branch!" when dirty)
git_part=""
# Use the cwd field from JSON for git; fall back to actual cwd
actual_cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty')
if [ -z "$actual_cwd" ]; then actual_cwd=$(pwd); fi
git_branch=$(git -C "$actual_cwd" symbolic-ref --short HEAD 2>/dev/null)
if [ -n "$git_branch" ]; then
  git_dirty=$(git -C "$actual_cwd" status --porcelain 2>/dev/null)
  if [ -n "$git_dirty" ]; then
    git_part="${git_branch}!"
  else
    git_part="$git_branch"
  fi
fi

# --- rate limit quota ---
five_used=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_used=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Colors — match hydro's default palette as closely as possible.
# hydro uses: pwd=blue(#5b9bd5-ish), branch=green(#78c2a4), dirty=yellow
# In 256-color: blue≈74, green≈72/79, yellow≈221, gray≈109, amber≈215
blue='\033[38;5;74m'
green='\033[38;5;79m'
yellow='\033[38;5;221m'
gray='\033[38;5;109m'
amber='\033[38;5;215m'
dim='\033[2m'
reset='\033[0m'

quota_parts=""

# Format unix epoch into a human-readable countdown: "4h", "45m", "30s", or "now"
_fmt_remaining() {
  resets_at="$1"
  [ -z "$resets_at" ] && return
  now=$(date +%s)
  diff=$((resets_at - now))
  [ "$diff" -le 0 ] && printf "now" && return
  h=$((diff / 3600))
  m=$(((diff % 3600) / 60))
  s=$((diff % 60))
  d=$((diff / 86400))
  if [ "$d" -gt 0 ]; then
    printf "%dd" "$d"
  elif [ "$h" -gt 0 ]; then
    printf "%dh" "$h"
  else
    printf "%dm" "$m"
  fi
}

_append_quota() {
  used="$1"; resets_at="$2"
  [ -z "$used" ] && return
  countdown=$(_fmt_remaining "$resets_at")
  rem=$(awk "BEGIN { printf \"%.0f\", 100 - $used }")
  color="$gray"
  [ "$(awk "BEGIN { print ($used > 70) ? 1 : 0 }")" = "1" ] && color="$amber"
  if [ -n "$countdown" ]; then
    part="${color}${rem}%${reset}${dim} ${countdown}${reset}"
  else
    part="${color}${rem}%${reset}"
  fi
  if [ -z "$quota_parts" ]; then
    quota_parts="$part"
  else
    quota_parts="${quota_parts}${dim} · ${reset}${part}"
  fi
}

_append_quota "$five_used" "$five_resets"
_append_quota "$week_used" "$week_resets"

# --- assemble final line ---
# hydro layout: <pwd>  <branch[!]>  [quota]
# pwd in blue, branch in green (dirty marker in yellow)
prompt_pwd="${blue}${cwd}${reset}"

prompt_git=""
if [ -n "$git_part" ]; then
  # Split branch and dirty marker for separate coloring
  branch_name="${git_part%!}"
  if [ "$git_part" != "$branch_name" ]; then
    # dirty
    prompt_git="  ${green}${branch_name}${yellow}!${reset}"
  else
    prompt_git="  ${green}${branch_name}${reset}"
  fi
fi

if [ -n "$quota_parts" ]; then
  printf "%b" "${prompt_pwd}${prompt_git}  ${dim}[${reset}${quota_parts}${dim}]${reset}"
else
  printf "%b" "${prompt_pwd}${prompt_git}"
fi
