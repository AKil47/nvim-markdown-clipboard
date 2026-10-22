vim.opt.runtimepath:append(vim.fn.getcwd())

local clipboard = require("markdown_clipboard")
clipboard.setup()

vim.api.nvim_buf_set_lines(0, 0, -1, false, { "A [link](https://example.com)" })
vim.fn.setpos("'[", { 0, 1, 1, 0 })
vim.fn.setpos("']", { 0, 1, 29, 0 })
clipboard.operator("char")

vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
clipboard.paste()
assert(vim.api.nvim_get_current_line() == "A [link](https://example.com)")

print("Neovim clipboard round trip passed")
