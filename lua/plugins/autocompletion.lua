return {
  -- Autocompletion setup
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  -- LSP and language server setup
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim", -- Easily install and manage LSP servers
      "mason-org/mason-lspconfig.nvim", -- Bridge between lspconfig and Mason
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ansiblels", -- Ansible
          "bashls", -- Bash
          "clangd", -- C/C++
          "pyright", -- Python
          "rust_analyzer", -- Rust
          "yamlls", -- YAML
        },
      })

      local lspconfig = require("lspconfig")

      -- LSP server configurations
      lspconfig.ansiblels.setup({})
      lspconfig.bashls.setup({})
      lspconfig.clangd.setup({})
      lspconfig.pyright.setup({})
      lspconfig.rust_analyzer.setup({})
      lspconfig.yamlls.setup({
        settings = {
          yaml = {
            schemas = {
              ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = ".gitlab-ci.yml",
            },
          },
        },
      })
    end,
  },

  -- Optional: Additional tools for languages
  {
    "mfussenegger/nvim-lint", -- Lightweight linting
    config = function()
      local lint = require("lint")
      -- Override yamllint parser to ignore false positives
      lint.linters_by_ft = {
        bash = { "shellcheck" },
        c = { "cppcheck" },
        cpp = { "cppcheck" },
        python = { "pylint" },
        -- Add other linters as needed
      }
    end,
  },

  -- Optional: Snippet collection for LuaSnip
  {
    "rafamadriz/friendly-snippets",
    dependencies = { "L3MON4D3/LuaSnip" },
  },
}
