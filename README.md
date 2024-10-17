# clipboard-history.nvim

A Neovim plugin that maintains a history of yanked text and allows easy pasting from this history.

## Features

- Automatically captures yanked text
- Displays a window with the clipboard history
- Allows selection and pasting from the history
- Configurable maximum history size

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'yourusername/clipboard-history.nvim',
    config = function()
        vim.g.clipboard_history_max_history = 200  -- Optional: set max history (default 100)
    end
}
```

## Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'royanirudd/clipboard-history.nvim',
    opts = {
        max_history = 200  -- Optional: set max history (default 100)
    }
}

```

## Configuration

You can configure the maximum numbner of items stored in the clipboard history:

For packer.nvim:
```lua
vim.g.clipboard_history_max_history = 200  -- Set before loading the plugin
```

For lazy.nvim:
```lua
{
    'royanirudd/clipboard-history.nvim',
    opts = {
        max_history = 200  -- Optional: set max history (default 100)
    }
}
```
If not specified the default value of 30 will be used.

## Usage
The plugin automatically captures yanked text and stores it in the history.
To open the clipboard history window:
```vim
:ClipboardHistory
```
In the clipboard history window
- Navigate to the text needed
- Press \<Enter> to select and paste an item
- Press q to close the window without selecting

## Pull requests
Feel free to change anything and submit a pull request!

By Anirudh Roy, India
