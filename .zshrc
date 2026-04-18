# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH


#line added after looking on stackoverflow
export PATH=/opt/homebrew/bin:$PATH
export PATH="/opt/homebrew/sbin:$PATH"


#line for jenv
# export PATH="$HOME/.jenv/bin:$PATH"
# eval "$(jenv init -)"


#line for OpenSSL
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

# line for maven-jenkins-tomcat


# line added for jenkins change of directory
# export JENKINS_HOME = /Users/herschelmenezes/Herschel/.jenkins


# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git 
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Claude Code Model Configuration
# Use Opus 4.7 for OpusPlan mode and Sonnet 4.6 as default
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-7"
export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-4-6"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias python=/opt/homebrew/bin/python3 	#error bcoz it doesnt use the homebrew version 

# To set up shell integration for fzf, add this to your shell configuration file:
source <(fzf --zsh)


export PATH="/opt/homebrew/opt/conan@1/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# For rust compiler
source "$HOME/.cargo/env"

# # alias nvim-kick="NVIM_APPNAME=kickstart nvim"
# alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
#
#
# function nvims() {
#   local nv_items=("Default" "AstroVim")
#   local nv_app=$(printf "%s\n" "${nv_items[@]}" | fzf --prompt=" Neovim Config 󰶻  " --height=~50% --layout=reverse --border --exit-0)
#
#   if [[ -z $nv_app ]]; then
#     echo "Nothing selected"
#     return 0
#   elif [[ $nv_app == "Default" ]]; then
#     nv_app=""
#   else
#     echo "Set $nvims_config to $nv_app"
#   fi
#
#   echo "$nv_app" > "$nvims_config"
#   alias vi="NVIM_APPNAME=${nv_app} nvim"
#
#   NVIM_APPNAME=$nv_app nvim $@
# }
#
# # nvims
# if [[ -x /usr/local/bin/nvim || -x /opt/homebrew/bin/nvim ]]; then
#   nvims_config="${XDG_CACHE_HOME:-$HOME/.cache}/nvims"
#   nvims_app=$(cat "$nvims_config")
#   #echo "Bind Neovim to $nvims_app"
#   alias vi="NVIM_APPNAME=${nvims_app} nvim"
#   export EDITOR="vi"
#   bindkey -s "^v" "nvims\n"
# fi


#Aliases for MongoDB
# alias start-mongod="brew services start mongodb/brew/mongodb-community"
# alias stop-mongod="brew services stop mongodb/brew/mongodb-community"

#Aliases for Git
#add here
alias git-c="git commit -m"

# Alias for Tomcat Server
# alias startup-tomcat="/Users/herschelmenezes/Applications/Tomcat/apache-tomcat-9.0.71/bin/startup.sh"
# alias shutdown-tomcat="/Users/herschelmenezes/Applications/Tomcat/apache-tomcat-9.0.71/bin/shutdown.sh"

# Alias for Jenkins
# alias restart-jenkins="brew services restart jenkins-lts"
# alias start-jenkins="brew services start jenkins-lts"
# alias stop-jenkins="brew services stop jenkins-lts"



alias ls='lsd'
alias ll='ls  -l'
alias la='ls -a'
alias lla='ls -la'

alias vv='nvim'

alias t='tmux'
alias td='tmux detach'
alias tname='tmux new -s'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias tkall='tmux kill-session -a'
alias tkt='tmux kill-session -t'

alias cd-epm='cd /Users/herschel.menezes/Projects/EPM/epm-f1e'
alias cd-epw='cd /Users/herschel.menezes/Projects/EPW/epw-f1e'
alias cd-mv3='cd "/Users/herschel.menezes/Projects/epx-v3/epx-v3-browser-extensions"'

alias powerdown="sudo pmset -a hibernatemode 25 && sudo pmset sleepnow"

alias powerup="sudo pmset -a hibernatemode 3"

alias deepsleep="sudo pmset -a hibernatemode 25 && sudo pmset -a standby 1 && sudo pmset -a standbydelayhigh 1 && sudo pmset -a standbydelaylow 1 && sudo pmset -a autopoweroff 1 && sudo pmset -a autopoweroffdelay 1 && echo 'Going to hibernate in 5 seconds...' && sleep 5 && sudo pmset sleepnow"

alias wakeup="sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 86400 standbydelaylow 10800 autopoweroff 1 autopoweroffdelay 28800 && echo 'Sleep settings restored to normal'"
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "/Users/herschel.menezes/.bun/_bun" ] && source "/Users/herschel.menezes/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias claude-mem='/Users/herschel.menezes/.bun/bin/bun "/Users/herschel.menezes/.claude/plugins/cache/thedotmack/claude-mem/10.6.3/scripts/worker-service.cjs"'

pr-comments() {
  local pr_number=${1:-445}
  local repo=${2:-epx-v3-browser-extensions}
  GH_HOST=github.cicd.cloud.fpdev.io gh api repos/ENDPT/$repo/pulls/$pr_number/comments --jq '.[] | "\n━━ Reviewer: \(.user.login | ascii_upcase) | Line: \(.original_line // "General")\(if .in_reply_to_id then " [REPLY]" else "" end)\n📄 \(.path)\n💬 \(.body | gsub("\n"; "\n   "))\n"' | cat
}


