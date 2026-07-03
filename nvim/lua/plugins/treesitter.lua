return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- main 分支支持 Neovim 0.11+/0.12（master 不支持 0.12）
    lazy   = false,
    build  = ":TSUpdate",
    config = function()
      local langs = {
        "bash", "fish", "go", "gomod", "rust", "dart",
        "lua", "javascript", "typescript", "tsx", "swift",
        "dockerfile", "markdown", "markdown_inline",
        "json", "yaml", "toml",
      }

      local ts = require("nvim-treesitter")
      ts.setup()

      -- 安装缺失的解析器（异步；已装的跳过）
      local installed = {}
      for _, l in ipairs(ts.get_installed()) do installed[l] = true end
      local todo = {}
      for _, l in ipairs(langs) do
        if not installed[l] then todo[#todo + 1] = l end
      end
      if #todo > 0 then ts.install(todo) end

      -- 高亮 + 缩进：main 分支不再有 highlight/indent 模块，改为按 FileType 启用
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nvim_treesitter_start", { clear = true }),
        callback = function(args)
          local ft   = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          -- 仅在解析器可用时启用，避免无解析器的 filetype 报错
          local ok, loaded = pcall(vim.treesitter.language.add, lang)
          if ok and loaded then
            pcall(vim.treesitter.start, args.buf, lang)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- 增量选择（main 分支已移除该模块，用 vim.treesitter 复刻）
      -- gnn 起始 / grn 扩展到父节点 / grm 缩小
      local sel = setmetatable({}, { __mode = "k" }) -- window -> 节点栈

      local function same_range(a, b)
        local a1, a2, a3, a4 = a:range()
        local b1, b2, b3, b4 = b:range()
        return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
      end

      local function visual_set(node)
        local sr, sc, er, ec = node:range()
        -- 若已在 visual 模式，先退回普通模式，否则下面的 `v` 会把选区切掉
        if vim.fn.mode() ~= "n" then
          vim.cmd("normal! \27") -- <Esc>
        end
        vim.fn.setpos(".", { 0, sr + 1, sc + 1, 0 })
        vim.cmd("normal! v")
        local col
        if ec == 0 and er > 0 then
          er  = er - 1
          col = #(vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1] or "") + 1
        else
          col = ec
        end
        vim.fn.setpos(".", { 0, er + 1, math.max(col, 1), 0 })
      end

      local function ts_init()
        local ok, parser = pcall(vim.treesitter.get_parser, 0)
        if not ok or not parser then return end
        parser:parse() -- 确保已解析，否则首帧 get_node 可能为 nil
        local node = vim.treesitter.get_node()
        if not node then return end
        sel[vim.api.nvim_get_current_win()] = { node }
        visual_set(node)
      end

      local function ts_grow()
        local win   = vim.api.nvim_get_current_win()
        local stack = sel[win]
        if not stack then return ts_init() end
        local cur    = stack[#stack]
        local parent = cur:parent()
        while parent and same_range(parent, cur) do parent = parent:parent() end
        if parent then
          stack[#stack + 1] = parent
          visual_set(parent)
        else
          visual_set(cur)
        end
      end

      local function ts_shrink()
        local stack = sel[vim.api.nvim_get_current_win()]
        if not stack or #stack <= 1 then return end
        table.remove(stack)
        visual_set(stack[#stack])
      end

      local map = vim.keymap.set
      map("n", "gnn", ts_init, { silent = true, desc = "TS 增量选择：起始" })
      map("x", "grn", ts_grow, { silent = true, desc = "TS 增量选择：扩展到父节点" })
      map("x", "grm", ts_shrink, { silent = true, desc = "TS 增量选择：缩小" })
    end,
  },
}
