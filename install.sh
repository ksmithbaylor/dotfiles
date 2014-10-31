function _setup_symlinks() {
    local symlinks=$(find * -maxdepth 1 -mindepth 1 ! -name *.swp |
                     grep -ve '^bin.*' |
                     grep -ve '^packages.*' |
                     grep -ve '^automator.*')

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
ln -sf $PWD/bin $HOME/bin

# Link automator apps into /Applications
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for file in $(ls automator)
do
  rm -rf /Applications/$file
  cp -r automator/$file /Applications/$file
done
IFS=$SAVEIFS
