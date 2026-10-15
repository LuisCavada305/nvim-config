return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- load before other UI plugins so they pick up its highlights
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  {
    -- `main` branch: the old `master` (configs.setup/ensure_installed) is archived.
    -- Parsers are compiled with the tree-sitter CLI; highlighting is started per buffer.
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "lua", "python", "c", "cpp", "cuda", "javascript", "typescript",
        "tsx", "json", "yaml", "markdown", "bash",
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function(args)
          -- pcall: no-op for filetypes without an installed parser
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>a", group = "ai/claude" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunk" },
        { "<leader>r", group = "rename" },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = "auto", globalstatus = true },
    },
  },
}
