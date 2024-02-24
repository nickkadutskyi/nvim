if filereadable(expand("~/.vimrc"))
    source ~/.vimrc
endif

" Import Lua modules
lua require("lazy_init")
lua require("nick_kadutskyi")

" Plugins in lazy require make, g++, gcc, fd-find, ripgrep
" Works good with nvim 0.9.4
