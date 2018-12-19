runtime! init/functions/*.vim

call SetupBackupAndSwapfiles()
call EnsureVimPlugInstalled()
call SetupPlugs()

runtime! init/*.vim
runtime! init/mappings/*.vim
runtime! init/behavior/*.vim
