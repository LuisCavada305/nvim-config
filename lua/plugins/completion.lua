local servers = { "lua_ls", "basedpyright", "ty", "ruff", "clangd", "ts_ls", "gopls" }

return {
  -- Mason puts its bin/ on PATH, so servers it installs are found by vim.lsp.enable
  { "mason-org/mason.nvim", cmd = "Mason", opts = {} },

  {
    "neovim/nvim-lspconfig", -- provides the lsp/<server>.lua defaults read by vim.lsp.config
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = false, -- enabled explicitly below
      })

      -- Native API (Neovim >= 0.11): '*' merges into every server's config
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            -- Makes `vim.*` known without an extra plugin
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
          },
        },
      })

      -- ruff handles lint, import sorting and formatting; ty is the type checker (and hover)
      vim.lsp.config("ruff", {
        on_attach = function(client) client.server_capabilities.hoverProvider = false end,
      })

      -- basedpyright (fork of pyright) instead of pyright: it adds the "Import X from Y" code
      -- action on an undefined name (<leader>ca), which upstream pyright only has in Pylance.
      -- Auto-import also comes in completion: confirming an item inserts its import.
      -- Use the project's .venv. In a uv workspace it sits at the workspace root,
      -- above the member's pyproject.toml that basedpyright picks as root_dir, so search upward.
      -- Type checking is ty's job (below): with both on, the same mistake shows twice and the two
      -- disagree. basedpyright stays only for completion and the add-import code action.
      vim.lsp.config("basedpyright", {
        on_attach = function(client) client.server_capabilities.hoverProvider = false end,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "off",
              autoImportCompletions = true,
            },
          },
        },
        before_init = function(_, config)
          local venv = config.root_dir and vim.fs.root(config.root_dir, ".venv")
          if not venv then return end
          local bin = vim.fn.has("win32") == 1 and "/.venv/Scripts/python.exe" or "/.venv/bin/python"
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            python = { pythonPath = venv .. bin },
          })
        end,
      })

      -- ty: the same checker as the project's gate (`uv run ty check`). Prefer the ty in the
      -- project's .venv so the editor and the gate run the same version; Mason's is the fallback.
      vim.lsp.config("ty", {
        cmd = function(dispatchers, config)
          local exe = "ty"
          local venv = config and config.root_dir and vim.fs.root(config.root_dir, ".venv")
          if venv then
            local bin = vim.fn.has("win32") == 1 and "/.venv/Scripts/ty.exe" or "/.venv/bin/ty"
            if vim.uv.fs_stat(venv .. bin) then exe = venv .. bin end
          end
          return vim.lsp.rpc.start({ exe, "server" }, dispatchers, {
            cwd = config and config.root_dir or nil,
          })
        end,
      })

      vim.lsp.enable(servers)

      -- Go: gofmt via gopls on save (the Go convention; nobody hand-formats Go)
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("go-format-on-save", { clear = true }),
        pattern = "*.go",
        callback = function(args)
          vim.lsp.buf.format({ bufnr = args.buf, name = "gopls", timeout_ms = 2000 })
        end,
      })

      -- Format Python with ruff on save (fix lint issues and sort imports first)
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("ruff-format-on-save", { clear = true }),
        pattern = "*.py",
        callback = function(args)
          vim.lsp.buf.code_action({
            context = { only = { "source.fixAll.ruff", "source.organizeImports.ruff" }, diagnostics = {} },
            apply = true,
          })
          vim.lsp.buf.format({ bufnr = args.buf, name = "ruff", timeout_ms = 2000 })
        end,
      })

      -- Neovim 0.11+ ships global gr* LSP maps (grr, grn, gra...). With `gr` mapped below,
      -- they would make `gr` wait for 'timeoutlen'; remove them since we have our own.
      for _, lhs in ipairs({ "grr", "grn", "gri", "grt", "grx" }) do
        pcall(vim.keymap.del, "n", lhs)
      end
      pcall(vim.keymap.del, { "n", "x" }, "gra")

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach-keymaps", { clear = true }),
        callback = function(args)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", function() require("telescope.builtin").lsp_references() end, "References")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action,
            { buffer = args.buf, desc = "Code action" })
        end,
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp", -- needed for LSP snippet regex transforms
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          -- select=false: Enter only confirms an item you explicitly selected
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" }, -- only when the sources above have nothing
        }),
      })
    end,
  },
}
