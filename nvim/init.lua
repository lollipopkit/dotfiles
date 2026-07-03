-- 基础设置
require("configs.options")
require("configs.keymaps")
require("configs.autocmds")

-- 引导 lazy.nvim（如未安装会自动克隆）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 插件加载
require("lazy").setup({ { import = "plugins" } }, {
  ui = { border = "rounded" },
  change_detection = { enabled = true, notify = false },
})
