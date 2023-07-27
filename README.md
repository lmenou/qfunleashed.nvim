# qfunleashed.nvim :gear:
This is a simple plugin to use the vim `:make` and `:grep` command
asynchronously in Neovim.

If you do not know what those commands are/do, I highly suggest you to type
`:help quickfix<CR>`, Vim/Neovim's compiler system is one of the reason to stick
with those editors to edit your amazing pieces of codes.

## Why ?  
With LSP integrated in Neovim, I admit that this plugin seems already
outdated.  Although I HATE to be linted in the face while I am coding and to
see lints that I do not care about in my (ugly) code. Yes, configuration
always bothers me.  Also, I like the `:make`, `:grep` commands.

## Requirements :lock_with_ink_pen:
- [Neovim 0.5](https://github.com/neovim/neovim)  
- Some compilers  
- Some "greppers"  

## Installation :incoming_envelope:
With your favourite plugin manager, you can have a look at
[packer.nvim](https://github.com/wbthomason/packer.nvim) or [vim
plug](https://github.com/junegunn/vim-plug) or even use the native solution
for plugins in Neovim (See `:help packages`). If the last solution is chosen,
please do not forget to run `:helptags` to get the documentation.

## How to use ?  

Set a compiler (See `:help :make`, `:help :compiler`, `:help 'errorformat'`)
and a makeprg (See `:help 'makeprg'`).  

- Run `:Make` command to lint/build your code and fill the quickfix list
  asynchronously.  
- Run `:Lmake` command to lint/build your code and fill the location list
  asynchronously.  

It is also possible to set a grepper (See `:help :grep` and `:help 'grepformat'`).  
- Run `:Grep` command to grep in your code and fill the quickfix list
  asynchronously.  
- Run `:Lgrep` command to grep in your code and fill the location list
  asynchronously.  

If you miss something, it is possible to stop the current running job.  
- Run `:StopJob` to stop the running job.  

If you wish to add other items to your current (quickfix or location) lists
after a grep, simply add `Add` after the previous asynchronous grep commands
(e.g. `:GrepAdd`, `:LgrepAdd`).  

Use `:copen` to open the quickfix window. Use `:lopen` to open the location
window. If you set `g:qfunleashed_quick_open` (See Configuration part), the quickfix (or
location) window will open automatically with (provided the good errorformat)
errors parsed.

`Find` and `Lfind` are also provided to fill your lists with items a similar
way. This might be useful for `cdo` like commands.

Please, feel free to read the help for further information.

## Configuration
In your `init.vim`, you can set:  
`let g:qfunleashed_quick_open = 1`
to open the quickfix list (or location window) at the end of the running job.  

It is also possible to set:  
`let g:qfunleashed_quick_window = 1`
to open a window showing the output of the job while it is running.  

## Contributing and Issues :thought_balloon:
Please, feel free to let me know if you encounter an issue using this plugin
(this is more likely to happen) or simply submit a PR (provided you decipher
my hieroglyphs), I would be happy to discuss !

If you feel brave or helpful, code review are more than welcome too !

*Note*: This plugin should work properly on a Unix like system, but I would love
to get some help from Windows users.

## License :bookmark:
This plugin is licensed under Apache 2.0 (same as Neovim). See the
[LICENSE](https://github.com/lmenou/nvim-luamake/blob/master/LICENSE) file for
more information.
