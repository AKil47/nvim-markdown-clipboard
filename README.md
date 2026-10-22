# nvim-markdown-clipboard

Copy Markdown from Neovim as rich HTML, or paste rich HTML from the system clipboard as Markdown.

## Install

With lazy.nvim, add this file as `lua/akil/plugin_setup/markdown_clipboard.lua` in your config. The repository's `build.lua` downloads a native library from the rolling GitHub release when the plugin is installed or updated. Users need `curl`, but do not need Rust or Cargo:

```lua
return {
  "AKil47/nvim-markdown-clipboard",
  config = function()
    local clipboard = require("markdown_clipboard")
    vim.keymap.set("n", "<leader>my", clipboard.copy, { expr = true, desc = "Copy Markdown as HTML" })
    vim.keymap.set("x", "<leader>my", clipboard.copy, { desc = "Copy Markdown as HTML" })
    vim.keymap.set({ "n", "i" }, "<leader>mp", clipboard.paste, { desc = "Paste HTML as Markdown" })
  end,
}
```

The rolling release is rebuilt from each commit on `main`. If an update reaches lazy.nvim before its native build is published, run `:Lazy build nvim-markdown-clipboard` after the release appears.

For a manual install or development, build with `cargo build --release` and add this repository to your Neovim runtime path. The plugin loads the library from `target/release` automatically. If you place it elsewhere, pass its path:

```lua
require("markdown_clipboard").setup({
  library = "/path/to/libnvim_markdown_clipboard.so",
})
```

On Windows the library is `nvim_markdown_clipboard.dll`; on macOS it is `libnvim_markdown_clipboard.dylib`. Neovim loads the Rust Lua module directly, without starting a process for each copy or paste.

## API

```lua
local clipboard = require("markdown_clipboard")
clipboard.copy()  -- operator in normal mode, selection in Visual mode
clipboard.paste() -- insert clipboard HTML as Markdown
```

In normal mode, follow the copy mapping with a motion or text object (`<leader>myip`, for example). In Visual mode, select text first, then invoke the mapping. `paste()` inserts converted Markdown at the cursor.

The clipboard receives HTML plus the original Markdown as its plain-text alternative. Pasting requires an HTML clipboard format; a plain-text-only clipboard reports an error.
