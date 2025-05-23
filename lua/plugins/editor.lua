return {
  -- Change default permissions for files created via Neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },

  -- Modify gitsigns
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = false,
      numhl = true,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        map("n", "<leader>ght", gs.toggle_current_line_blame, "Toggle Blame Line")
      end,
    },
  },

  -- Modify `flash.nvim`
  {
    "folke/flash.nvim",
    -- keys = {
    --   -- Disable default mappings, cuz they conflict with `vim-surround`
    --   { "s", mode = { "n", "x", "o" }, false },
    --   { "S", mode = { "n", "x", "o" }, false },
    --   {
    --     "m",
    --     mode = { "n", "x", "o" },
    --     function()
    --       require("flash").jump()
    --     end,
    --     desc = "Flash",
    --   },
    --   {
    --     "M",
    --     mode = { "n", "o", "x" },
    --     function()
    --       require("flash").treesitter()
    --     end,
    --     desc = "Flash Treesitter",
    --   },
    -- },
    opts = {
      modes = {
        -- Modify options used by `flash` when doing `f`, `F`, `t`, `T` motions
        char = {
          jump_labels = true,
        },
      },
    },
  },

  -- Try out `fzf-lua`
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    opts = function(_, opts)
      -- INFO:
      --  ╭──────────────────────────────────────────────────────────────────────────╮
      --  │ Use this instead of `keymap.builtin` and `keymap.fzf`, because if you    │
      --  │ declare the keybindings in those tables, they will override the defaults │
      --  │ and you need to add the default missing ones.                            │
      --  ╰──────────────────────────────────────────────────────────────────────────╯

      -- opts.keymap = vim.tbl_deep_extend("force", require("fzf-lua").defaults.keymap, {
      --   fzf = {
      --     ["ctrl-q"] = "select-all+accept",
      --   },
      -- })
      opts.winopts = {
        on_create = function()
          vim.keymap.set("t", "<C-d>", function()
            require("fzf-lua.win").preview_scroll("line-down")
          end, { buffer = 0, noremap = true })
          vim.keymap.set("t", "<C-u>", function()
            require("fzf-lua.win").preview_scroll("line-up")
          end, { buffer = 0, noremap = true })
          vim.keymap.set("t", "<A-d>", function()
            require("fzf-lua.win").preview_scroll("page-down")
          end, { buffer = 0, noremap = true })
          vim.keymap.set("t", "<A-u>", function()
            require("fzf-lua.win").preview_scroll("page-up")
          end, { buffer = 0, noremap = true })
          vim.keymap.set("t", "<C-j>", "<down>", { buffer = 0, noremap = true })
          vim.keymap.set("t", "<C-k>", "<up>", { buffer = 0, noremap = true })
        end,
      }
    end,
  },
}
