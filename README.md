# nvim-luamake (Experimental) 
This is a simple plugin to use the vim `:make` and `:lmake` command
asynchronously in neovim.

## Why ?  
With LSP integrated in neovim, I admit that this plugin is already outdated.
Although I HATE to be linted in the face while I am coding and to see lints
that I do not care about in my (ugly) code. Yes, configuration always bothers
me.  Also I like the `:make`, `:grep` commands.

## Requirements 
- [Neovim 0.5](https://github.com/neovim/neovim)  
- (For now) Some compilers  
- (For the future) Some "greppers"  

## Installation 
With your favourite plugin manager, you can take a look at
[packer.nvim](https://github.com/wbthomason/packer.nvim) or [vim
plug](https://github.com/junegunn/vim-plug) or even use the native solution
for plugins in neovim (See `:help packages`). If the last solution is chosen,
please do not forget to run `:helptags` to get the documentation.

## How to use ?  
(For now, we will see what happens in the future)  Set a compiler (See `:help
:make`, `:help :compiler`, `:help 'errorformat'`) and a makeprg (See `:help
'makeprg'`)  

- Run `Amake` command to lint your code and fill the quickfix list
  asynchronously.  
- Run `Lamake` command to lint your code and fill the location list
  asynchronously.
- Run `StopAmake` to stop the running job.  

Use `:copen` to open the quickfix window. Use `:lopen` to open the location
window. If you set `g:quick_copen` (See Configuration part), the quickfix (or
location) window will open automatically with (provided the good errorformat)
errors parsed. Otherwise, a message "Job is done." will be printed out. If you
stop the job, a message "Job has been stopped." is shown.

## Configuration
In your `init.vim`, you can set:  `let g:quick_copen = 1` to open the quickfix
list (or location window) at the end of the running job.  

## Cautions 
Use it (if you are very old school like me) at your own risk !  This plugin is
at an early stage, let us hope more is following.

## Contributing and Issues 
Please feel free to let me know if you encounter an issue using this plugin
(this is more likely to happen) or simply submit a PR (provided you decipher
my hieroglyphs), I would be happy to discuss !

## License 
This plugin is licensed under Apache 2.0 (same as neovim). See the
[LICENSE](https://github.com/lmenou/nvim-luamake/blob/master/LICENSE) file for
more information.
