return {
  {
    "renerocksai/telekasten.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "renerocksai/calendar-vim" },
    keys = {
      -- zettelkasten
      { "<leader>z", "<cmd>Telekasten panel<CR>", desc = "+Zettelkasten" },
      -- Most used functions
      { "<leader>zf", ":lua require('telekasten').find_notes()<CR>", desc = "Find Notes" },
      { "<leader>zd", ":lua require('telekasten').find_daily_notes()<CR>", desc = "Find Dailies" },
      { "<leader>zg", ":lua require('telekasten').search_notes()<CR>", desc = "Search Notes" },
      { "<leader>zz", ":lua require('telekasten').follow_link()<CR>", desc = "Follow Link" },
      { "<leader>zT", ":lua require('telekasten').goto_today()<CR>", desc = "Goto Daily" },
      { "<leader>zW", ":lua require('telekasten').goto_thisweek()<CR>", desc = "Goto Weekly" },
      { "<leader>zw", ":lua require('telekasten').find_weekly_notes()<CR>", desc = "Find Weeklies" },
      { "<leader>zn", ":lua require('telekasten').new_note()<CR>", desc = "New Note" },
      { "<leader>zN", ":lua require('telekasten').new_templated_note()<CR>", desc = "New Templated Note" },
      { "<leader>zy", ":lua require('telekasten').yank_notelink()<CR>", desc = "Yank Noteline" },
      { "<leader>zc", ":lua require('telekasten').show_calendar()<CR>", desc = "Show Cal" },
      { "<leader>zC", ":CalendarT<CR>", desc = "Calendar" },
      { "<leader>zi", ":lua require('telekasten').paste_img_and_link()<CR>", desc = "Paste img & Link" },
      { "<leader>zt", ":lua require('telekasten').toggle_todo()<CR>", desc = "Toggle Todo" },
      { "<leader>zb", ":lua require('telekasten').show_backlinks()<CR>", desc = "Show Backlinks" },
      { "<leader>zF", ":lua require('telekasten').find_friends()<CR>", desc = "Find Friends" },
      { "<leader>zI", ":lua require('telekasten').insert_img_link({ i=true })<CR>", desc = "Insert IMG link" },
      { "<leader>zp", ":lua require('telekasten').preview_img()<CR>", desc = "Preview img" },
      { "<leader>zm", ":lua require('telekasten').browse_media()<CR>", desc = "Browse Media" },
      { "<leader>za", ":lua require('telekasten').show_tags()<CR>", desc = "Show Tags" },
      { "<leader>#", ":lua require('telekasten').show_tags()<CR>", desc = "Show Tags" },
      { "<leader>zr", ":lua require('telekasten').rename_note()<CR>", desc = "Rename Note" },
      { "<leader>zl", "<cmd>Telekasten insert_link<CR>", desc = "Insert Link" },
    },
  },
}
