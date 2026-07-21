#!/usr/bin/env bash
# 一键初始化新主机：将仓库文件软链到对应的系统配置路径，并跑一遍各配置的首次初始化。
# 已存在且不是指向本仓库的文件/目录会先备份到 backup 目录，再建立软链。
# 与本机路径无关，可在任意主机上重复执行（幂等）。
#
# 用法: ./install.sh [--skip-bootstrap] [--bootstrap=fish,nvim]
#   --skip-bootstrap    只建软链，不执行任何首次初始化命令
#   --bootstrap=a,b     非交互指定要初始化的组件(fish/nvim)，用于脚本化调用
# 不带上述参数时：交互式终端会提示选择要初始化的组件；非交互式终端(如管道/CI)默认只初始化 fish
# (nvm.fish 只是 fish_plugins 里的一个 fisher 插件，随 fish 初始化一起装，不是 nvim 编辑器)。
set -euo pipefail

SKIP_BOOTSTRAP=0
BOOTSTRAP_ARG=""
for arg in "$@"; do
  case "$arg" in
    --skip-bootstrap) SKIP_BOOTSTRAP=1 ;;
    --bootstrap=*) BOOTSTRAP_ARG="${arg#--bootstrap=}" ;;
    *) echo "未知参数: $arg" >&2; exit 1 ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

# src(仓库内相对路径) dst(目标绝对路径)
LINKS=(
  ".gitconfig|$HOME/.gitconfig"
  ".gitignore_global|$HOME/.gitignore_global"
  ".tmux.conf|$HOME/.tmux.conf"
  "claude/settings.json|$HOME/.claude/settings.json"
  "claude/statusline-command.sh|$HOME/.claude/statusline-command.sh"
  "claude/CLAUDE.global.md|$HOME/.claude/CLAUDE.md"
  "codex/config.toml|$HOME/.codex/config.toml"
  "fish/config.fish|$CONFIG_HOME/fish/config.fish"
  "fish/fish_plugins|$CONFIG_HOME/fish/fish_plugins"
  "ghostty/config.ghostty|$CONFIG_HOME/ghostty/config.ghostty"
  "ghostty/themes/iterm2-dark|$CONFIG_HOME/ghostty/themes/iterm2-dark"
  "ghostty/themes/iterm2-light|$CONFIG_HOME/ghostty/themes/iterm2-light"
  "nvim|$CONFIG_HOME/nvim"
)

link_one() {
  local src="$REPO_DIR/$1"
  local dst="$2"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "跳过(已链接): $dst"
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup_target="$BACKUP_DIR/${dst#"$HOME"/}"
    mkdir -p "$(dirname "$backup_target")"
    mv "$dst" "$backup_target"
    echo "已备份: $dst -> $backup_target"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "已链接: $dst -> $src"
}

for entry in "${LINKS[@]}"; do
  src="${entry%%|*}"
  dst="${entry##*|}"
  link_one "$src" "$dst"
done

echo
echo "软链完成。codex/config.toml、claude/settings.json 等文件被应用运行时写入后会直接修改仓库内文件，请留意 git diff。"

bootstrap_fish() {
  if ! command -v fish >/dev/null 2>&1; then
    echo "跳过 fish 插件安装: 未找到 fish"
    return
  fi

  if ! fish -c 'type -q fisher' >/dev/null 2>&1; then
    echo "安装 fisher..."
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
  fi

  echo "安装 fish 插件..."
  fish -c "fisher install (string split \n -- (cat \"$CONFIG_HOME/fish/fish_plugins\"))"

  if fish -c 'type -q nvm' >/dev/null 2>&1; then
    echo "安装 Node LTS(nvm install lts && nvm use lts)..."
    fish -c 'nvm install lts && nvm use lts'
  fi
}

bootstrap_nvim() {
  if ! command -v nvim >/dev/null 2>&1; then
    echo "跳过 nvim 插件安装: 未找到 nvim"
    return
  fi

  echo "同步 nvim 插件(Lazy sync)..."
  nvim --headless "+Lazy! sync" +qa
  echo "同步 nvim LSP/DAP/格式化工具(MasonUpdate)..."
  nvim --headless "+MasonUpdate" +qa
}

DO_FISH=0
DO_NVIM=0

if [[ "$SKIP_BOOTSTRAP" -eq 1 ]]; then
  echo "已跳过首次初始化(--skip-bootstrap)。"
elif [[ -n "$BOOTSTRAP_ARG" ]]; then
  IFS=',' read -ra parts <<< "$BOOTSTRAP_ARG"
  for p in "${parts[@]}"; do
    case "$p" in
      fish) DO_FISH=1 ;;
      nvim) DO_NVIM=1 ;;
      *) echo "未知的 --bootstrap 组件: $p" >&2; exit 1 ;;
    esac
  done
elif [[ -t 0 ]]; then
  echo
  echo "选择要初始化的组件(空格分隔序号，直接回车 = 默认仅 fish):"
  echo "  1) fish  -- fisher 插件(含 nvm.fish)"
  echo "  2) nvim  -- 编辑器插件(Lazy sync + Mason)，与 nvm.fish 无关"
  read -rp "> " choice
  if [[ -z "$choice" ]]; then
    DO_FISH=1
  else
    for c in $choice; do
      case "$c" in
        1) DO_FISH=1 ;;
        2) DO_NVIM=1 ;;
        *) echo "忽略未知选项: $c" >&2 ;;
      esac
    done
  fi
else
  # 非交互式终端，默认只初始化 fish
  DO_FISH=1
fi

if [[ "$DO_FISH" -eq 1 || "$DO_NVIM" -eq 1 ]]; then
  echo
  echo "开始首次初始化..."
  [[ "$DO_FISH" -eq 1 ]] && bootstrap_fish
  [[ "$DO_NVIM" -eq 1 ]] && bootstrap_nvim
  echo "首次初始化完成。"
fi
