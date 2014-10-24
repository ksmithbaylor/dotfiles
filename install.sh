function _setup_symlinks() {
    local symlinks=$(find * -maxdepth 1 -mindepth 1 ! -name *.swp |
                     grep -ve '^bin.*') # don't include bin files

    for link in $symlinks; do
        local actual=$PWD/$link
        if [ -f $link ]; then
            local symlink_path="$(head -n 1 $link |
                                  awk '{print $NF}' |
                                  sed "s|~|$HOME|")"
        else
            local symlink_path="$HOME/.$(basename $link)"
        fi
        rm -rf $symlink_path && ln -sf $actual $symlink_path
    done
}

_setup_symlinks
unset _setup_symlinks

# Link personal binaries into ~/bin
rm -rf $HOME/bin
mkdir $HOME/bin
for file in $(ls $PWD/bin); do
    ln -sf $PWD/bin/$file $HOME/bin/$file
done
