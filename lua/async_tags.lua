local M = {}

local vim = vim
local loop = vim.loop
local context = {}

context._is_building_tags = false
context._last_built = nil

function M.async_build_tags()
  if vim.tbl_contains(context._skip_fts, vim.bo.filetype) then
    print("[async_tags] skipping due to filetype")
    return
  end

  if context._is_building_tags then
    print("[async_tags] there's a process running already")
    return
  end

  if context._last_built and os.time() - context._last_built < context._fresh_threshold then
    print("[async_tags] tags are still fresh")
    return
  end

  local start = vim.loop.hrtime()
  context._is_building_tags = true
  context._handle = vim.loop.spawn(context._bin, {
    args = context._args,
    cwd = context._cwd_fn(),
  }, function(code)
    if code == 0 then
      local took_ms = (vim.loop.hrtime() - start) / 1000000
      context._last_built = os.time()
      if context._verbosity > 0 then
        print(("[async_tags] tags built successfully, took %.2f ms"):format(took_ms))
      end
    else
      if context._verbosity > 0 then
        print(("[async_tags] failed to build tags (exit code: %d)"):format(code))
      end
    end

    context._is_building_tags = false
    context._handle:close()
  end)
end

local function install_autocmds()
  local events = table.concat(context._events, ",")
  local fts = table.concat(context._patterns, ",")
  local silent = "silent! "
  if context._verbosity >= 2 then
    silent = ""
  end

  vim.cmd(([[
    augroup AsyncTags
        autocmd!
        autocmd %s %s %slua require("async_tags").async_build_tags()
    augroup END
  ]]):format(events, fts, silent))
end

function M.setup(user_args)
  local args = user_args or {}
  context._bin = args.bin or "ctags"
  context._args = args.args or { "-R", "." }
  context._cwd_fn = args.cwd_fn or loop.cwd
  context._events = args.events or { "BufWritePost", "BufEnter", "VimEnter" }
  context._patterns = args.patterns or { "*" }
  context._skip_fts = args.skip_filetypes or { "markdown" }
  context._fresh_threshold = args.fresh_threshold or 60
  context._verbosity = args.verbosity or 0

  if user_args.install_autocmds then
    install_autocmds()
  end
end

return M
