return {
    -- 快速跳转
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            labels = "asdfghjklqwertyuiop",
            search = {
                multi_window = true,
                forward = true,
                wrap = true,
            },
            modes = {
                char = { 
                    enabled = false, -- 禁用 f/F/t/T 模式
                    jump_labels = true,
                    multi_line = true,
                },
            },
        },
        keys = {
            { "<leader>j", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Jump (Flash)" },
            { "<leader>J", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Jump TS (Flash)" },
        },
    },
    
    -- 包围操作
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },
}