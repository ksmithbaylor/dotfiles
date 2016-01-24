#!/usr/bin/env zsh

# Make a new automator app that accepts files and runs:
# ~/bin/mailroom.sh "$@"

# Assumes CocoaDialog is installed, as well as `tag`. If they're not:
#   brew cask install cocoadialog
#   brew install tag

# Constants to use throughout
TARGET_DIR=/Users/kevin/Library/Mobile\ Documents/com~apple~CloudDocs/scans
INPUT_FILE="$1"
EXIT_FILE=/tmp/mailRoomShouldExit

# Prompts the user with an input box. Takes one argument, the text to prompt with.
function get_input() {
  result=$(/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog inputbox \
    --float \
    --title "Mail Room" \
    --button1 "OK" \
    --button2 "Cancel" \
    --informative-text $1)

  if [ $(echo "$result" | awk 'NR==1') = 2 ]; then
    touch $EXIT_FILE
  else
    rm -f $EXIT_FILE
  fi

  echo "$result" | awk 'NR==2'
}

# Finds any existing tags in the target directory
function existing_tags() {
  pushd `pwd`

  cd "$TARGET_DIR"

  # List OS X tags
  /usr/local/bin/tag --list * -N | \
    # Filter out duplicates
    tr ',' '\n' | sort | uniq | \
    # Comma-separate them
    tr '\n' ',' | sed 's/,/, /g' | \
    # Get rid of last comma
    sed 's/, $//g'

  popd
}

function parse_tags() {
  tr ', ' ',' | tr ',' '\n' | grep -v '^$' | tr '\n' ',' | sed 's/,$//g'
}

# Get the filename from the user
filename=$(get_input "Enter the filename for this scan:")
[[ -f $EXIT_FILE ]] && rm -f "$INPUT_FILE" && exit

# Get tags from the user
tags=$(get_input "Enter the tags for this scan. Existing tags are: $(existing_tags)" | parse_tags)
[[ -f $EXIT_FILE ]] && rm -f "$INPUT_FILE" && exit

# Tag the file
if [[ -n "$tags" ]]; then
  /usr/local/bin/tag --add "$tags" "$INPUT_FILE"
fi

# Move the file
if [[ -n "$filename" ]]; then
  mv "$INPUT_FILE" "$TARGET_DIR/$filename.pdf"
fi
