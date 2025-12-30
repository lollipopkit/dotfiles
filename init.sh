#!/usr/bin/env bash
# 初始化脚本（Debian/Ubuntu 系）
# NOTE:
# - This file is **bash**, not fish. Do not `source` it from fish.
# - Run it as your normal user; it will use sudo only when needed.
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

require_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    return 0
  fi
  if command -v sudo >/dev/null 2>&1; then
    sudo -n true >/dev/null 2>&1 && return 0
    return 1
  fi
  return 1
}

target_user="${USER:-root}"
target_home="$(
  if command -v getent >/dev/null 2>&1; then
    getent passwd "$target_user" | cut -d: -f6
  else
    printf '%s' "/home/$target_user"
  fi
)"

run_as_target_user() {
  local cmd="$1"
  bash -lc "$cmd"
}

if require_sudo; then
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git curl vim fish htop ca-certificates
else
  echo "Skipping apt setup: sudo not available or requires a password."
fi

# 配置 fish shell
raw_base_url="https://raw.githubusercontent.com/lollipopkit/fish-cfg/refs/heads/main/"
config_url="${raw_base_url}config.fish"
fish_dir="$target_home/.config/fish"
install -d -m 0755 "$fish_dir"
install -d -m 0755 "$fish_dir/functions"

curl -fsSL "$config_url" -o "$fish_dir/config.fish"
chmod 0644 "$fish_dir/config.fish"

run_as_target_user "fish -c 'source \"$fish_dir/config.fish\"' < /dev/null"
# 安装 fisher
run_as_target_user "fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher install jorgebucaran/fisher' < /dev/null"
fish_plugins_url="${raw_base_url}fish_plugins"
curl -fsSL "$fish_plugins_url" -o "$fish_dir/fish_plugins"
chmod 0644 "$fish_dir/fish_plugins"

run_as_target_user "fish -c 'fisher install (cat \"$fish_dir/fish_plugins\")' < /dev/null"

if command -v chsh >/dev/null 2>&1; then
  chsh -s /usr/bin/fish
fi

# 安装golang
if ! command -v go >/dev/null 2>&1; then
    GO_VERSION="1.25.5"
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        GO_ARCH="amd64"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        GO_ARCH="arm64"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
    if require_sudo; then
        curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -o /tmp/go.tar.gz
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
    else
        echo "Skipping Go install: sudo not available or requires a password."
    fi
fi

# 安装docker
if ! command -v docker >/dev/null 2>&1; then
    if require_sudo; then
        curl -fsSL https://get.docker.com/ | sudo sh
        sudo usermod -aG docker "$target_user"
    else
        echo "Skipping Docker install: sudo not available or requires a password."
    fi
fi