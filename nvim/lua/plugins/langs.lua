return {
    {
        "mrcjkb/rustaceanvim",
        version = "^4",
        ft = { "rust" },
        dependencies = { "neovim/nvim-lspconfig" },
        init = function()
            local lsp = require("configs.lsp")
            vim.g.rustaceanvim = {
                server = {
                    on_attach = lsp.on_attach,
                    capabilities = lsp.get_capabilities(),
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                            },
                            check = {
                                command = "clippy",
                            },
                            procMacro = {
                                enable = true,
                            },
                        },
                    },
                },
                tools = {
                    hover_actions = {
                        auto_focus = true,
                        border = "rounded",
                    },
                    inlay_hints = {
                        auto = true,
                    },
                },
            }

            -- 运行/测试键位：与 Go/Dart 一致绑定到 FileType，而非 LSP attach，
            -- 保证 rust-analyzer 未安装/未就绪时 cargo 相关终端命令依然可用。
            local function set_rust_keymaps(bufnr)
                local map = function(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                end
                map("<Leader>rr", "<Cmd>terminal cargo run<CR>", "Rust run (terminal)")
                map("<Leader>rt", "<Cmd>terminal cargo test<CR>", "Rust test (terminal)")
                map("<Leader>rc", "<Cmd>terminal cargo clippy<CR>", "Rust clippy (terminal)")
                map("<Leader>rR", "<Cmd>RustLsp runnables<CR>", "Rust runnables")
                map("<Leader>rk", "<Cmd>RustLsp expandMacro<CR>", "Rust expand macro")
            end
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "rust",
                callback = function(args)
                    set_rust_keymaps(args.buf)
                end,
            })
        end,
    },
    {
        "pmizio/typescript-tools.nvim",
        ft = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = function()
            local lsp = require("configs.lsp")
            return {
                capabilities = lsp.get_capabilities(),
                on_attach = lsp.on_attach,
                settings = {
                    tsserver_file_preferences = {
                        includeCompletionsForModuleExports = true,
                        includeInlayParameterNameHints = "all",
                        includeInlayVariableTypeHints = true,
                        includeInlayFunctionParameterTypeHints = true,
                    },
                    tsserver_format_options = {
                        allowIncompleteCompletions = false,
                        allowRenameOfImportPath = true,
                    },
                    complete_function_calls = true,
                },
            }
        end,
    },
    {
        "ray-x/go.nvim",
        ft = { "go", "gomod", "gowork", "gosum" },
        dependencies = { "ray-x/guihua.lua" },
        config = function()
            require("go").setup({
                gofmt = "goimports",
                lsp_cfg = false,
                lsp_keymaps = false,
                lsp_inlay_hints = {
                    enable = true,
                },
                test_runner = "go",
                run_in_floaterm = true,
            })

            local function set_go_keymaps(bufnr)
                local map = function(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                end
                map("<Leader>rr", "<Cmd>terminal go run .<CR>", "Go run (terminal)")
                map("<Leader>rt", "<Cmd>terminal go test ./...<CR>", "Go test (terminal)")
            end

            set_go_keymaps(vim.api.nvim_get_current_buf())
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "go", "gomod", "gowork", "gosum" },
                callback = function(args)
                    set_go_keymaps(args.buf)
                end,
            })
        end,
    },
    {
        "akinsho/flutter-tools.nvim",
        ft = { "dart" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",
            "mfussenegger/nvim-dap",
        },
        config = function()
            local lsp = require("configs.lsp")
            require("flutter-tools").setup({
                debugger = {
                    enabled = true,
                },
                widget_guides = {
                    enabled = true,
                },
                closing_tags = {
                    highlight = "Comment",
                    prefix = "// ",
                },
                dev_tools = {
                    auto_open_browser = false,
                },
                lsp = {
                    on_attach = lsp.on_attach,
                    capabilities = lsp.get_capabilities(),
                    settings = {
                        dart = {
                            completeFunctionCalls = true,
                            showTodos = true,
                        },
                    },
                },
            })

            local function set_flutter_keymaps(bufnr)
                local map = function(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                end
                map("<Leader>rr", "<Cmd>FlutterRun<CR>", "Flutter run")
                map("<Leader>rt", "<Cmd>terminal flutter test<CR>", "Flutter test (terminal)")
                map("<Leader>rl", "<Cmd>FlutterReload<CR>", "Flutter reload")
                map("<Leader>rR", "<Cmd>FlutterRestart<CR>", "Flutter restart")
                map("<Leader>rd", "<Cmd>FlutterDevTools<CR>", "Flutter DevTools")
            end

            set_flutter_keymaps(vim.api.nvim_get_current_buf())
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "dart" },
                callback = function(args)
                    set_flutter_keymaps(args.buf)
                end,
            })
        end,
    },
}
