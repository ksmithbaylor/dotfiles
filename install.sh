function setup_symlinks() {
    local symlinks=$(find * -maxdepth 1 -mindepth 1 ! -name *.swp |
                     grep -ve '^bin.*' |
                     grep -ve '^packages.*' |
                     grep -ve '^applications*')

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

echo -- Setting up symlinks
setup_symlinks

# Link personal binaries into ~/bin
echo -- Linking personal binaries
rm -rf $HOME/bin
ln -sf $PWD/bin $HOME/bin

# Update homebrew/cask
echo -- Updating Homebrew and Homebrew cask
brew update | grep -v 'Already up-to-date'

# Install homebrew packages
echo -- Installing any missing Homebrew packages
brew_packages=$(cat packages/brew)
installed_packages=$(brew list)
for package in $brew_packages; do
    [[ ! $(echo $installed_packages | grep $package) ]] && brew install $package
done

# Install homebrew-cask packages
echo -- Installing any missing Homebrew Cask packages
brew_packages=$(cat packages/brew-cask)
installed_packages=$(brew cask list)
[[ $(brew tap | grep 'ksmithbaylor/homebrew-casks') ]] && brew tap 'ksmithbaylor/homebrew-casks'
for package in $brew_packages; do
    [[ ! $(echo $installed_packages | grep $package) ]] && brew cask install $package
done

# Check for other apps (mac app store)
echo -- Checking for presence of other apps
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for app in $(cat packages/mac-app-store)
do
    if [ ! -d /Applications/$app.app ]; then
        echo Go install $app!
    fi
done
IFS=$SAVEIFS

# Checking other things
echo -- Looking for potential problems
[ -d $HOME/Applications ] && echo Why is the ~/Applications folder present?

# Cleanup
unset setup_symlinks
unset brew_cask_packages
unset installed_packages
unset SAVEIFS
