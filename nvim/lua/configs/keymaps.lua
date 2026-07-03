local map = vim.keymap.set
local opts = { silent = true }

-- Leader 键
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 基础操作
map("n", "<Leader>w", "<Cmd>w<CR>", opts)
map("n", "<Leader>q", "<Cmd>q<CR>", opts)
map("n", "<Leader>qq", "<Cmd>qa!<CR>", opts)
map("n", "<Leader>x", "<Cmd>x<CR>", opts) -- 保存并退出

-- 快速编辑
map("n", "J", "mzJ`z", opts) -- 合并行但保持光标位置
map("v", "J", ":m '>+1<CR>gv=gv", opts) -- 向下移动选中行
map("v", "K", ":m '<-2<CR>gv=gv", opts) -- 向上移动选中行

-- 更好的搜索
map("n", "n", "nzzzv", opts) -- 搜索时保持屏幕居中
map("n", "N", "Nzzzv", opts)

-- 分屏操作
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<Leader>vs", "<Cmd>vsplit<CR>", opts) -- 垂直分屏
map("n", "<Leader>hs", "<Cmd>split<CR>", opts)  -- 水平分屏

-- 缓冲区管理
map("n", "<Leader>bd", "<Cmd>bdelete<CR>", opts) -- 删除缓冲区
map("n", "<Tab>", "<Cmd>bnext<CR>", opts)        -- 下一个缓冲区
map("n", "<S-Tab>", "<Cmd>bprevious<CR>", opts)  -- 上一个缓冲区

-- 数字快速切换缓冲区
for i = 1, 9 do
  map("n", "<Leader>" .. i, function()
    require('bufferline').go_to_buffer(i, true)
  end, { desc = "跳转到缓冲区 " .. i, silent = true })
end

-- Telescope
map("n", "<Leader>ff", "<Cmd>Telescope find_files<CR>", opts)
map("n", "<Leader>fg", "<Cmd>Telescope live_grep<CR>", opts)
map("n", "<Leader>fb", "<Cmd>Telescope buffers<CR>", opts)
map("n", "<Leader>fh", "<Cmd>Telescope help_tags<CR>", opts)
map("n", "<Leader>fr", "<Cmd>Telescope resume<CR>", opts)      -- 恢复上次搜索
map("n", "<Leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>", opts) -- 文档符号

-- 文件树
map("n", "<Leader>e", "<Cmd>NvimTreeToggle<CR>", opts)
map("n", "<Leader>ef", "<Cmd>NvimTreeFindFile<CR>", opts) -- 在文件树中定位当前文件

-- 终端
map("n", "<Leader>t", "<Cmd>terminal<CR>", opts)
map("t", "<Esc>", "<C-\\><C-n>", opts) -- 终端模式下退出

-- 快速选择
map("n", "<Leader>a", "ggVG", opts) -- 全选
