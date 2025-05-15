return {
  {
    "vimwiki/vimwiki",
    keys = {
      { "<leader>ww", "<cmd>VimwikiIndex<cr>", desc = "Open Vimwiki" },
    },
    opts = {
      path = "~/vimwiki/",
      syntax = "markdown",
      ext = ".md",
    },
  },
}
