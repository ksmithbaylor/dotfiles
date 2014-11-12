# Bashmarks is a simple set of bash functions that allows you to bookmark
# folders in the command-line.
#
# To install, put bashmarks.sh somewhere such as ~/bin, then source it
# in your .bashrc file (or other bash startup file):
#   source ~/bin/bashmarks.sh
#
# To bookmark a folder, simply go to that folder, then bookmark it like so:
#   bookmark foo
#
# The bookmark will be named "foo"
#
# When you want to get back to that folder use:
#   g foo
#
# To see a list of bookmarks:
#   bms
#
# Tab completion works, to go to the shoobie bookmark:
#   go sho[tab]
#
# Your bookmarks are stored in the ~/.bookmarks file

bookmarks_file=~/.bookmarks

# Create bookmarks_file it if it doesn't exist
if [[ ! -f $bookmarks_file ]]; then
  touch $bookmarks_file
fi

# bookmark
bm (){
  bookmark_name=$1

  if [[ -z $bookmark_name ]]; then
    echo 'Current bookmarks:'
    bookmarksshow
  else
    bookmark="`pwd`|$bookmark_name" # Store the bookmark as folder|name

    if [[ -z $(grep "|$bookmark_name" $bookmarks_file) ]]; then
      echo $bookmark >> $bookmarks_file
      echo "Bookmark '$bookmark_name' saved"
    else
      echo "Bookmark already existed"
    fi
  fi
}

# Show a list of the bookmarks
# bookmark show
bms (){
  column -t -s '|' $bookmarks_file
}

g(){
  bookmark_name=$1

  bookmark=`grep "|$bookmark_name$" "$bookmarks_file"`

  if [[ -z $bookmark ]]; then
    echo 'Invalid name, please provide a valid bookmark name. For example:'
    echo '  g foo'
    echo
    echo 'To bookmark a folder, go to the folder then do this (naming the bookmark 'foo'):'
    echo '  bm foo'
  else
    dir=`echo "$bookmark" | cut -d\| -f1`
    echo -ne 'Going to '
    echo $dir
    cd "$dir"
  fi
}

# Added by Kevin Smith on 5/29/2013
# bookmark delete
bmd() {
    if [[ -n $(grep "|$1" $bookmarks_file) ]]; then
    grep -v $(echo "$1" | awk '{print "|" $1 "$"}') $bookmarks_file > ~/.bookmarks.tmp
    cat ~/.bookmarks.tmp > $bookmarks_file
    rm ~/.bookmarks.tmp
    echo "Bookmark '$1' deleted"
  else
    echo "That bookmark doesn't exist"
  fi
}

_go_complete(){
  # Get a list of bookmark names, then grep for what was entered to narrow the list
  cat $bookmarks_file | cut -d\| -f2 | grep "$2.*"
}


if command_exists complete; then
    complete -C _go_complete -o default g
fi
