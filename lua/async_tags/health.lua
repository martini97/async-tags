local M = {}

local vim = vim
local is_win = vim.api.nvim_call_function("has", { "win32" }) == 1
local health_start = vim.fn["health#report_start"]
local health_ok = vim.fn["health#report_ok"]
local health_error = vim.fn["health#report_error"]

local command_dependencies = {
  {
    name = "ctags",
    bin = "ctags",
    url = "[Universal Ctags](https://ctags.io/)",
  },
}

local function check_command_installed(command)
  if is_win then
    command = command .. ".exe"
  end
  if vim.fn.executable(command) == 1 then
    local handle = io.popen(command .. " --version")
    local binary_version = handle:read("*a")
    handle:close()
    local eol = binary_version and binary_version:find("\n")
    return true, eol and binary_version:sub(0, eol - 1)
  end
end

M.check = function()
  health_start("Checking external dependencies")

  for _, dep in pairs(command_dependencies) do
    local installed, version = check_command_installed(dep.bin)
    if not installed then
      health_error(("%s: not found. Check %s for information."):format(dep.name, dep.url))
    else
      health_ok(("%s: found %s"):format(dep.name, version or "(unknown version)"))
    end
  end
end

return M
