#!/bin/sh
# Status line based on robbyrussell Oh My Zsh theme
# with model name, context usage, and estimated session cost

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
dir=$(basename "$cwd")

# Git info
git_branch=""
git_dirty=""
if git_output=$(git -C "$cwd" -c core.fsmonitor= symbolic-ref --short HEAD 2>/dev/null); then
  git_branch="$git_output"
  if [ -n "$(git -C "$cwd" -c core.fsmonitor= status --porcelain 2>/dev/null)" ]; then
    git_dirty=" ✗"
  fi
fi

# ANSI colors
bold_green="\033[1;32m"
bold_red="\033[1;31m"
cyan="\033[0;36m"
bold_blue="\033[1;34m"
red="\033[0;31m"
blue="\033[0;34m"
yellow="\033[0;33m"
magenta="\033[0;35m"
bold_magenta="\033[1;35m"
white="\033[0;37m"
reset="\033[0m"

# Model info
model_display=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
model_id=$(echo "$input" | jq -r '.model.id // ""')

# Context window usage
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
# Derive real context consumed from percentage (matches /context command output)
if [ -n "$used_pct" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
  total_consumed=$(echo "$used_pct $ctx_size" | awk '{printf "%d", ($1/100)*$2}')
else
  total_consumed=$((total_input + total_output))
fi

# Format context token counts (e.g. 5100 -> 5.1k, 5074000 -> 5.1M)
format_tokens() {
  val="$1"
  if [ -z "$val" ] || [ "$val" = "0" ]; then
    echo "0"
  elif [ "$val" -ge 1000000 ] 2>/dev/null; then
    echo "$val" | awk '{printf "%.1fM", $1/1000000}'
  elif [ "$val" -ge 1000 ] 2>/dev/null; then
    echo "$val" | awk '{printf "%.1fk", $1/1000}'
  else
    echo "$val"
  fi
}

ctx_used_fmt=$(format_tokens "$total_consumed")
ctx_total_fmt=$(format_tokens "$ctx_size")

ctx_info="${ctx_used_fmt}/${ctx_total_fmt}"
if [ -n "$used_pct" ]; then
  used_pct_int=$(printf "%.0f" "$used_pct")
  ctx_info="${ctx_info} (${used_pct_int}%)"
fi

# Estimated session cost
# Pricing per million tokens (approximate, as of early 2025):
#   claude-opus-4*       input $15/M   output $75/M
#   claude-sonnet-4*     input $3/M    output $15/M
#   claude-haiku-4*      input $0.80/M output $4/M
#   claude-3-7-sonnet*   input $3/M    output $15/M
#   claude-3-5-sonnet*   input $3/M    output $15/M
#   claude-3-5-haiku*    input $0.80/M output $4/M
#   claude-3-opus*       input $15/M   output $75/M
#   claude-3-haiku*      input $0.25/M output $1.25/M
#   fallback             input $3/M    output $15/M

cost=$(echo "$model_id $total_input $total_output" | awk '{
  model=$1; inp=$2; out=$3
  in_rate=3; out_rate=15
  if (model ~ /opus-4/ || model ~ /claude-3-opus/) { in_rate=15; out_rate=75 }
  else if (model ~ /haiku-4/)                       { in_rate=0.80; out_rate=4 }
  else if (model ~ /claude-3-5-haiku/)              { in_rate=0.80; out_rate=4 }
  else if (model ~ /claude-3-haiku/)                { in_rate=0.25; out_rate=1.25 }
  total = (inp * in_rate + out * out_rate) / 1000000
  if (total < 0.01) printf "$0.00"
  else if (total < 1) printf "$%.3f", total
  else printf "$%.2f", total
}')

# Build the prompt section
if [ -n "$git_branch" ]; then
  prompt_part=$(printf "${bold_green}➜${reset} ${cyan}%s${reset} ${bold_blue}git:(${red}%s${blue})${reset}${yellow}%s${reset}" \
    "$dir" "$git_branch" "$git_dirty")
else
  prompt_part=$(printf "${bold_green}➜${reset} ${cyan}%s${reset}" "$dir")
fi

# Claude Code mode
mode_label=""
plan_mode=$(echo "$input" | jq -r '.plan_mode // false')
auto_accept=$(echo "$input" | jq -r '.auto_accept // false')
if [ "$plan_mode" = "true" ]; then
  mode_label=$(printf " ${white}[${bold_blue}PLAN${white}]${reset}")
elif [ "$auto_accept" = "true" ]; then
  mode_label=$(printf " ${white}[${bold_red}AUTO${white}]${reset}")
fi

# Build the info section
info_part=$(printf "${white}[${bold_magenta}%s${white}]${reset} ${white}ctx:${cyan}%s${reset} ${white}cost:${yellow}%s${reset}%s" \
  "$model_display" "$ctx_info" "$cost" "$mode_label")

printf "%s  %s" "$prompt_part" "$info_part"
