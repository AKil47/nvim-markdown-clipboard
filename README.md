# nvim-markdown-clipboard

Copy Markdown from Neovim as rich HTML, or paste rich HTML from the system clipboard as Markdown.

## Install

Build the Rust helper with `cargo build --release`. Add this repository to your Neovim runtime path and point the plugin at the resulting executable:

```lua
require("markdown_clipboard").setup({
  binary = "/path/to/nvim-markdown-clipboard/target/release/nvim-markdown-clipboard",
})
```

On Windows, add `.exe` to the binary path. You can also put the executable on your `PATH` and omit `setup()`.

## API and example mappings

```lua
local clipboard = require("markdown_clipboard")

vim.keymap.set("n", "<leader>my", clipboard.copy, { expr = true, desc = "Copy Markdown as HTML" })
vim.keymap.set("x", "<leader>my", clipboard.copy, { desc = "Copy Markdown as HTML" })
vim.keymap.set({ "n", "i" }, "<leader>mp", clipboard.paste, { desc = "Paste HTML as Markdown" })
```

In normal mode, follow the copy mapping with a motion or text object (`<leader>myip`, for example). In Visual mode, select text first, then invoke the mapping. `paste()` inserts converted Markdown at the cursor.

The clipboard receives HTML plus the original Markdown as its plain-text alternative. Pasting requires an HTML clipboard format; a plain-text-only clipboard reports an error.
