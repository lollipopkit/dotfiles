local o, g = vim.o, vim.g

-- 基础设置
o.number = true
o.relativenumber = true
o.termguicolors = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.clipboard = "unnamedplus"
o.splitright = true
o.splitbelow = true
o.updatetime = 300
o.signcolumn = "yes"
o.mouse = "a"
o.scrolloff = 8         -- 光标上下保持8行
o.sidescrolloff = 8     -- 光标左右保持8列
o.cursorline = true     -- 高亮当前行
o.autoread = true       -- 外部修改时自动读取文件

-- 性能优化
o.lazyredraw = true     -- 宏执行时不重绘
o.ttyfast = true        -- 快速终端连接
o.timeoutlen = 500      -- 按键序列超时时间
o.ttimeoutlen = 10      -- 键码序列超时时间

-- 搜索设置
o.ignorecase = true     -- 搜索忽略大小写
o.smartcase = true      -- 有大写字母时精确匹配
o.hlsearch = true       -- 高亮搜索结果
o.incsearch = true      -- 增量搜索
o.grepprg = "rg --vimgrep --smart-case --follow" -- 使用 ripgrep 进行搜索

-- 备份和交换文件
o.backup = false
o.writebackup = false
o.swapfile = false

-- Markdown 围栏代码块高亮
g.markdown_fenced_languages = {
    "bash", "fish", "go", "rust", "dart", "lua",
    "javascript", "typescript", "swift",
    "json", "yaml", "dockerfile",
}

-- 禁用部分内置插件以加快启动（保持原有配置）
for _, p in ipairs({
    "gzip", "zip", "zipPlugin", "tar", "tarPlugin",
    "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
    "2html_plugin", "logipat", "matchit", "matchparen",
    "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
}) do
    g["loaded_" .. p] = 1
end
