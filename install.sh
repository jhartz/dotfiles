#!/bin/bash
# Symlink dotfiles into home directory
#
# My home, my comforting environment; my couch, TV, remote, and toaster.
# Except I'm a programmer.
#
# install.sh - Creates symlinks or adds shell "source" lines for dotfiles.
# Example: `vimrc` will be symlinked to from `~/.vimrc`
#
# Influenced from: https://github.com/airblade/dotfiles/blob/master/install.sh

set -e

# Files which should be sourced, not symlinked
SHELL_FILES=(".bashrc" ".profile" ".bash_profile")


# Usage message
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat << EOF
Usage: install.sh [options]

Options:
    -h  --help      Show this usage message.
    -d  --dry-run   Don't actually make any changes to the filesystem.
EOF
    exit 2
fi

# Whether we should actually make changes
CHANGE=1
if [ "$1" = "-d" ] || [ "$1" = "--dry-run" ]; then
    echo "Not writing changes to disk"
    CHANGE=0
fi

# The directory in which this script is located
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Working in the home directory - makes things a lot easier
cd "$HOME"

# If we're located in a subdir of $HOME, let's cut that off
if [[ $DIR = "$HOME"* ]]; then
    LEN="${#HOME}"
    DIR="${DIR:$LEN}"
    # Trim leading "/", but still make sure it's relative
    if [ "${DIR:0:1}" = "/" ]; then
        DIR="${DIR:1}"
    fi
    DIR="./$DIR"
fi


# Check if an array contains an element
contains() {
    local e
    for e in "${@:2}"; do
        [[ "$e" == "$1" ]] && return 0
    done
    return 1
}


# Loop thru all the dotfiles
for file in "$DIR"/*; do
    bname="$(basename "$file")"
    if [ "$bname" = "README.md" ] || [ "$bname" = "install.sh" ] || [ ! -f "$file" ]; then
        continue
    fi

    dotfile=".$bname"

    if contains "$bname" "${SHELL_FILES[@]}" || contains "$dotfile" "${SHELL_FILES[@]}"; then
        # Add a line to source the file
        [ "$CHANGE" -eq 1 ] && cat <<EOF >> "$dotfile"

############################
# Added from Jake's Dotfiles ($DIR)
. "$file"

EOF
        echo "Source line added to $dotfile for $file"
    else
        # Symlink the file
        if [ -e "$dotfile" ] && [ ! "$replace_all" ]; then
            echo -n "replace ~/.$bname? [Y/n/a/q] "
            read keypress
            case "$keypress" in
                "n" ) continue ;;
                "a" ) replace_all="yes" ;;
                "q" ) exit 0 ;;
            esac
        fi
        if [ "$CHANGE" -eq 1 ]; then
            ln -vnfs "$file" "$dotfile"
        else
            echo "$dotfile symlinked to $file"
        fi
    fi
done


# We used to have a bin folder than we'd simlink ~/bin to, but not anymore

#if [ -e "bin" ]; then
#    echo -n "replace ~/bin? [Y/n] "
#    read keypress
#    case "$keypress" in
#        "n" ) exit 0 ;;
#    esac
#fi
#ln -vnfs "$DIR/bin" "bin"
