#!/bin/sh
# Antigravity CLI (agy) status line — hydro-style prompt rebuilt in pure sh.

[ -d /opt/homebrew/bin ] && PATH="/opt/homebrew/bin:$PATH"
[ -d /usr/local/bin ] && PATH="/usr/local/bin:$PATH"
export PATH

input=$(cat)

# Single jq pass: first 6 lines are scalar fields, remaining lines are quota rows.
parsed=$(printf '%s' "$input" | jq -r '
  (.workspace.current_dir // .cwd // ""),
  (.vcs.branch // ""),
  (if ((.vcs.dirty == true) or ((.vcs.dirty | type) == "string" and (.vcs.dirty | length) > 0)) then "1" else "" end),
  (.model.display_name // .model.id // ""),
  (.model.effort // ""),
  ((.context_window.used_percentage | numbers) // "" | tostring),
  (
    (.quotas // .quota // {})
    | to_entries[]
    | select((.value | type) == "object" and ((.value.disabled // false) | not) and (.value.remaining_fraction != null))
    | "\(.value.remaining_fraction * 100)|\(if (.value.reset_in_seconds | type) == "number" then (.value.reset_in_seconds | tostring) else "" end)"
  )
' 2>/dev/null)

actual_cwd=""
vcs_branch=""
vcs_dirty=""
model_name=""
model_effort=""
ctx_used=""
quota_rows=""

line_idx=0
while IFS= read -r item; do
  line_idx=$((line_idx + 1))
  case "$line_idx" in
    1) actual_cwd="$item" ;;
    2) vcs_branch="$item" ;;
    3) vcs_dirty="$item" ;;
    4) model_name="$item" ;;
    5) model_effort="$item" ;;
    6) ctx_used="$item" ;;
    *)
      if [ -z "$quota_rows" ]; then
        quota_rows="$item"
      else
        quota_rows="${quota_rows}
${item}"
      fi
      ;;
  esac
done <<EOF
$parsed
EOF

# --- git / vcs branch + dirty flag ---
if [ -z "$vcs_branch" ]; then
  [ -z "$actual_cwd" ] && actual_cwd=$(pwd)
  vcs_branch=$(git -C "$actual_cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$vcs_branch" ]; then
    [ -n "$(git -C "$actual_cwd" status --porcelain 2>/dev/null)" ] && vcs_dirty="1"
  fi
fi

# --- model ---
if [ -n "$model_name" ]; then
  stripped=$(printf '%s' "$model_name" | sed -E 's/[[:space:]]*\([^()]*\)[[:space:]]*$//')
  [ -n "$stripped" ] && model_name="$stripped"
  [ -n "$model_effort" ] && model_name="${model_name} (${model_effort})"
fi

# Colors — match hydro's palette (256-color)
green='\033[38;5;79m'
yellow='\033[38;5;221m'
gray='\033[38;5;109m'
amber='\033[38;5;215m'
red='\033[38;5;203m'
purple='\033[38;5;140m'
dim='\033[2m'
reset='\033[0m'

# --- context window usage ---
ctx_part=""
if [ -n "$ctx_used" ]; then
  ctx_color="$gray"
  [ "$(awk "BEGIN { print ($ctx_used >= 70) ? 1 : 0 }")" = "1" ] && ctx_color="$amber"
  [ "$(awk "BEGIN { print ($ctx_used >= 90) ? 1 : 0 }")" = "1" ] && ctx_color="$red"
  ctx_part="${ctx_color}$(awk "BEGIN { printf \"%.0f\", $ctx_used }")%${reset}"
fi

model_part=""
[ -n "$model_name" ] && model_part="${purple}${model_name}${reset}"

_fmt_remaining() {
  diff="$1"
  [ -z "$diff" ] && return
  diff=$(awk "BEGIN { printf \"%.0f\", $diff }")
  [ "$diff" -le 0 ] && printf "now" && return
  d=$((diff / 86400))
  h=$((diff / 3600))
  m=$(((diff % 3600) / 60))
  if [ "$d" -gt 0 ]; then
    printf "%dd" "$d"
  elif [ "$h" -gt 0 ]; then
    printf "%dh" "$h"
  else
    printf "%dm" "$m"
  fi
}

quota_parts=""
if [ -n "$quota_rows" ]; then
  while IFS= read -r row; do
    [ -z "$row" ] && continue
    rem_raw=${row%%|*}
    reset_sec=${row#*|}
    [ -z "$rem_raw" ] && continue
    rem=$(awk "BEGIN { printf \"%.0f\", $rem_raw }")
    color="$gray"
    [ "$(awk "BEGIN { print ($rem_raw < 30) ? 1 : 0 }")" = "1" ] && color="$amber"
    [ "$(awk "BEGIN { print ($rem_raw <= 10) ? 1 : 0 }")" = "1" ] && color="$red"
    countdown=$(_fmt_remaining "$reset_sec")
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
  done <<EOF
$quota_rows
EOF
fi

# --- assemble final line ---
# hydro layout: <branch[!]>  [<model> · <ctx used%>]  [quota]
line=""
if [ -n "$vcs_branch" ]; then
  if [ -n "$vcs_dirty" ]; then
    line="${green}${vcs_branch}${yellow}!${reset}"
  else
    line="${green}${vcs_branch}${reset}"
  fi
fi

model_ctx="$model_part"
if [ -n "$ctx_part" ]; then
  if [ -n "$model_ctx" ]; then
    model_ctx="${model_ctx}${dim} · ${reset}${ctx_part}"
  else
    model_ctx="$ctx_part"
  fi
fi

_append_bracket() {
  [ -z "$1" ] && return
  [ -n "$line" ] && line="${line}  "
  line="${line}${dim}[${reset}$1${dim}]${reset}"
}

_append_bracket "$model_ctx"
_append_bracket "$quota_parts"
printf "%b" "$line"
