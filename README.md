# clipboard-history.nvim

A Neovim plugin that maintains a history of yanked text and allows easy pasting from this history. Integrated support for WSL, allowing you to yank directly to windows clipboard. 

## Features

- Automatically captures yanked text
- Displays a window with the clipboard history
- Allows selection and pasting from the history
- Configurable maximum history size
- Clear clipboard history
- Yank text directly to clip.exe (useful for WSL users)

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'royanirudd/clipboard-history.nvim',
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

You can configure the maximum numbner of items stored in the clipboard history
You can also set if you are using WSL

For packer.nvim:
```lua
use {
  "royanirudd/clipboard-history.nvim",
  config = function()
    require("clipboard-history").setup({
      max_history = 30,  -- Maximum number of items to store in the clipboard history
      enable_wsl_features = false,  -- Set to true if you're using WSL and want Windows clipboard integration
    })
  end
}
```

For lazy.nvim:
```lua
{
    'royanirudd/clipboard-history.nvim',
    opts = {
        max_history = 200,  -- Optional: set max history (default 100)
        enable_wsl_features = false,  -- Set to true if you're using WSL and want Windows clipboard integration
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

To clear clipboard history
```vim
:ClipboardClear
```
Clears entire clipboard history

To yank text to windows
```vim
:'<,'>ClipboardYankToWindows
```
NOTE: The "'<,'>" Should come pre populated once you enter command mode after highlighting text

## Pull requests
Feel free to change anything and submit a pull request!

## TODO
- Add search functionality within history
- Project persistant history, maintain context of where text is yanked from 
- WSL2 Windows clipboard integration using 'clip.exe'
- Telescope integration




By Anirudh Roy, India
