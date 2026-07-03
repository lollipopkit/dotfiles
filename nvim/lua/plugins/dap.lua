return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "nvim-neotest/nvim-nio",
        module = "nio",
      },
      {
        "williamboman/mason.nvim",
        opts = {
          ensure_installed = {
            "python-debugpy", -- Python
            "js-debug-adapter", -- JavaScript/TypeScript
            "codelldb", -- C, C++, Rust
            "delve", -- Go
          },
        },
      },
      -- DAP UI 插件
      {
        "rcarriga/nvim-dap-ui",
        name = "dapui",
        opts = {},
      },
      -- 可选：虚拟文本显示调试信息
      -- { "theHamsta/nvim-dap-virtual-text", config = true },
    },
    keys = {
      { "<leader>Db", function() require("dap").toggle_breakpoint() end, desc = "添加/删除断点" },
      { "<leader>Dus", function() require("dapui").open() end, desc = "打开 DAP UI" },
      { "<leader>Duc", function() require("dapui").close() end, desc = "关闭 DAP UI" },
      { "<leader>Dut", function() require("dapui").toggle() end, desc = "切换 DAP UI" },
      { "<leader>Dc", function() require("dap").continue() end, desc = "继续" },
      { "<leader>Dj", function() require("dap").step_over() end, desc = "步过" },
      { "<leader>Dk", function() require("dap").step_into() end, desc = "步入" },
      { "<leader>Do", function() require("dap").step_out() end, desc = "步出" },
      { "<leader>Dr", function() require("dap").repl.open() end, desc = "打开 REPL" },
      { "<leader>Dl", function() require("dap").run_last() end, desc = "运行上次配置" },
      { "<leader>Dt", function() require("dap").terminate() end, desc = "终止" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- 设置 dap-ui 监听器以自动打开/关闭 UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- 适配器配置示例 (根据需要添加更多)
      -- 确保适配器已通过 Mason 或手动安装

      -- Python (使用 debugpy - 通过 Mason 安装: "python-debugpy")
      dap.adapters.python = {
        type = 'executable',
        -- 使用 Mason 安装的路径
        command = vim.fn.stdpath("data") .. '/mason/bin/debugpy-adapter',
        -- 或者直接指定 python 解释器路径来运行 adapter
        -- command = '/path/to/virtualenv/bin/python',
        -- args = { '-m', 'debugpy.adapter' }
      }
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = '启动文件',
          program = '${file}', -- 启动当前文件
          pythonPath = function()
            -- debugpy 支持使用与启动 debugpy 不同的解释器来启动应用程序。
            -- return '/path/to/python' -- 指定 python 解释器路径
            return vim.fn.exepath('python3') or vim.fn.exepath('python') -- 优先使用 python3，否则使用 PATH 中的 python
          end,
        },
      }

      -- Javascript/TypeScript (js-debug-adapter - 通过 Mason 安装: "js-debug-adapter")
      -- js-debug-adapter 是 server 模式，须用 pwa-node（而非旧的 node2 executable 协议）。
      -- 参考: https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter",
          args = { "${port}" },
        },
      }
      local js_ts_config = {
        {
          name = "启动当前文件",
          type = "pwa-node",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          console = "integratedTerminal",
        },
        {
          name = "附加到进程",
          type = "pwa-node",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
      }
      dap.configurations.javascript = js_ts_config
      dap.configurations.typescript = js_ts_config -- TypeScript 复用 Javascript 配置

      -- C/C++/Rust (使用 codelldb - 通过 Mason 安装: "codelldb")
      dap.adapters.codelldb = {
        type = 'executable',
        -- 使用 Mason 安装的路径
        command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
        -- 或者直接指定 codelldb 路径
        -- command = '/path/to/codelldb',
        name = 'codelldb',
      }
      local cpp_c_rust_config = {
        {
          name = "启动文件",
          type = "codelldb",
          request = "launch",
          program = function()
            -- 要求用户输入可执行文件路径
            return vim.fn.input('要调试的可执行文件路径: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {}, -- 如果需要传递命令行参数
          -- 如果需要设置环境变量
          -- env = {
          --   { name = "DEBUG", value = "1" }
          -- },
        },
      }
      dap.configurations.cpp = cpp_c_rust_config
      dap.configurations.c = cpp_c_rust_config
      dap.configurations.rust = cpp_c_rust_config

      -- Go (使用 delve - 通过 Mason 安装: "delve")
      dap.adapters.go = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
        },
      }
      dap.configurations.go = {
        {
          name = "Debug file",
          type = "go",
          request = "launch",
          program = "${file}",
        },
        {
          name = "Debug package",
          type = "go",
          request = "launch",
          program = "${fileDirname}",
        },
      }


    end,
  },
}