# ═══════════════════════════════════════════════════════════════
# JIRA CLI SETUP (go-jira)
# ═══════════════════════════════════════════════════════════════
# 1. Install: brew install go-jira
# 2. Create ~/.jira/config.yml with:
#    endpoint: https://forcepoint.atlassian.net
#    user: herschel.menezes@forcepoint.com
#    password: YOUR_API_TOKEN  (from https://id.atlassian.com/manage-profile/security/api-tokens)
# 3. Set permissions: chmod 600 ~/.jira/config.yml
# ═══════════════════════════════════════════════════════════════

export JIRA_API_TOKEN="REDACTED_ATLASSIAN_TOKEN"

jira-ticket() {
	local ticket=${1}

	if [[ -z "$ticket" ]]; then
		echo "Usage: jira-ticket ISSUE-123"
		return 1
	fi

	if ! command -v jira &> /dev/null; then
		echo "❌ go-jira not installed"
		return 1
	fi

	if [[ -z "$JIRA_API_TOKEN" ]]; then
		echo "❌ JIRA_API_TOKEN not set"
		return 1
	fi

	local endpoint="https://forcepoint.atlassian.net"
	local user="herschel.menezes@forcepoint.com"
	local json_file
	json_file=$(mktemp)

	# Fetch JSON
	if ! jira -e "$endpoint" -u "$user" view "$ticket" -t debug > "$json_file" 2>&1; then
		rm -f "$json_file"
		echo "❌ Failed to fetch: $ticket"
		return 1
	fi

	# Validate JSON
	if ! jq empty "$json_file" 2>/dev/null; then
		rm -f "$json_file"
		echo "❌ Invalid JSON from Jira"
		return 1
	fi

	# Generate markdown via Python reading the JSON file directly
	python3 - "$json_file" << 'SCRIPT'
import sys, json

with open(sys.argv[1]) as f:
	raw = json.load(f)

fields = raw.get('fields', {})
key = raw.get('key', '?')

def fmt_date(s):
	return s.split('T')[0] if s else '(not set)'

def get_names(items, field='name'):
	if not items: return '(none)'
	if isinstance(items, list): return ', '.join([i.get(field, i) if isinstance(i, dict) else str(i) for i in items])
	return '(none)'

# Header
print(f"# 🎫 {key} | {fields.get('issuetype', {}).get('name', '?')} | {fields.get('priority', {}).get('name', '?')}\n")
print(f"> **Status:** {fields.get('status', {}).get('name', '?')}\n")
print(f"> **Link:** https://forcepoint.atlassian.net/browse/{key}\n")

# Summary
print(f"## Summary\n\n{fields.get('summary', 'N/A')}\n")

# Metadata
print("## Metadata\n")
print("| Field | Value |")
print("|-------|-------|")

assignee = fields.get('assignee') or {}
reporter = fields.get('reporter') or {}

print(f"| **Assignee** | {assignee.get('displayName', 'Unassigned')} ({assignee.get('emailAddress', 'N/A')}) |")
print(f"| **Reporter** | {reporter.get('displayName', 'N/A')} ({reporter.get('emailAddress', 'N/A')}) |")
print(f"| **Component** | {get_names(fields.get('components', []))} |")
labels = ', '.join(fields.get('labels', [])) if fields.get('labels') else '(none)'
print(f"| **Labels** | {labels} |")
print(f"| **Created** | {fmt_date(fields.get('created', ''))} |")
print(f"| **Updated** | {fmt_date(fields.get('updated', ''))} |")
print(f"| **Due Date** | {fmt_date(fields.get('duedate', ''))} |")
print(f"| **Fix Version** | {get_names(fields.get('fixVersions', []))} |")
print(f"| **Affected Version** | {get_names(fields.get('versions', []))} |")
resolution = fields.get('resolution') or {}
print(f"| **Resolution** | {resolution.get('name', 'Unresolved')} |")
print()

# Description
if fields.get('description'):
	print(f"## Description\n\n{fields['description']}\n")

# Attachments
if fields.get('attachment'):
	print("## Attachments\n")
	for att in fields['attachment']:
		print(f"- **{att.get('filename', '?')}** ({att.get('size', 0) // 1024} KB) — {att.get('author', {}).get('displayName', '?')} on {fmt_date(att.get('created', ''))}")
	print()

# Linked Issues
if fields.get('issuelinks'):
	print("## Linked Issues\n")
	for link in fields['issuelinks']:
		issue = link.get('inwardIssue') or link.get('outwardIssue') or {}
		print(f"- {link.get('type', {}).get('name', '?')}: {issue.get('key', '?')} — {issue.get('fields', {}).get('summary', '?')}")
	print()
else:
	print("## Linked Issues\n\n(none)\n")

# Subtasks
if fields.get('subtasks'):
	print("## Subtasks\n")
	for sub in fields['subtasks']:
		print(f"- {sub.get('key', '?')} — {sub.get('fields', {}).get('summary', '?')} ({sub.get('fields', {}).get('status', {}).get('name', '?')})")
	print()

# Comments
comments = fields.get('comment', {}).get('comments', [])
if comments:
	print(f"## Comments ({len(comments)})\n")
	for cmt in comments:
		print(f"### {cmt.get('author', {}).get('displayName', '?')} — {fmt_date(cmt.get('created', ''))}\n")
		print(f"{cmt.get('body', '')}\n")
else:
	print("## Comments\n\n(none)\n")
SCRIPT

	# Transitions
	local transitions
	transitions=$(jira -e "$endpoint" -u "$user" transitions "$ticket" 2>&1)

	echo ""
	echo "## Available Transitions"
	echo ""
	echo "$transitions" | grep -v "^usage:" | grep -v "^jira" || echo "(none)"

	# Save to file
	# echo ""
	# echo "---"
	# echo "_Saved to: /tmp/${ticket}.md_"

	# # Regenerate for file save
	# python3 - "$json_file" << 'SCRIPT' > "/tmp/${ticket}.md"
	# import sys, json
	#
	# with open(sys.argv[1]) as f:
	# 	raw = json.load(f)
	#
	# fields = raw.get('fields', {})
	# key = raw.get('key', '?')
	#
	# def fmt_date(s):
	# 	return s.split('T')[0] if s else '(not set)'
	#
	# def get_names(items, field='name'):
	# 	if not items: return '(none)'
	# 	if isinstance(items, list): return ', '.join([i.get(field, i) if isinstance(i, dict) else str(i) for i in items])
	# 	return '(none)'
	#
	# print(f"# 🎫 {key} | {fields.get('issuetype', {}).get('name', '?')} | {fields.get('priority', {}).get('name', '?')}\n")
	# print(f"> **Status:** {fields.get('status', {}).get('name', '?')}\n")
	# print(f"> **Link:** https://forcepoint.atlassian.net/browse/{key}\n")
	#
	# print(f"## Summary\n\n{fields.get('summary', 'N/A')}\n")
	#
	# print("## Metadata\n")
	# print("| Field | Value |")
	# print("|-------|-------|")
	#
	# assignee = fields.get('assignee') or {}
	# reporter = fields.get('reporter') or {}
	#
	# print(f"| **Assignee** | {assignee.get('displayName', 'Unassigned')} ({assignee.get('emailAddress', 'N/A')}) |")
	# print(f"| **Reporter** | {reporter.get('displayName', 'N/A')} ({reporter.get('emailAddress', 'N/A')}) |")
	# print(f"| **Component** | {get_names(fields.get('components', []))} |")
	# labels = ', '.join(fields.get('labels', [])) if fields.get('labels') else '(none)'
	# print(f"| **Labels** | {labels} |")
	# print(f"| **Created** | {fmt_date(fields.get('created', ''))} |")
	# print(f"| **Updated** | {fmt_date(fields.get('updated', ''))} |")
	# print(f"| **Due Date** | {fmt_date(fields.get('duedate', ''))} |")
	# print(f"| **Fix Version** | {get_names(fields.get('fixVersions', []))} |")
	# print(f"| **Affected Version** | {get_names(fields.get('versions', []))} |")
	# resolution = fields.get('resolution') or {}
	# print(f"| **Resolution** | {resolution.get('name', 'Unresolved')} |")
	# print()
	#
	# if fields.get('description'):
	# 	print(f"## Description\n\n{fields['description']}\n")
	#
	# if fields.get('attachment'):
	# 	print("## Attachments\n")
	# 	for att in fields['attachment']:
	# 		print(f"- **{att.get('filename', '?')}** ({att.get('size', 0) // 1024} KB) — {att.get('author', {}).get('displayName', '?')} on {fmt_date(att.get('created', ''))}")
	# 	print()
	#
	# if fields.get('issuelinks'):
	# 	print("## Linked Issues\n")
	# 	for link in fields['issuelinks']:
	# 		issue = link.get('inwardIssue') or link.get('outwardIssue') or {}
	# 		print(f"- {link.get('type', {}).get('name', '?')}: {issue.get('key', '?')} — {issue.get('fields', {}).get('summary', '?')}")
	# 	print()
	# else:
	# 	print("## Linked Issues\n\n(none)\n")
	#
	# if fields.get('subtasks'):
	# 	print("## Subtasks\n")
	# 	for sub in fields['subtasks']:
	# 		print(f"- {sub.get('key', '?')} — {sub.get('fields', {}).get('summary', '?')} ({sub.get('fields', {}).get('status', {}).get('name', '?')})")
	# 	print()
	#
	# comments = fields.get('comment', {}).get('comments', [])
	# if comments:
	# 	print(f"## Comments ({len(comments)})\n")
	# 	for cmt in comments:
	# 		print(f"### {cmt.get('author', {}).get('displayName', '?')} — {fmt_date(cmt.get('created', ''))}\n")
	# 		print(f"{cmt.get('body', '')}\n")
	# else:
	# 	print("## Comments\n\n(none)\n")
	# SCRIPT

	# Clean up temp file
	rm -f "$json_file"
}
