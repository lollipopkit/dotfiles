#!/usr/bin/env bash
# 初始化脚本（Debian/Ubuntu 系）
# NOTE:
# - This file is **bash**, not fish. Do not `source` it from fish.
# - Run it as: `sudo bash ./init.sh` (or `bash ./init.sh` if already root).
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    exec sudo -E bash "$0" "$@"
  fi
  echo "This script needs root for apt + /usr/local installs. Re-run with sudo."
  exit 1
fi

target_user="${SUDO_USER:-${USER:-root}}"
target_home="$(
  if command -v getent >/dev/null 2>&1; then
    getent passwd "$target_user" | cut -d: -f6
  else
    printf '%s' "/home/$target_user"
  fi
)"

run_as_target_user() {
  local cmd="$1"
  if [ "$target_user" = "$(id -un)" ]; then
    bash -lc "$cmd"
    return
  fi

  # IMPORTANT:
  # `su - user -c "..."` runs the command using the user's *login shell*.
  # If their login shell is fish, bash-style quoting breaks and fish will try to parse it.
  # Force bash explicitly so the quoting rules are predictable.
  if command -v sudo >/dev/null 2>&1; then
    sudo -H -u "$target_user" bash -lc "$cmd"
    return
  fi

  if command -v su >/dev/null 2>&1; then
    local quoted
    printf -v quoted '%q' "$cmd"
    su - "$target_user" -s /bin/bash -c "bash -lc $quoted"
    return
  fi

  echo "Need 'sudo' or 'su' to run user-scoped steps as $target_user."
  exit 1
}

apt update && apt upgrade -y
apt install -y git curl vim fish htop ca-certificates

# 配置 fish shell
raw_base_url="https://raw.githubusercontent.com/lollipopkit/fish-cfg/refs/heads/main/"
config_url="${raw_base_url}config.fish"
fish_dir="$target_home/.config/fish"
install -d -m 0755 -o "$target_user" "$fish_dir"
install -d -m 0755 -o "$target_user" "$fish_dir/functions"

curl -fsSL "$config_url" -o "$fish_dir/config.fish"
chown "$target_user" "$fish_dir/config.fish"
chmod 0644 "$fish_dir/config.fish"

run_as_target_user "fish -c 'source \"$fish_dir/config.fish\"'"
# 安装 fisher
run_as_target_user "fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher install jorgebucaran/fisher'"
fish_plugins_url="${raw_base_url}fish_plugins"
curl -fsSL "$fish_plugins_url" -o "$fish_dir/fish_plugins"
chown "$target_user" "$fish_dir/fish_plugins"
chmod 0644 "$fish_dir/fish_plugins"

run_as_target_user "fish -c 'fisher install (cat \"$fish_dir/fish_plugins\")'"

if command -v chsh >/dev/null 2>&1; then
  chsh -s /usr/bin/fish "$target_user" || true
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
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -o /tmp/go.tar.gz
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
fi
