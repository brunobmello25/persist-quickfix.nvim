# Persist Quickfix

## The problem and the solution

Persist Quickfix is a small plugin that came up to mind when I was refactoring a project and was constantly switching back and forth to a small set of entrypoints that I was constantly revisiting. Adding them to [grapple.nvim](https://github.com/cbochs/grapple.nvim) wasn't cutting because sometimes I wanted multiple entries of the same file and grapple only supports one entry per file. Then I started using global marks in addition to grapple marks, but it was getting confusing to manage. Finally, just using quickfix was a bit of a pain because everytime I navigate references with LSP it opens a new quickfix list, so having to constantly do `cold` and `cnew` wasnt cutting either.

Persist Quickfix solves this problem for me. I can easily assign a name for a given list and quickly load it whenever I want. I can create custom keymaps for saving and loading specific lists and it persists across sessions.

## Next steps

This plugin is **very** early stage. There isn't any release created yet, and the APIs might change. When it comes to features, this is what I'm thinking:

- [ ] Allow picking quickfix lists from a picker (like telescope or snacks.picker) instead of manually typing the list name
- [ ] (maybe?) Generate names automatically if the user doesn't type any name
