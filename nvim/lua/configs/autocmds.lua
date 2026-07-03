local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Reload buffers when files change outside of Neovim
local autoread_group = augroup("configs_autoread", { clear = true })

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = autoread_group,
    command = "checktime",
})

autocmd("FileChangedShellPost", {
    group = autoread_group,
    callback = function()
        vim.notify("File reloaded because it changed on disk.", vim.log.levels.INFO, { title = "nvim" })
    end,
})

