#!/bin/bash
# Symlink dotfiles into home directory
#
# My home, my comforting environment; my couch, TV, remote, and toaster.
# Except I'm a programmer.
#
# Use `install.sh` - it will symlink all the dotfiles to `~/.name`.
#
# Influenced from: https://github.com/airblade/dotfiles/blob/master/install.sh

set -e

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

for file in "$DIR"/*; do
    bname="$(basename "$file")"
    if [ "$bname" = "README.md" ] || [ "$bname" = "install.sh" ] || [ ! -f "$file" ]; then
        continue
    fi
    
    dotfile=".$bname"
    if [ -e "$dotfile" ] && [ ! "$replace_all" ]; then
        echo -n "replace ~/.$bname? [Y/n/a/q] "
        read keypress
        case "$keypress" in
            "n" ) continue ;;
            "a" ) replace_all="yes" ;;
            "q" ) exit 0 ;;
        esac
    fi
    ln -vnfs "$file" "$dotfile"
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
