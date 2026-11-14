# dotfiles

个人配置仓库，覆盖 git、fish、tmux、ghostty、nvim、Claude Code、Antigravity (agy)、Codex。

## 目录结构

| 路径 | 用途 | 软链目标 |
| --- | --- | --- |
| `.gitconfig` | git 全局配置 | `~/.gitconfig` |
| `.gitignore_global` | git 全局忽略规则 | `~/.gitignore_global` |
| `.tmux.conf` | tmux 配置 | `~/.tmux.conf` |
| `claude/settings.json` | Claude Code 配置 | `~/.claude/settings.json` |
| `claude/statusline-command.sh` | Claude Code 状态栏脚本 | `~/.claude/statusline-command.sh` |
| `claude/CLAUDE.global.md` | Claude Code 全局用户指令 | `~/.claude/CLAUDE.md` |
| `agy/settings.json` | Antigravity CLI 配置 | `~/.gemini/antigravity-cli/settings.json` |
| `agy/statusline-command.sh` | Antigravity CLI 状态栏脚本 | `~/.gemini/antigravity-cli/statusline-command.sh` |
| `agy/AGENTS.global.md` | Antigravity 全局用户指令 | `~/.gemini/GEMINI.md`、`~/.gemini/config/AGENTS.md` |
| `agy/mcp_config.json` | Antigravity 全局 MCP 配置 | `~/.gemini/config/mcp_config.json` |
| `agy/hooks.json` | Antigravity 全局生命周期 Hook 配置 | `~/.gemini/config/hooks.json` |
| `agy/load-claude-memory.py` | 共享 Claude 记忆与 `CLAUDE.md` 桥接脚本 | `~/.gemini/config/load-claude-memory.py` |
| `codex/config.toml` | Codex CLI 配置 | `~/.codex/config.toml` |
| `fish/config.fish` | fish shell 配置 | `~/.config/fish/config.fish` |
| `fish/fish_plugins` | fisher 插件列表 | `~/.config/fish/fish_plugins` |
| `ghostty/config.ghostty` + `ghostty/themes/*` | Ghostty 终端配置与主题 | `~/.config/ghostty/` |
| `nvim/` | Neovim 配置（lazy.nvim） | `~/.config/nvim` |

## 一键安装 / 初始化新主机

```bash
curl -fsSL https://raw.githubusercontent.com/lollipopkit/dotfiles/main/bootstrap.sh | bash
```

`bootstrap.sh` 会把仓库 clone 到 `~/proj/dotfiles`（已存在则 `git pull --ff-only` 更新），再执行 `install.sh`。可通过环境变量自定义：

```bash
# 自定义 clone 目录 / 仓库地址
DOTFILES_DIR=~/dotfiles DOTFILES_REPO_URL=git@github.com:lollipopkit/dotfiles.git \
  curl -fsSL https://raw.githubusercontent.com/lollipopkit/dotfiles/main/bootstrap.sh | bash

# 透传 install.sh 参数，用 `bash -s --` 传参
curl -fsSL https://raw.githubusercontent.com/lollipopkit/dotfiles/main/bootstrap.sh | bash -s -- --bootstrap=fish,nvim
```

## 注意事项

- `claude/CLAUDE.global.md`、`agy/AGENTS.global.md` 没有直接叫 `CLAUDE.md` / `AGENTS.md`：仓库的 `.gitignore_global` 全局忽略了所有名为 `CLAUDE.md`、`AGENTS.md`、`GEMINI.md` 的文件（各项目里生成的规则文件不应入库），所以全局指令改用 `*.global.md` 存放，避免被忽略。
- `codex/config.toml`、`claude/settings.json`、`agy/settings.json` 会在应用运行时被直接写回（model 选择、trustedWorkspaces、插件状态、marketplaces 等），软链后这些写入会直接落在仓库文件里，记得定期 `git diff` / `git status` 确认是否需要提交。
- fish、nvim 的详细说明分别见 [`fish/README.md`](fish/README.md)、[`nvim/README.md`](nvim/README.md)。
