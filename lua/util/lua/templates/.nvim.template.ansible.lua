-- Ensure lspconfig and lspcontainers are installed
local container_image = "quay.io/ansible/ansible-runner:latest"
local container_name = "my-ansible-container"
local lsp_config = require("lspconfig")
local lsp_container = require("lspcontainers")

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

-- Utility function to install Ansible Galaxy roles/collections
local function install_ansible_dependencies()
  local project_root = vim.fn.getcwd()
  local requirements_file = project_root .. "/requirements.yml"

  -- Install roles or collections using ansible-galaxy if requirements.yml exists
  if vim.fn.filereadable(requirements_file) == 1 then
    vim.fn.system(
      "docker run --rm -v "
        .. project_root
        .. ":/workspace -w /workspace "
        .. container_image
        .. " ansible-galaxy install -r requirements.yml"
    )
  end
end

-- Function to run tools in the persistent container (needs to be global for autocmd run)
function _G.run_ansible_lint()
  local project_root = vim.fn.getcwd()
  vim.fn.system("docker exec " .. container_name .. " ansible-lint /workspace/*.yml")
end

-- Setup for Ansible LSP using lsp_container with dependency installation
lsp_config.ansiblels.setup({
  cmd = lsp_container.command("ansible-language-server", {
    image = container_image, -- Official Ansible Docker image
    network_mode = "host", -- Optional: for networking
    command = { "ansible-language-server", "--stdio" },
  }),
  root_dir = lsp_config.util.root_pattern("ansible.cfg", ".git", vim.fn.getcwd()), -- Set project root to ansible.cfg or git repo root
  settings = {
    ansible = {
      ansible = {
        path = "/usr/local/bin/ansible", -- Path to Ansible binary inside the container
      },
      executionEnvironment = {
        enabled = false, -- Disable automatic execution environment unless desired
      },
      python = {
        interpreterPath = "/usr/bin/python3", -- Python interpreter path inside the container
      },
    },
  },
  on_init = function()
    -- Install dependencies when the LSP starts
    start_container() -- Start the container
    vim.defer_fn(install_ansible_dependencies, 1000) -- Delay execution to avoid blocking
    vim.defer_fn(run_ansible_lint, 1000) -- Delay execution to avoid blocking
  end,
})

-- Automatically run ansible-lint on save for YAML files
vim.api.nvim_exec(
  [[
    autocmd BufWritePost *.yml,*.yaml lua run_ansible_lint()
]],
  false
)
