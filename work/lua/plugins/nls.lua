return {
  {
    "nvim-tools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources, {
        nls.builtins.formatting.prettierd.with({
          extra_args = {
            "--trailing-comma=all",
            "--single-quote=true",
            "--semi=true",
            "--tab-width=2",
            "--print-width=80",
            "--single-attribute-per-line=true",
            "--comma-dangle=always-multiline",
          },
        }),
        nls.builtins.formatting.stylua,
        nls.builtins.diagnostics.mypy,
      })
    end,
  },
}
