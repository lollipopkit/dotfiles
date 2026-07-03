# Neovim 配置说明

本仓库提供一套围绕 Rust、Go、TypeScript/JavaScript 与 Dart 开发优化的 Neovim 配置，基于 [lazy.nvim](https://github.com/folke/lazy.nvim) 实现按需加载和插件版本锁定。核心目标是快速启动、统一编码风格、完善的 LSP/DAP 体验与清晰的键位规范。

## 环境要求

- Neovim ≥ 0.9，建议 0.10 以获得原生 inlay hints 与最新 API。
- 系统需安装 Git、ripgrep、fd (Telescope 可选) 以及各语言的 Toolchain：Rustup、Go、Node.js (含 npm)、Dart/Flutter SDK。
- Python 3 以及 `pip install pynvim` 可提升 Python 集成体验。

## 安装与初始化

1. 备份现有配置并克隆本仓库至 `~/.config/nvim`：

   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup # 如已有配置
   git clone https://github.com/your/repo.git ~/.config/nvim
   ```

2. 首次启动：

   ```bash
   nvim --headless "+Lazy sync" +qa
   nvim --headless "+MasonUpdate" +qa
   ```

   这会安装插件、语言服务器、调试适配器与格式化工具（详见 `lazy-lock.json` 与 `lua/plugins/conform.lua`）。
3. 打开 Neovim 后运行 `:checkhealth`、`:Lazy`、`:Mason` 确认依赖状态。

## 项目结构

- `init.lua`：入口文件，加载基础选项与 lazy.nvim。
- `lua/configs/`：通用配置模块，例如 `options.lua`、`keymaps.lua`、`lsp.lua`。
- `lua/plugins/`：按领域拆分的插件定义；`langs.lua` 侧重 Rust/Go/TypeScript/Dart 工具链，`dap.lua` 提供调试适配器。
- `lazy-lock.json`：插件版本锁，只有在执行 `:Lazy sync` 成功后才更新。
- `KEYS.md`：更完整的快捷键清单。

## 插件与语言特性概览

- **UI/UX**：onedarkpro 主题、lualine 状态栏、bufferline、which-key、indent-blankline、nvim-tree。
- **查找与导航**：Telescope、flash.nvim、nvim-treesitter 增量选择与语法高亮。
- **LSP**：`lua/configs/lsp.lua` 统一 on_attach 与 capabilities，Mason 自动安装 `gopls`、`rust_analyzer`、`tsserver`、`dartls` 等；Rust 进一步由 RustaceanVim 管理，TypeScript 使用 `typescript-tools.nvim`，Go 集成 `go.nvim`，Dart 通过 `flutter-tools.nvim`。
- **补全与 AI**：nvim-cmp（LSP、snippet、buffer、path 源）结合 LuaSnip、friendly-snippets 与 Copilot。
- **代码格式化**：Conform 配置 goimports、rustfmt、prettier、dart format 等；保存时自动格式化，必要时回退至 LSP。
- **调试**：nvim-dap + dap-ui，内置适配器包括 js-debug、codelldb、debugpy、delve，可针对主要语言进行断点调试。

## 快速上手

- 使用 `:Telescope find_files` / `<Leader>ff` 搜索文件，`<Leader>fg` 全局搜索。
- LSP 工作流：`gd` 跳转定义、`gr` 查找引用、`<Leader>ca` 触发代码操作、`<Leader>rn` 重命名、`<Leader>f` 格式化、`K` 查看文档、`[d`/`]d` 在诊断间跳转。
- 调试（DAP）：为避免和诊断 `<Leader>d*` 冲突，DAP 统一改为 `<Leader>D*`：`<Leader>Db` 断点、`<Leader>Dc` 继续、`<Leader>Dut` UI。
- 运行 / 测试（终端）：统一用 `<Leader>r*`（buffer-local）。
  - Go：`<Leader>rr` → `go run .`，`<Leader>rt` → `go test ./...`
  - Rust：`<Leader>rr` → `cargo run`，`<Leader>rt` → `cargo test`，`<Leader>rc` → `cargo clippy`，`<Leader>rR` → `:RustLsp runnables`
  - Dart/Flutter：`<Leader>rr` → `:FlutterRun`（默认 DAP 可断点），`<Leader>rt` → `flutter test`（terminal），`<Leader>rl` → `:FlutterReload`，`<Leader>rR` → `:FlutterRestart`

## 高频键位
>
> Leader = `<Space>`，更多请参考 `KEYS.md`。

| 分组 | 快捷键 | 功能 |
| --- | --- | --- |
| 文件 | `<Leader>w` / `<Leader>x` / `<Leader>q` | 保存 / 保存并退 / 退出 |
| 窗口 | `<C-h/j/k/l>` | 切换窗口 |
| 缓冲区 | `<Tab>` / `<S-Tab>` / `<Leader>bd` | 切换 / 关闭缓冲区 |
| 搜索 | `<Leader>ff` / `<Leader>fg` / `<Leader>fs` | 文件 / 全局 / 符号 |
| 文件树 | `<Leader>e` / `<Leader>ef` | 切换 / 定位当前文件 |
| LSP | `gd`, `gr`, `<Leader>rn`, `<Leader>ca`, `<Leader>f` | 导航 / 重命名 / 操作 / 格式化 |
| 诊断 | `[d`, `]d`, `<Leader>d`, `<Leader>dl` | 浏览诊断 |
| 补全 | `<C-Space>`, `<CR>`, `<C-b>/<C-f>` | 打开菜单 / 确认 / 滚动文档 |
| Copilot | `<Tab>` / `<C-]>` / `<C-\\>` / `<C-/>` | 接受 / 下一个 / 上一个 / 拒绝 |
| 调试 | `<Leader>Db`, `<Leader>Dc`, `<Leader>Dj`, `<Leader>Dk`, `<Leader>Dut` | 断点 / 继续 / 步过 / 步入 / UI |
| 终端 | `<Leader>t`, `<Esc>` (终端模式) | 开启浮动终端 / 返回普通模式 |

## 维护流程

1. 更新插件：手动执行 `:Lazy sync`，确认 `lazy-lock.json` 变化可控再提交。
2. 更新语言工具：`:MasonUpdate`、`:MasonInstall <pkg>`，Rust 可额外 `rustup update`，Go 使用 `go install` 安装 linters。
3. 调试适配器：确保 Mason 中安装 `js-debug-adapter`、`codelldb`、`delve`；Flutter 调试需本地 `dart` 与 `flutter` 可执行文件。
4. 变更键位或配置后同步更新 `KEYS.md`，保证键位说明与实现一致。

## 常见问题

- **插件未被识别**：查看 `:Lazy` 面板的错误日志；必要时删除 `~/.local/share/nvim/lazy/` 对应目录再同步。
- **LSP 无法启动**：检查 `:Mason` 中服务器状态或执行 `:LspInfo`，确认语言工具链在 `$PATH` 中。
- **格式化失败**：`null-ls` 未使用；查看 `:messages` 或手动执行 `:ConformInfo` 了解失败原因。
- **调试器无连接**：确保可执行文件存在且使用的是对应语言的适配器；Go 需 `dlv`，Rust 需编译产物并输入路径。

欢迎根据自身需求在 `lua/plugins` 目录扩展更多语言支持或 UI 插件，保持模块化可维护性。 若遇到问题，可在 Issue 中附上 `:checkhealth` 和 `:Lazy` 输出，便于排查。
