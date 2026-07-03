return {
    -- 缩进线
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = { char = "│" },
            scope = { enabled = false },
        },
    },
    
    -- 高亮当前单词
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("illuminate").configure({
                delay = 200,
                filetypes_denylist = { "NvimTree", "TelescopePrompt" },
            })
        end,
    },
    
    -- 自动检测文件类型的缩进
    {
        "tpope/vim-sleuth",
        event = { "BufReadPre", "BufNewFile" },
    },
}