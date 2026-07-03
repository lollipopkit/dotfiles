return {
    -- LazyGit 浮窗：完整的 git 页面（暂存/提交/推送/分支/stash/log）
    {
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>gg", "<cmd>LazyGit<cr>",            desc = "LazyGit（浮窗）" },
            { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit 当前文件" },
            { "<leader>gl", "<cmd>LazyGitFilter<cr>",      desc = "LazyGit 提交历史" },
        },
        init = function()
            vim.g.lazygit_floating_window_scaling_factor = 0.9
            vim.g.lazygit_use_neovim_remote = 0

            -- keymaps.lua 里把终端模式 <Esc> 全局映射成退出终端，会抢走 lazygit 的
            -- <Esc>（返回/取消）。这里对 lazygit 终端缓冲区撤销该映射，交还给 lazygit。
            vim.api.nvim_create_autocmd("TermOpen", {
                group = vim.api.nvim_create_augroup("lazygit_esc", { clear = true }),
                callback = function(args)
                    if vim.api.nvim_buf_get_name(args.buf):match("lazygit") then
                        vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = args.buf })
                    end
                end,
            })
        end,
    },
}
