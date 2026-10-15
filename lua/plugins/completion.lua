local servers = { "lua_ls", "pyright", "clangd", "ts_ls" }

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

      vim.lsp.enable(servers)

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
