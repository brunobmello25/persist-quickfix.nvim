# Persist Quickfix

## The Problem and the Solution

Persist Quickfix is a small plugin that came about while I was refactoring a project and found myself constantly switching between a few entry points that I revisited repeatedly. I tried adding them to [grapple.nvim](https://github.com/cbochs/grapple.nvim), but that wasn't sufficient since I sometimes needed multiple entries from the same file, and grapple only supports one entry per file. I then experimented with combining global marks and grapple marks, but that approach quickly became confusing to manage. Finally, using quickfix directly proved tedious because every time I navigated references with LSP, a new quickfix list would open, forcing me to constantly run commands like `cold` and `cnew`. Persist Quickfix solves this problem by allowing you to assign a name to a given list and load it quickly whenever needed. You can also create custom keymaps for saving and loading specific lists, and everything persists across sessions.

## Installation

Install with your favourite plugin manager.

For example, with lazy.nvim:

```lua
{
    'brunobmello25/persist-quickfix.nvim',
    --- @type PersistQuickfix.Config
    opts = {},
},
```

## Usage

### Saving and Loading Quickfix Lists

When you have an active quickfix list, you can save it by calling the `save` function and providing a name:

```lua
require('persist-quickfix').save('list-name')
```

Later, load that quickfix list using the `load` function:

```lua
require('persist-quickfix').load('list-name')
```

You can choose among all your saved quickfixes with `choose`:

```lua
require('persist-quickfix').choose()
```

To delete an item, simply call `delete` with its list name:

```lua
require('persist-quickfix').delete('list-name')
```

Alternatively, open a picker to choose which list to delete via `choose_delete`:

```lua
require('persist-quickfix').choose_delete()
```

### Extended Usage Examples

Below is an example of how you can extend your Neovim configuration by creating user commands and key mappings. In this example, user commands `SaveQuickfix`, `LoadQuickfix`, and `DeleteQuickfix` are defined to streamline saving, loading, and deleting quickfix lists. Additionally, convenient keymaps are set for saving and loading.

```lua
return {
  {
    'brunobmello25/persist-quickfix.nvim',
    --- @type PersistQuickfix.Config
    opts = {},
    init = function()
      local persist_quickfix = require 'persist-quickfix'

      -- Create a user command to delete a quickfix list using a picker.
      vim.api.nvim_create_user_command('DeleteQuickfix', function()
        persist_quickfix.choose_delete()
      end, {})

      -- Create a user command to load a quickfix list using a picker.
      vim.api.nvim_create_user_command('LoadQuickfix', function()
        persist_quickfix.choose()
      end, {})

      -- Create a user command to save the current quickfix list.
      -- Accepts an optional argument for the quickfix list name.
      vim.api.nvim_create_user_command('SaveQuickfix', function(args)
        if args.fargs[1] and args.fargs[1] ~= '' then
          persist_quickfix.save(args.fargs[1])
        else
          vim.ui.input({ prompt = 'Quickfix name: ' }, function(value)
            if value then
              persist_quickfix.save(value)
            end
          end)
        end
      end, { nargs = '?' })

      -- Key mappings for convenience:
      -- <leader>sq will prompt to save the current quickfix list.
      -- <leader>lq will prompt to load a saved quickfix list.
      vim.keymap.set('n', '<leader>sq', '<cmd>SaveQuickfix<CR>')
      vim.keymap.set('n', '<leader>lq', '<cmd>LoadQuickfix<CR>')
    end,
  },
}
```

### How It Works

1. The `SaveQuickfix` command saves the current quickfix list. You can either provide a list name as an argument:
   - Command Mode: `:SaveQuickfix my-list`
   
   Or omit the argument to be prompted for a name via `vim.ui.input`:
   - Command Mode: `:SaveQuickfix`

2. The `LoadQuickfix` command lets you pick among all saved quickfix lists to load one.

3. The `DeleteQuickfix` command opens a picker to choose which quickfix list to delete.

4. Key mappings (`<leader>sq` and `<leader>lq`) provide an even quicker alternative for saving and loading respectively.

## Configuration

Here are the default configuration values:

```lua
{
    storage_dir = vim.fn.stdpath('data') .. '/persist-quickfix',
    selector = function(items, callback)
        vim.ui.select(items, {}, function(item)
            callback(item)
        end)
    end
}
```
