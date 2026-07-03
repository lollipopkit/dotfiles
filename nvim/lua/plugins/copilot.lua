return {
    {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        cmd = "Copilot",
        opts = {
            suggestion = {
                enabled = true,       -- 启用行内建议
                auto_trigger = true,  -- 自动触发
                keymap = {
                    accept = "<Tab>", -- 接受建议键位
                    next = "<C-]>",
                    prev = "<C-\\>",
                    dismiss = "<C-/>",
                },
            },
            panel = {
                enabled = true, -- 启用 Copilot 面板
                auto_refresh = true,
                keymap = {
                    open = "<M-CR>",
                    jump_prev = "[[",
                    jump_next = "]]",
                    refresh = "gr",
                    close = "q",
                },
            },
        },
        config = function(_, opts)
            require("copilot").setup(opts)
        end,
    },
}
