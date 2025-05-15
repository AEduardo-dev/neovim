return {
  -- PlantUML syntax highlighting and support
  {
    "aklt/plantuml-syntax",
    ft = { "plantuml" },
  },
  -- Preview support for PlantUML diagrams
  {
    "weirongxu/plantuml-previewer.vim",
    ft = { "plantuml" },
    dependencies = { "tyru/open-browser.vim" },
  },
}
