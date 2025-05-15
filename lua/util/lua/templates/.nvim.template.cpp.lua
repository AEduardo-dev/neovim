-- Ensure lspcontainers, lspconfig, and null-ls are installed
local container_name = "my-cpp-container"
local container_image = "gcc:latest"
local lsp_config = require("lspconfig")
local lsp_containers = require("lspcontainers")
local null_ls = require("null-ls")

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

-- Utility function to build the project and generate compile_commands.json
local function build_cpp_project()
  local project_root = vim.fn.getcwd()
  vim.fn.system(
    "docker exec " .. container_name .. " cmake -B build -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build"
  )
end

function _G.run_cpp_tools()
  local project_root = vim.fn.getcwd()
  -- Run clang-tidy and clang-format in the persistent container
  vim.fn.system("docker exec " .. container_name .. ' clang-tidy $(find /workspace -name "*.cpp")')
  vim.fn.system("docker exec " .. container_name .. ' clang-format -i $(find /workspace -name "*.cpp")')
end

-- Setup for clangd using lsp_container with compile_commands.json
lsp_config.clangd.setup({
  cmd = lsp_container.command("clangd", {
    image = container_image, -- Use Docker image
    network_mode = "host", -- Optional: for networking
    command = { "clangd", "--background-index", "--clang-tidy" },
  }),
  root_dir = lsp_config.util.root_pattern("CMakeLists.txt", "compile_commands.json", ".git", vim.fn.getcwd()),
  capabilities = lsp_config.util.default_config.capabilities,
  on_init = function()
    -- Build the project and generate compile_commands.json
    start_container() -- Start the container
    vim.defer_fn(build_cpp_project, 1000) -- Delay execution to avoid blocking
    vim.defer_fn(run_cpp_tools, 1000) -- Delay execution to avoid blocking
  end,
})

-- -- Setup null-ls for external formatting and diagnostics (e.g., clang-format, clang-tidy)
-- null_ls.setup({
--   sources = {
--     -- Formatting using clang-format from container
--     null_ls.builtins.formatting.clang_format.with({
--       command = lsp_containers.command("clang-format", {
--         image = container_image,
--         command = { "clang-format" },
--       }),
--     }),
--     -- Diagnostics using clang-tidy from container
--     null_ls.builtins.diagnostics.clang_tidy.with({
--       command = lsp_containers.command("clang-tidy", {
--         image = container_image,
--         command = { "clang-tidy" },
--       }),
--     }),
--   },
-- })

-- Automatically run linters and formatters on save for C++ files
vim.api.nvim_exec(
  [[
    autocmd BufWritePost *.cpp lua run_cpp_tools()
]],
  false
)
