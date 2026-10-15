-- C/C++: compile the program with `-g -O0` (e.g. `g++ -g -O0 main.cpp -o main`).
-- Without debug info (-g) breakpoints can't map to source lines, and with
-- optimizations on, stepping jumps around and variables show as "optimized out".

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: continue / start" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "codelldb" },
        handlers = {
          -- Register only the adapter: the default handler also appends its own launch
          -- configurations, which would duplicate the ones defined below
          function(config)
            config.configurations = nil
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })

      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      dap.configurations.cpp = {
        {
          name = "Launch executable",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = dap.configurations.cpp

      dap.configurations.python = {
        {
          name = "Run current file",
          type = "python",
          request = "launch",
          program = "${file}",
          -- Debug with the active virtualenv's interpreter, if any. On Windows venvs use
          -- Scripts\python.exe, and `python3` is usually the Microsoft Store stub.
          pythonPath = function()
            local is_win = vim.fn.has("win32") == 1
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return is_win and (venv .. "\\Scripts\\python.exe") or (venv .. "/bin/python")
            end
            return is_win and "python" or "python3"
          end,
        },
      }
    end,
  },
}
