return {
    -- 主题
    {
        "olimorris/onedarkpro.nvim",
        priority = 1000,
        lazy     = false,
        config   = function()
            vim.cmd("colorscheme onedark_dark")
        end,
    },

    -- 状态栏
    {
        "nvim-lualine/lualine.nvim",
        event        = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts         = { options = { section_separators = "", component_separators = "" } },
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = " ",
                    path_display = { "truncate" },
                    file_ignore_patterns = { "node_modules", ".git/", "target/", "build/", ".dart_tool/" },
                    layout_config = {
                        horizontal = { preview_width = 0.6 },
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true, -- 显示隐藏文件
                    },
                    live_grep = {
                        additional_args = function() return { "--hidden" } end,
                    },
                },
            })
            pcall(require("telescope").load_extension, "fzf")
        end,
    },

    -- Git 行内标记
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts  = {
            signs = {
                add          = { text = "▌" },
                change       = { text = "▌" },
                delete       = { text = "▸" },
                topdelete    = { text = "▸" },
                changedelete = { text = "▌" },
            },
        },
    },

    -- 注释
    { "numToStr/Comment.nvim", opts = {},             keys = { { "gc", mode = { "n", "v" } } } },

    -- 自动括号
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

    -- which‑key
    { "folke/which-key.nvim",  event = "VeryLazy",    opts = {} },
}
