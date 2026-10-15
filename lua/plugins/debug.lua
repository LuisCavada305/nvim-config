-- C/C++: compile the program with `-g -O0` (e.g. `g++ -g -O0 main.cpp -o main`).
-- Without debug info (-g) breakpoints can't map to source lines, and with
-- optimizations on, stepping jumps around and variables show as "optimized out".
--
-- APIs: <F5> lists the server configurations below (FastAPI/Litestar, Flask, Django, npm
-- script...). The server keeps running until stopped with <leader>dq, which only detaches
-- (leaving the server up) when attached to one started outside nvim. A project's .vscode/launch.json,
-- if present, is also read by nvim-dap and its entries show up in the same list.

local is_win = vim.fn.has("win32") == 1

-- Interpreter for debugging: the active virtualenv, else a .venv/venv in the project,
-- else the system one. On Windows venvs use Scripts\python.exe, and `python3` is
-- usually the Microsoft Store stub.
local function python_path()
  local bin = is_win and "/Scripts/python.exe" or "/bin/python"
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    return venv .. bin
  end
  for _, dir in ipairs({ ".venv", "venv" }) do
    local candidate = vim.fn.getcwd() .. "/" .. dir .. bin
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return is_win and "python" or "python3"
end

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
      {
        "<leader>dq",
        function()
          local dap = require("dap")
          local session = dap.session()
          -- Attached to a server started outside nvim: detach and leave it running
          if session and session.config.request == "attach" then
            dap.disconnect({ terminateDebuggee = false })
          else
            dap.terminate()
          end
        end,
        desc = "Stop debugging (detach if attached)",
      },
      { "<leader>dr", function() require("dap").run_last() end, desc = "Rerun last configuration" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      {
        "<leader>dc",
        function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
        desc = "Conditional breakpoint",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "codelldb", "js" },
        handlers = {
          -- Register only the adapter: the default handler also appends its own launch
          -- configurations, which would duplicate the ones defined below
          function(config)
            config.configurations = nil
            require("mason-nvim-dap").default_setup(config)
          end,
          python = function() end, -- adapter defined below
        },
      })

      -- Launch: run debugpy's adapter from mason's venv (avoids the .cmd shim on Windows).
      -- Attach: a server started with `debugpy --listen` already speaks DAP, so connect
      -- to it directly instead of spawning a second adapter.
      dap.adapters.python = function(callback, config)
        if config.request == "attach" then
          local connect = config.connect or {}
          callback({
            type = "server",
            host = connect.host or "127.0.0.1",
            port = connect.port or 5678,
            options = { source_filetype = "python" },
          })
        else
          local venv = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv"
          callback({
            type = "executable",
            command = venv .. (is_win and "/Scripts/python.exe" or "/bin/python"),
            args = { "-m", "debugpy.adapter" },
            options = { source_filetype = "python" },
          })
        end
      end

      -- mason-nvim-dap installs js-debug-adapter but has no adapter mapping for it.
      -- Running its server script through node avoids spawning a .cmd shim on Windows.
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close
      dap.listeners.before.disconnect["dapui_config"] = dapui.close

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

      -- Auto-reload is off in the server configs: the reloader runs the app in a child
      -- process, where breakpoints would not be hit. Restart with <leader>dr after edits.
      dap.configurations.python = {
        {
          name = "Run current file",
          type = "python",
          request = "launch",
          program = "${file}",
          pythonPath = python_path,
        },
        {
          name = "API: ASGI via uvicorn (FastAPI, Litestar, Starlette)",
          type = "python",
          request = "launch",
          module = "uvicorn",
          args = function()
            local app = vim.fn.input("App (module:variable): ", "main:app")
            local port = vim.fn.input("Port: ", "8000")
            return { app, "--port", port }
          end,
          cwd = "${workspaceFolder}",
          pythonPath = python_path,
          justMyCode = true,
        },
        {
          name = "API: Flask",
          type = "python",
          request = "launch",
          module = "flask",
          args = function()
            local app = vim.fn.input("App (module): ", "app")
            local port = vim.fn.input("Port: ", "5000")
            return { "--app", app, "run", "--no-debugger", "--no-reload", "--port", port }
          end,
          cwd = "${workspaceFolder}",
          pythonPath = python_path,
          jinja = true,
        },
        {
          name = "API: Django (manage.py runserver)",
          type = "python",
          request = "launch",
          program = "${workspaceFolder}/manage.py",
          args = function()
            return { "runserver", "--noreload", vim.fn.input("Port: ", "8000") }
          end,
          cwd = "${workspaceFolder}",
          pythonPath = python_path,
          django = true,
        },
        {
          -- For a server started outside nvim with:
          --   python -m debugpy --listen 5678 -m uvicorn main:app
          name = "Attach to debugpy (port 5678)",
          type = "python",
          request = "attach",
          connect = { host = "127.0.0.1", port = 5678 },
          pathMappings = { { localRoot = "${workspaceFolder}", remoteRoot = "." } },
        },
      }

      local js_configs = {
        {
          name = "Run current file (node)",
          type = "pwa-node",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
        {
          -- Runs `npm run <script>` (e.g. dev/start), so TS servers with tsx/ts-node/nodemon
          -- work as configured in package.json
          name = "API: npm run <script>",
          type = "pwa-node",
          request = "launch",
          runtimeExecutable = "npm",
          runtimeArgs = function()
            return { "run", vim.fn.input("npm script: ", "dev") }
          end,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          console = "integratedTerminal",
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
        {
          -- For a server started outside nvim with `node --inspect app.js`
          name = "Attach to node process",
          type = "pwa-node",
          request = "attach",
          processId = function() return require("dap.utils").pick_process() end,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
      }
      for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[ft] = js_configs
      end
    end,
  },
}
