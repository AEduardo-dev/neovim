-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local usercmd = vim.api.nvim_create_user_command

--[[ -------------
     AUTO COMMANDS
     ------------- ]]

-- Prefer creating groups and assigning autocmds to groups, because it makes it easier to clear them
--[[ Mygroup Group ]]
augroup("mygroup", { clear = true })

autocmd("FileType", {
  group = "lazyvim_close_with_q",
  pattern = {
    "aerial-nav",
    "ClangdAST",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Local Configuration
-- Function to load local config on startup
function _G.load_local_config() end

-- Create an autocommand that runs on VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.notify("triggered")
    local config_files = { ".nvim.lua", ".nvim.json" }
    local cwd = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n$", "")

    for _, file in ipairs(config_files) do
      local full_path = cwd .. "/" .. file
      print(full_path)
      if vim.fn.filereadable(full_path) == 1 then
        vim.notify("Loading local config: " .. file)
        vim.cmd("source " .. full_path)
        break
      end
    end
  end,
})

--Filetype
autocmd("Filetype", {
  pattern = { "*" },
  callback = function()
    -- vim.opt.formatoptions = vim.opt.formatoptions - "o"
    if vim.bo["ft"] == "css" then
      vim.opt_local.formatoptions:remove("r") -- don't enter comment leader on Enter in css files
    end
    vim.opt.formatoptions = vim.opt.formatoptions + {
      o = false, -- Don't continue comments with o and O
    }
  end,
  group = "mygroup",
  desc = "Don't continue comments with o and O",
})

-- Ansible file pattern
autocmd({ "BufRead", "BufNewFile", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("Ansible", { clear = true }),
  pattern = {
    "**/ansible/**/*.yml",
    "**/ansible**/*.yaml",
  },
  callback = function()
    vim.opt.filetype = "yaml.ansible"
  end,
})
-- Reload config on save
autocmd("BufWritePost", {
  -- Match all `lua` files in `lua/config` except `lazy.lua` which is the
  -- setup file for `lazy.nvim` and should only be reloaded when updated.
  pattern = "**/lua/config/*[^lazy].lua",
  callback = function()
    local filepath = vim.fn.expand("%")
    dofile(filepath)
    vim.notify("Configuration reloaded \n" .. filepath, nil)
  end,
  group = "mygroup",
  desc = "Reload config on save",
})

-- ToggleTerm
function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
autocmd("TermOpen", {
  pattern = "term://*toggleterm#*",
  callback = function()
    set_terminal_keymaps()
  end,
  group = "mygroup",
  desc = "Set terminal mappings for ToggleTerm",
})

autocmd("BufEnter", {
  pattern = "term://*toggleterm#*",
  callback = function()
    -- INFO:
    -- vim.schedule function is needed to make sure the buffer terminal is entered
    -- and `pattern` recognized
    vim.schedule(function()
      vim.cmd.startinsert()
    end)
  end,
  group = "mygroup",
  desc = "Insert mode on TermEnter (toggleterm)",
})

autocmd("BufLeave", {
  pattern = "term://*toggleterm#*",
  callback = function()
    vim.o.cursorline = false
  end,
  group = "mygroup",
  desc = "Don't show cursor line on BufLeave (toggleterm)",
})

--[[ Remember Folds Group ]]
augroup("remember_folds", { clear = true })

autocmd({ "BufLeave", "BufWinLeave" }, {
  pattern = "*",
  callback = function()
    vim.cmd("silent! mkview")
  end,
  group = "remember_folds",
  desc = "Remember folds on buffer exit",
})

autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    vim.cmd("silent! loadview")
  end,
  group = "remember_folds",
  desc = "Restore folds on buffer enter",
})

--[[ Toggle relative line numbers ]]
augroup("ToggleLineNumbers", { clear = true })
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
  group = "ToggleLineNumbers",
  callback = function()
    if vim.o.nu and vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
  desc = "Toggle line numbers on when focus",
})

autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
  group = "ToggleLineNumbers",
  callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = false
    end
  end,
  desc = "Toggle line numbers off when not focus",
})

--[[ Open plugin repos with gx ]]
autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("GxWithPlugins", { clear = true }),
  callback = function()
    if vim.fn.getcwd() == vim.fn.stdpath("config") then
      vim.keymap.set("n", "gx", function()
        local file = vim.fn.expand("<cfile>") --[[@as string]]

        -- First try the default behavior
        -- see https://github.com/neovim/neovim/blob/b0f9228179bf781eec76d1aaf346b56a7e64cd5d/runtime/lua/vim/_defaults.lua#L101
        -- for recent changes in `vim.ui.open`
        local cmd, err = vim.ui.open(file)
        local rv = cmd and cmd:wait(1000) or nil
        if cmd and rv and rv.code ~= 0 then
          err = ("vim.ui.open: command %s (%d): %s"):format(
            (rv.code == 124 and "timeout" or "failed"),
            rv.code,
            vim.inspect(cmd.cmd)
          )
        end
        if not err then
          return
        end

        -- Consider anything that looks like string/string a GitHub link.
        local link = file:match("%w[%w%-]+/[%w%-%._]+")
        if link then
          vim.ui.open("https://www.github.com/" .. link)
          err = nil
        end

        -- Else show the error
        if err then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end, { desc = "Open filepath or URI under cursor" })
    end
  end,
  desc = "Make `gx` open repos in default browser",
})

--[[ Disable `mini.indentscope` for specific filetypes ]]
autocmd("FileType", {
  pattern = { "fzf", "lspinfo" },
  group = augroup("DisableIndentScope", { clear = true }),
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
  desc = "Disable `mini.indentscope` for specific filetypes",
})

--[[ vim-visual-multi with Lualine ]]
autocmd({ "User" }, {
  pattern = "visual_multi_start",
  callback = function()
    require("lualine").hide()
    vim.g.VM_cmdheight = 1
  end,
})

-- rust save and format
autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

autocmd({ "User" }, {
  pattern = "visual_multi_exit",
  callback = function()
    require("lualine").hide({ unhide = true })
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "debian/rules",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 8
    vim.bo.shiftwidth = 8
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.c", ".h", ".cpp", ".hpp" },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})

--[[ -------------
     USER COMMANDS
     ------------- ]]

usercmd("Rwd", function()
  print(LazyVim.root.get())
end, { desc = "Print root_dir of current buffer" })

--[[ User command for diffing current buffer when not in .git repo ]]
usercmd("DiffOrig", function()
  local scratch_buffer = vim.api.nvim_create_buf(false, true)
  local current_ft = vim.bo.filetype
  vim.cmd("vertical sbuffer" .. scratch_buffer)
  vim.bo[scratch_buffer].filetype = current_ft
  vim.cmd("read ++edit #") -- load contents of previous buffer into scratch_buffer
  vim.cmd.normal('1G"_d_') -- delete extra newline at top of scratch_buffer without overriding register
  vim.cmd.diffthis() -- scratch_buffer
  vim.cmd.wincmd("p")
  vim.cmd.diffthis() -- current buffer
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = scratch_buffer, silent = true })
end, { desc = "Diff current buffer not .git" })
