return { {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = {
        "NvimTreeToggle",
        "NvimTreeFocus",
        "NvimTreeOpen",
        "NvimTreeFindFile",
        "NvimTreeFindFileToggle",
    },
    init = function()
        local function buf_opt(buf, key)
            if not buf or buf == 0 or not vim.api.nvim_buf_is_valid(buf) then
                return ""
            end
            local ok, value = pcall(function()
                return vim.bo[buf][key]
            end)
            return ok and value or ""
        end

        local function should_open(data)
            local directory = data.file ~= "" and vim.fn.isdirectory(data.file) == 1
            local buftype = buf_opt(data.buf, "buftype")
            local filetype = buf_opt(data.buf, "filetype")
            local no_name = data.file == "" and buftype == ""
            local ignored = filetype == "gitcommit"
            if ignored then
                return false
            end
            return directory or no_name
        end

        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function(data)
                if not should_open(data) then
                    return
                end

                vim.schedule(function()
                    require("lazy").load({ plugins = { "nvim-tree.lua" } })
                    local api = require("nvim-tree.api")

                    local directory = data.file ~= "" and vim.fn.isdirectory(data.file) == 1
                    if directory then
                        vim.fn.chdir(data.file)
                        api.tree.change_root(data.file)
                    end

                    api.tree.open()
                end)
            end,
        })
    end,
    opts = {
        view = {
            width = 37
        },
        filters = {
            dotfiles = false
        },
        hijack_directories = {
            enable = true,
            auto_open = true -- 打开 nvim 时如果是目录就自动展开树
        },
        update_focused_file = {
            enable = true,
            update_root = true
        },
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        renderer = {
            group_empty = true
        },
        -- 关闭对 .gitignore 中声明文件的隐藏
        git = {
            enable  = true, -- 保持开启 Git 状态显示
            ignore  = false, -- 不隐藏 Git 忽略的文件
            timeout = 500, -- 可选：Git 状态查询超时
        },
    },
    config = function(_, opts)
        require("nvim-tree").setup(opts)
    end,
} }
