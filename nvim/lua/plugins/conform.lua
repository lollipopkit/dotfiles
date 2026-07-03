return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = {
      notify_on_error = false,
      format_on_save  = {
        lsp_format = "fallback",
        timeout_ms = 2000,
      },
      formatters_by_ft = {
        go              = { "goimports" },
        rust            = { "rustfmt" },
        dart            = { "dart_format" },
        javascript      = { "prettier" },
        javascriptreact = { "prettier" },
        typescript      = { "prettier" },
        typescriptreact = { "prettier" },
        bash            = { "shfmt" },
        sh              = { "shfmt" },
        fish            = { "fish_indent" },
        lua             = { "stylua" },
        markdown        = { "prettier" },
        swift           = { "swiftformat" },
      },
    },
  },
}

