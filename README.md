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

Given a quickfix, you can save by calling the `save` function and passing it a name:

```lua
require('persist-quickfix').save('list-name')
```

and to load this list later, call the `load` function:

```lua
require('persist-quickfix').load('list-name')
```

that's it.

## Configuration

Here are the default configuration values:

```lua
{
    storage_dir = vim.fn.stdpath('data') .. '/persist-quickfix',
}
```

## Next Steps

This plugin is **very** early stage. There isn’t a release yet, and the APIs might change. For future features, I’m considering the following:

- [ ] Allow picking quickfix lists from a picker (like telescope or snacks.picker) instead of manually typing the list name.
- [ ] (Maybe?) Automatically generate names if the user doesn’t enter one.
