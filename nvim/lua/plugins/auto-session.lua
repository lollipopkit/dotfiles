return { {
    "rmagatti/auto-session",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        log_level = "error",
        auto_session_enable_last_session = true, -- 启用自动恢复上次会话
        auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
        auto_save_enabled = true,                -- 退出时自动保存
        auto_restore_enabled = true,             -- 启动时自动恢复
        auto_session_use_git_branch = false      -- 按项目分会话（可选）
    }
} }
