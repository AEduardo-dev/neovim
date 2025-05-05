-- Ensure lspcontainers and lspconfig are installed
local container_name = "my-rust-container"
local container_image = "rust:latest"
local lsp_config = require("lspconfig")
local lsp_containers = require("lspcontainers")

-- Function to start the persistent container
local function start_container()
  local project_root = vim.fn.getcwd()

  -- Check if the container is already running
  local status = vim.fn.system("docker ps --filter 'name=" .. container_name .. "' --format '{{.Names}}'")
  if status == "" then
    -- Start the container if it is not running
    vim.fn.system(
      "docker run -d --rm --name "
        .. container_name
        .. " -v "
        .. project_root
        .. ":/workspace "
        .. container_image
        .. " tail -f /dev/null"
    )
  end
end

-- Utility function to install Rust dependencies using cargo inside the container
local function install_rust_dependencies()
  local project_root = vim.fn.getcwd()
  vim.fn.system("docker exec " .. container_image .. " cargo build")
end

-- Function to run tools in the persistent container (needs to be global for autocmd run)
function _G.run_rust_tools()
  local project_root = vim.fn.getcwd()
  -- Run cargo fmt and cargo clippy in the persistent container
  vim.fn.system("docker exec " .. container_name .. " cargo fmt")
  vim.fn.system("docker exec " .. container_name .. " cargo clippy")
end

-- Setup for Rust Analyzer using lspcontainers
lsp_config.rust_analyzer.setup({
  cmd = lsp_container.command("rust-analyzer", {
    image = container_image, -- Use official Rust Docker image
    network_mode = "host", -- Optional: for networking
    command = { "rust-analyzer" },
  }),
  root_dir = lsp_config.util.root_pattern("Cargo.toml", ".git", vim.fn.getcwd()), -- Set project root
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true, -- Enable all features in Cargo.toml
      },
      checkOnSave = {
        command = "clippy", -- Use Clippy for linting
      },
    },
  },
  on_init = function()
    start_container()
    vim.defer_fn(install_rust_dependencies, 1000)
    vim.defer_fn(run_rust_tools, 1000)
  end,
})

-- Optional: For formatting, you can use rustfmt
-- null_ls.setup({
--   sources = {
--     -- Formatting using rustfmt from container
--     null_ls.builtins.formatting.rustfmt.with({
--       command = lspcontainers.command("rustfmt", {
--         image = container_image,
--         command = { "rustfmt" },
--       }),
--     }),
--   },
-- })

-- Automatically run linters and formatters on save for Rust files
vim.api.nvim_exec(
  [[
    autocmd BufWritePost *.rs lua run_rust_tools()
]],
  false
)
