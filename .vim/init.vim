runtime! init/functions/*.vim

call EnsureVimPlugInstalled()
call SetupPlugs()

runtime! init/mappings/*.vim
runtime! init/behavior/*.vim
runtime! init/*.vim
