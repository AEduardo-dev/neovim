return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false,
    },
    diagnostics = {
      float = {
        source = true,
      },
      virtual_text = {
        prefix = "icons",
        spacing = 4,
        source = true,
        -- source = "if_many",
      },
      -- virtual_text = false,
    },
    servers = {
      clangd = {},
      nil_ls = {},
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      },
      yamlls = {
        settings = {
          yaml = {
            validate = true,
            hover = true,
            completion = true,
            customTags = {
              "!reference scalar",
              "!reference mapping",
              "!reference sequence",
            },
            schemas = {
              -- GitLab CI schema:
              ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = "/.gitlab-ci.yml",
            },
          },
        },
      },
      tsserver = {
        -- Need to disable this cuz `Inline Edit` won't work otherwise
        single_file_support = false,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "literal",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              -- disable = { "missing-parameter" },
            },
            hint = {
              enable = true,
              setType = true,
              paramType = true,
              paramName = "All",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      },
      -- pyright = {},
      pylsp = {
        mason = false,
        settings = {
          pylsp = {
            plugins = {
              rope_autoimport = {
                enabled = true,
              },
            },
          },
        },
      },
      ruff_lsp = {
        handlers = {
          ["textDocument/publishDiagnostics"] = function() end,
        },
      },
      jedi_language_server = {},
      tailwindcss = {
        -- exclude a filetype from the default_config
        filetypes_exclude = { "markdown" },
        -- add additional filetypes to the default_config
        filetypes_include = {},
        -- to fully override the default_config, change the below
        -- filetypes = {}
      },
    },
  },
  setup = {
    pylsp = function()
      LazyVim.lsp.on_attach(function(client, _)
        if client.name == "pylsp" then
          -- disable hover in favor of jedi-language-server
          client.server_capabilities.hoverProvider = false
        end
      end)
    end,
    ruff_lsp = function()
      require("lazyvim.util").lsp.on_attach(function(client, _)
        if client.name == "ruff_lsp" then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end
      end)
    end,
    pyright = function()
      require("lazyvim.util").lsp.on_attach(function(client, _)
        if client.name == "pyright" then
          -- disable hover in favor of jedi-language-server
          client.server_capabilities.hoverProvider = false
        end
      end)
    end,

    tailwindcss = function(_, opts)
      local tw = LazyVim.lsp.get_raw_config("tailwindcss")
      opts.filetypes = opts.filetypes or {}

      -- Add default filetypes
      vim.list_extend(opts.filetypes, tw.default_config.filetypes)

      -- Remove excluded filetypes
      --- @param ft string
      opts.filetypes = vim.tbl_filter(function(ft)
        return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
      end, opts.filetypes)

      -- Additional settings for Phoenix projects
      opts.settings = {
        tailwindCSS = {
          includeLanguages = {
            elixir = "html-eex",
            eelixir = "html-eex",
            heex = "html-eex",
          },
        },
      }
      -- Add additional filetypes
      vim.list_extend(opts.filetypes, opts.filetypes_include or {})
    end,
  },
}
