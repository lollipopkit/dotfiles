#!/usr/bin/env bash
# curl -fsSL https://raw.githubusercontent.com/lollipopkit/dotfiles/main/bootstrap.sh | bash
# 用于在没有本地 clone 的新主机上一键拉取本仓库并执行 install.sh。
# 支持透传 install.sh 的参数，例如:
#   curl -fsSL .../bootstrap.sh | bash -s -- --bootstrap=fish,nvim
set -euo pipefail

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/lollipopkit/dotfiles.git}"
TARGET_DIR="${DOTFILES_DIR:-$HOME/proj/dotfiles}"

if ! command -v git >/dev/null 2>&1; then
  echo "需要先安装 git" >&2
  exit 1
fi

if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "更新已存在的仓库: $TARGET_DIR"
  git -C "$TARGET_DIR" pull --ff-only
else
  echo "克隆仓库到: $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

exec "$TARGET_DIR/install.sh" "$@"
