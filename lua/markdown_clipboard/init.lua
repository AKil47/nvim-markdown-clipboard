local M = {}

local library_path
local library

local function default_library()
  local source = debug.getinfo(1, "S").source:sub(2)
  local root = vim.fn.fnamemodify(source, ":h:h:h")
  local name = vim.fn.has("win32") == 1 and "nvim_markdown_clipboard.dll"
    or (vim.fn.has("mac") == 1 and "libnvim_markdown_clipboard.dylib" or "libnvim_markdown_clipboard.so")
  return root .. "/target/release/" .. name
end

local function get_library()
  if not library then
    local load, err = package.loadlib(library_path or default_library(), "luaopen_nvim_markdown_clipboard")
    if not load then
      error(err)
    end
    library = load()
  end
  return library
end

function M.setup(opts)
  opts = opts or {}
  library_path = opts.library
  library = nil
end

local function copy_region(first, last, kind)
  local lines = vim.fn.getregion(first, last, { type = kind })
  get_library().copy(table.concat(lines, "\n"))
end

function M.operator(kind)
  local region_type = ({ char = "v", line = "V", block = "\22" })[kind]
  copy_region(vim.fn.getpos("'["), vim.fn.getpos("']"), region_type or kind)
end

function M.copy()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    copy_region(vim.fn.getpos("v"), vim.fn.getpos("."), mode)
    return
  end
  vim.o.operatorfunc = "v:lua.require'markdown_clipboard'.operator"
  return "g@"
end

function M.paste()
  local markdown = get_library().paste()
  if markdown ~= "" then
    vim.api.nvim_put(vim.split(markdown, "\n", { plain = true }), "c", true, true)
  end
end

return M
