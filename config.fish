fish_add_path /Applications/Xcode.app/Contents/Developer/usr/bin
fish_add_path ~/.local/bin
fish_add_path ~/go/bin
fish_add_path /usr/local/go/bin
fish_add_path ~/env/flutter/bin
fish_add_path ~/.bun/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.pub-cache/bin

# Change to /opt/homebrew/bin/fish if using Homebrew Fish
set -x SHELL /usr/bin/fish
set -x TZ Asia/Shanghai
set -x LC_ALL en_US.UTF-8
set -x EDITOR vim
#set -x DOCKER_HOST unix:///run/user/1000/docker.sock
set -x FIC $HOME/.config/fish/config.fish
set -x FIH $HOME/.local/share/fish/fish_history
set -gx NVM_DIR $HOME/.nvm
set -gx BUN_INSTALL "$HOME/.bun"

set -g fish_greeting
set -g sponge_successful_exit_codes 0 130 255
set -g sponge_purge_only_on_exit true
set -g hydro_symbol_prompt '>'
set -g hydro_symbol_git_dirty '!'
set -g hydro_color_pwd BB2D6F
set -g hydro_color_prompt BB2D6F

alias dps 'docker ps -a --format "table {{printf \"%-15.15s %-15.15s %-30.30s %-15.15s\" .ID .Names .Image .Status}}"'
alias dcp 'docker compose'
alias ulog 'journalctl --user -u'
alias uctl 'systemctl --user'
alias dp 'dart pub'
alias drbb 'dart run build_runner build --delete-conflicting-outputs'
alias scpr 'rsync -P --rsh=ssh'
alias fl_build 'dart run fl_build'

set SSH_ENV "$HOME/.ssh/agent-environment"

function start_ssh_agent -d "Start a new SSH agent"
    echo "Initialising new SSH agent..."

    /usr/bin/ssh-agent | sed 's/^echo/#echo/' | sed 's/;.*$//' | sed -E 's/([A-Z_][A-Z0-9_]+)=(.*)/set -x \1 \2/g' > "$SSH_ENV"

    chmod 600 "$SSH_ENV"
    source "$SSH_ENV" > /dev/null
    /usr/bin/ssh-add
end

if test -f "$SSH_ENV"
    . "$SSH_ENV" > /dev/null
    or start_ssh_agent
else
    start_ssh_agent
end

function fish_prompt
    set -l current_time (date +%H:%M)
    printf '%s%s%s %s%s%s %s%s%s%s%s%s%s%s%s ' \
        "$_hydro_color_pwd" "$current_time" "$hydro_color_normal" \
        "$_hydro_color_pwd" "$_hydro_pwd" "$hydro_color_normal" \
        "$_hydro_color_git" "$$_hydro_git" "$hydro_color_normal" \
        "$_hydro_color_duration" "$_hydro_cmd_duration" "$hydro_color_normal" \
        "$_hydro_status" "$hydro_color_normal"
end
