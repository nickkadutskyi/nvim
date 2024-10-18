" Define as much as possible in .vimrc to share configs with vim and ideavim
if filereadable(expand("~/.vimrc"))
    source ~/.vimrc
endif

" Import Lua modules
lua require("lazy_init")
lua require("nickkadutskyi")

" Works good with nvim 0.9.5
