status is-interactive || exit

set -x PATH $PATH ~/env/script
set -x PATH $PATH ~/.cargo/bin
set -x PATH $PATH ~/.local/bin
set -x PATH $PATH ~/env/flutter/bin
set -x PATH $PATH ~/go/bin
set -x PATH $PATH ~/env/android/cmdline-tools/latest/bin
set -x PATH $PATH ~/env/android/platform-tools
set -x PATH $PATH ~/proj/fvck_adb_mDNS
set -x PATH $PATH /usr/local/go/bin
set -x PATH $PATH ~/.pub-cache/bin

set -x SHELL /usr/bin/fish
set -x TZ Asia/Shanghai
set -x LC_ALL en_US.UTF-8
set -x EDITOR vim
set -x ANDROID_HOME ~/env/android
set -x DOCKER_HOST unix:///run/user/1000/docker.sock
set -x FIC $HOME/.config/fish/config.fish
set -x FIH $HOME/.local/share/fish/fish_history

set -g fish_greeting
set -g sudope_sequence \cs
set -g sponge_successful_exit_codes 0 130
set -g sponge_delay 5
set -g hydro_symbol_prompt '>'
set -g hydro_symbol_git_dirty '!'
set -g hydro_color_pwd BB2D6F
set -g hydro_color_prompt BB2D6F

alias dps 'docker ps -a --format "table {{printf \"%-15.15s %-15.15s %-30.30s %-15.15s\" .ID .Names .Image .Status}}"'
alias dcp 'docker compose'
alias ulog 'journalctl --user -u'
alias slog 'journalctl -u'
alias uctl 'systemctl --user'
alias sctl 'systemctl'
alias fgl 'flutter gen-l10n'
alias dfmt 'dart format .'
alias gtp 'git_tag_push'
alias ka 'kill_all'
alias gr 'go run'
alias gmt 'go mod tidy'
alias dp 'dart pub'
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
    echo -e "$_hydro_color_pwd$_hydro_pwd$hydro_color_normal $_hydro_color_git$$_hydro_git$hydro_color_normal$_hydro_color_duration$_hydro_cmd_duration$hydro_color_normal$_hydro_status$hydro_color_normal "
end

function compress -d "Compress dir to tar.gz"
    if test (count $argv) -eq 0
        echo "Usage: compress <dir>"
        return 1
    end
    tar -czvf $argv[1].tar.gz $argv[1]
end

function kill_all -d "Kill all processes with a keyword"
    if test (count $argv) -eq 0
        echo "Usage: kill_all <keyword>"
        return 1
    end

    set keyword $argv[1]
    ps aux | grep "$keyword" | grep -v grep | awk '{print $2}' | xargs -r kill -9
end

function git_tag_push -d "Create a tag and push it to the remote"
    set tag ""
    if test (count $argv) -ge 1
        set tag $argv[1]
    else
        set count (git rev-list --count HEAD)
        set tag "v1.0.$count"
    end

    set msg $tag
    if test (count $argv) -ge 2
        set msg $argv[2]
    end

    git tag -a "$tag" -m "$msg"
    or return 1

    git push origin "$tag"
    or return 1

    echo "Tag $tag pushed successfully"
end

function mdc -d "Make directory and cd into it"
    mkdir -p $argv[1]
    cd $argv[1]
end

function combine_dir_files_into_one -d "Combine files in a dir into one file"
    argparse 'd/directory=' 'o/output=' 'c/comment=' -- $argv
    or return 1

    if not set -q _flag_directory; or not set -q _flag_output
        echo "Usage: combine_dir_files_into_one -d <directory> -o <output_file> [-c <comment_symbol>]"
        return 1
    end

    set directory $_flag_directory
    set output_file $_flag_output
    set comment_symbol "//"
    if set -q _flag_comment
        set comment_symbol $_flag_comment
    end

    if not test -d "$directory"
        echo "错误: 目录 '$directory' 不存在"
        return 1
    end

    # 递归函数
    function process_directory
        set dir $argv[1]
        set base_dir $argv[2]
        set local_output_file $argv[3]
        set local_comment_symbol $argv[4]

        for item in $dir/*
            if test -f "$item"
                # 计算相对路径
                set rel_path (string replace "$base_dir/" "" "$item")
                
                # 写入文件路径和内容
                echo "$rel_path"
                echo "$local_comment_symbol $rel_path" >> $local_output_file
                cat "$item" >> $local_output_file
                echo "" >> $local_output_file
            else if test -d "$item"
                # 如果是目录，递归处理
                process_directory "$item" "$base_dir" $local_output_file $local_comment_symbol
            end
        end
    end

    # 清空或创建输出文件
    echo -n > $output_file

    # 开始处理
    process_directory "$directory" "$directory" $output_file $comment_symbol

    echo "已写入 $output_file"
end

function git_merge -d "合并远程仓库"
    set -l options 'r/repo=' 'b/branch='
    argparse $options -- $argv

    set -l USERNAME $argv[1]
    set -l REPO $_flag_repo
    set -l BRANCH $_flag_branch

    # 如果没有指定 REPO，则使用当前仓库名称
    if test -z "$REPO"
        set REPO (basename (git rev-parse --show-toplevel))
    end

    # 如果没有指定 BRANCH，则使用 main
    if test -z "$BRANCH"
        set BRANCH "main"
    end

    # 保存当前分支名
    set CURRENT_BRANCH (git rev-parse --abbrev-ref HEAD)

    # 确保工作目录干净
    if not git diff-index --quiet HEAD --
        echo "错误：工作目录不干净，请先提交或存储更改"
        return 1
    end

    # 添加远程仓库（如果不存在）
    git remote add $USERNAME https://github.com/$USERNAME/$REPO.git 2>/dev/null; or true

    # 获取最新的远程分支信息
    git fetch $USERNAME

    # 尝试合并
    if git merge --no-edit --no-ff $USERNAME/$BRANCH
        echo "成功合并 $USERNAME/$REPO:$BRANCH 到 $CURRENT_BRANCH"
    else
        # 合并失败，尝试使用 -Xtheirs 策略
        if git merge --no-edit --no-ff -Xtheirs $USERNAME/$BRANCH
            echo "使用 -Xtheirs 策略成功合并 $USERNAME/$REPO:$BRANCH 到 $CURRENT_BRANCH"
        else
            # 如果仍然失败，中止合并并恢复到原始状态
            git merge --abort
            echo "错误：无法自动合并。请手动解决冲突"
            return 1
        end
    end
end

function git_lines -d "Get the lines of code of a git repository"
    set name (git config user.name)

    set_color yellow
    echo -n "["
    echo -n (set_color yellow) $name (set_color normal)
    echo -n "] at ["
    echo -n (set_color green) (date) (set_color normal)
    echo "]"
    git log --author="$name" --pretty=tformat: --numstat -- $dir | awk '{ add += $1 ; subs += $2 ; loc += $1 + $2 } END { printf "added lines: \033[34m%d\033[0m, removed lines: \033[31m%d\033[0m, total lines: \033[32m%d\033[0m\n", add, subs, loc }'
end

# Print the first commit's hash, line, author and date as text(non interactive).
function git_first -d "Get the first commit of a git repository"
    git log --reverse --pretty=format:"%h  %ad  %s  %an" --date=short | head -n 1
end
