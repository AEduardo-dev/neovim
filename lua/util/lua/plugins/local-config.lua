return {
  {
    "klen/nvim-config-local",
    config = function()
      require("config-local").setup({
        config_files = { ".nvim.lua", ".nvim.json" }, -- Detect config files
        autocommands_create = true, -- Automatically create autocommands
        commands_create = true, -- Create Ex commands for manual loading
        silent = false, -- Notify when loading the local config
        lookup_parents = false, -- Stop at the root directory, don't check parent dirs
      })
    end,
  },
}
