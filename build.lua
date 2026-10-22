local source = debug.getinfo(1, "S").source:sub(2)
local root = vim.fn.fnamemodify(source, ":h")
local uname = vim.uv.os_uname()
local os = vim.fn.has("win32") == 1 and "windows" or (vim.fn.has("mac") == 1 and "macos" or "linux")
local arch = uname.machine:lower()
arch = ({ amd64 = "x64", x86_64 = "x64", aarch64 = "arm64", arm64 = "arm64" })[arch]
assert(arch, "unsupported CPU architecture: " .. uname.machine)

local extension = ({ windows = "dll", macos = "dylib", linux = "so" })[os]
local asset = ("nvim_markdown_clipboard-%s-%s.%s"):format(os, arch, extension)
local directory = root .. "/target/release"
local manifest = directory .. "/native-library.txt"
local repo = "AKil47/nvim-markdown-clipboard"

local function curl(url, output)
  assert(vim.fn.executable("curl") == 1, "curl is required to download the native library")
  local command = { "curl", "--fail", "--silent", "--show-error", "--location", "--retry", "3" }
  if output then
    vim.list_extend(command, { "--output", output })
  end
  table.insert(command, url)
  local result = vim.system(command, { text = not output }):wait()
  assert(result.code == 0, result.stderr)
  return result.stdout
end

local commit = vim.system({ "git", "-C", root, "rev-parse", "HEAD" }, { text = true }):wait()
assert(commit.code == 0, commit.stderr)
local sha = vim.trim(commit.stdout)
local filename = ("nvim_markdown_clipboard-%s.%s"):format(sha, extension)
local destination = directory .. "/" .. filename

if vim.fn.filereadable(destination) == 0 then
  local release = vim.json.decode(curl("https://api.github.com/repos/" .. repo .. "/releases/tags/nightly"))
  assert(release.target_commitish == sha, "native build for " .. sha .. " is not published yet; retry :Lazy build nvim-markdown-clipboard shortly")
  vim.fn.mkdir(directory, "p")
  local temporary = destination .. ".download"
  local ok, err = pcall(curl, "https://github.com/" .. repo .. "/releases/download/nightly/" .. asset, temporary)
  if not ok then
    vim.fn.delete(temporary)
    error(err)
  end
  assert(vim.fn.rename(temporary, destination) == 0, "could not install native library")
end

vim.fn.writefile({ filename }, manifest)
