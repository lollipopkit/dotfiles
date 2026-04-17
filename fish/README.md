## fish cfg

- Q: Why fish?
- A: Fast, lightweight, and easy to use.

### Install

1. 安装 `fisher`
   ```bash
   curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
   fisher install jorgebucaran/fisher
   ```
2. 安装插件
   ```bash
   fisher install (curl -fsSL https://raw.githubusercontent.com/lollipopkit/fish-cfg/main/fish/fish_plugins | string split \n)
   ```
