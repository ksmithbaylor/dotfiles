function die() {
    echo $@
    exit 1
}

function setup_symlinks() {
    local symlinks=$(find * -maxdepth 1 -mindepth 1 ! -name *.swp |
                     grep -ve '^bin.*' |
                     grep -ve '^packages.*' |
                     grep -ve '^applications*')

    for link in $symlinks; do
        local actual=$PWD/$link
        if [[ -f $link && $(head -n 1 $link | grep location) ]]; then
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

echo -- Linking personal binaries
rm -rf $HOME/bin
ln -sf $PWD/bin $HOME/bin

echo -- Making sure that Xcode is installed
[ ! -d /Applications/Xcode.app ] && die "Xcode is not installed. Go install it and re-run this script"

echo -- Making sure that Homebrew is installed
if [[ ! $(which brew) ]]; then
    echo "Homebrew is not installed. Installing Homebrew..."
    sudo mkdir -p /usr/local/Cellar
    sudo chown -R $(whoami) /usr/local
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo -- Making sure that Homebrew Cask is installed
if [[ ! -n $(brew list | grep brew-cask) ]]; then
    echo "Homebrew Cask is not installed. Installing Homebrew Cask..."
    brew install caskroom/cask/brew-cask
fi

echo -- Updating Homebrew and Homebrew cask
brew update | grep -v 'Already up-to-date'

echo -- Installing any missing Homebrew packages
brew_packages=$(cat packages/brew)
installed_packages=$(brew list)
for package in $brew_packages; do
    [[ ! $(echo $installed_packages | grep $package) ]] && brew install $package
done

echo -- Installing any missing Homebrew Cask packages
brew_packages=$(cat packages/brew-cask)
installed_packages=$(brew cask list)
[[ $(brew tap | grep 'ksmithbaylor/homebrew-casks') ]] && brew tap 'ksmithbaylor/homebrew-casks'
for package in $brew_packages; do
    [[ ! $(echo $installed_packages | grep $package) ]] && brew cask install $package
done

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

echo -- Running Brew doctor
brew doctor || echo Brew doctor failed

echo -- Checking for other potential problems
[ -d $HOME/Applications ] && echo Why is the ~/Applications folder present?

# Cleanup
unset die
unset setup_symlinks
unset brew_cask_packages
unset installed_packages
unset SAVEIFS
