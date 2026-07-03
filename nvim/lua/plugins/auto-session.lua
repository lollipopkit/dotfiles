return { {
    "rmagatti/auto-session",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        log_level = "error",
        root_dir = vim.fn.stdpath("data") .. "/sessions/",
        auto_save = true,                  -- 退出时自动保存“当前目录”的会话
        auto_restore = true,               -- 启动时恢复“当前目录”的会话（VSCode 式状态恢复）
        -- 关键：不恢复“上一次那个项目”的会话。否则在无会话目录打开 nvim
        -- 会去 cd 到旧项目目录，一旦目录被删就报 E344。
        auto_restore_last_session = false,
    }
} }
