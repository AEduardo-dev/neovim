local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local container_image = "python:3.11"
local container_name = "my-python-container"
local lsp_config = require("lspconfig")
local lsp_containers = require("lspcontainers")
local navic = require("nvim-navic")
local null_ls = require("null-ls")
local util = require("lspconfig.util")

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

-- Function to run tools in the persistent container (needs to be global for autocmd run)
function _G.run_python_tools()
  local project_root = vim.fn.getcwd()
  vim.fn.system("docker exec " .. container_name .. " black /workspace")
  vim.fn.system("docker exec " .. container_name .. " isort /workspace")
  vim.fn.system("docker exec " .. container_name .. " mypy /workspace")
end

-- Utility function to install dependencies in the container
local function install_python_dependencies()
  local project_root = vim.fn.getcwd() -- Get the current working directory
  local requirements_file = project_root .. "/requirements.txt"
  local pyproject_file = project_root .. "/pyproject.toml"

  -- Check for requirements.txt or pyproject.toml and install dependencies inside the container
  if vim.fn.filereadable(requirements_file) == 1 then
    vim.fn.system("docker exec " .. container_name .. " pip install -r requirements.txt")
  elseif vim.fn.filereadable(pyproject_file) == 1 then
    vim.fn.system("docker exec " .. project_root .. " poetry install")
  end
end

-- Setup for Python LSP using lspcontainers
lsp_config.pyright.setup({
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = lsp_container.command("pyright", {
    image = container_image, -- Use Python 3.11 Docker image
    network_mode = "host", -- Optional: set Docker network mode
    command = { "pyright-langserver", "--stdio" },
  }),
  root_dir = lsp_config.util.root_pattern(".git", vim.fn.getcwd()), -- Set project root
  settings = {
    python = {
      pythonPath = "/usr/local/bin/python", -- Path to Python binary inside the container
    },
  },
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  },
  on_init = function()
    start_container()
    -- Run dependency installation when LSP starts
    vim.defer_fn(install_python_dependencies, 1000) -- Delay execution to avoid blocking
    vim.defer_fn(run_python_tools, 1000) -- Delay execution to avoid blocking
  end,
})

-- Automatically run linters and formatters on save for Python files
vim.api.nvim_exec(
  [[
    autocmd BufWritePost *.py lua run_python_tools()
]],
  false
)
