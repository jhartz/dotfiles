#!/bin/bash
# Symlink dotfiles into home directory
#
# My home, my comforting environment; my couch, TV, remote, and toaster.
# Except I'm a programmer.
#
# install.sh
#       Create symlinks or add shell "source" lines for the files and folders
#       in a certain directory (by default, the one this script is in).
#
# Examples: `vimrc' will be symlinked to from `~/.vimrc'
#           `bashrc' will be sourced from `~/.bashrc'
#           `bin' will be symlinked to from `~/bin'
#
# For usage: ./install.sh -h
#
# NOTE: The filenames in this directory (or wherever you're installing from)
#       should NOT contain the leading dot (or they will be ignored).

set -e


###############################################################################
# CONFIGURATION

# Files which should be sourced, not symlinked (if they exist)
SHELL_FILES=(".bashrc" ".profile" ".bash_profile")

# Files which should NOT have a dot prepended before sourcing/symlinking
NO_DOT=("bin")

# Include in shell files before/after the "source" line
SHELL_PRE="
############################
# Added from Jake's Dotfiles
# For more explanation of these variables (and others you can set),
# see Jake's bashrc.

# Use color in the shell prompt
_BASHRC_USE_COLOR=1
# User who's running a graphical environment
_GRAPHICAL_USER=\"$(id -un)\""

SHELL_POST=""


###############################################################################
# USAGE

# Print usage message, then exit
usage() {
    cat << EOF
Usage: install.sh [options]

Options:
    -h      Show this usage message.
    -d      Don't actually make any changes to the filesystem ("dry run").
    -f ...  Look for dotfiles in the directory specified ("from").
            (default: directory containing this script)
    -t ...  Install dotfiles to the directory specified ("to").
            (default: current user's home directory)
EOF
    exit 2
}

# Just in case...
if [ "$1" = "--help" ]; then
    usage
fi


###############################################################################
# ARGUMENT PARSING

# Whether we should actually make changes
CHANGE=1

# The directory to look for dotfiles in
# (default: where this script is located)
DIR="$(dirname "${BASH_SOURCE[0]}")"

# The directory to install dotfiles to
DEST="$HOME"

# Parse command-line arguments
while getopts ":hdf:t:" opt; do
    case "$opt" in
        h)  usage
            ;;
        d)  CHANGE=0
            ;;
        f)  DIR="$OPTARG"
            ;;
        t)  DEST="$OPTARG"
            ;;
        \?) echo "ERROR: Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)  echo "ERROR: Missing argument -$OPTARG ..." >&2
            exit 1
            ;;
    esac
done

DIR="$(cd "$DIR" && pwd)"
if [ ! -d "$DIR" ]; then
    echo "ERROR: Invalid directory: $DIR"
    exit 1
fi

if [ ! -d "$DEST" ]; then
    echo "ERROR: Invalid destination directory: $DIR"
    exit 1
fi


###############################################################################
# PREPARATION

if [ "$CHANGE" -eq 1 ]; then
    echo "::: Writing changes to disk"
else
    echo "::: Not writing changes to disk"
fi

# Working in the destination directory - makes things a lot easier
cd "$DEST"

# If we're located in a subdir of $DEST, let's cut that off for symlinks
LINKDIR="$DIR"
if [[ $LINKDIR = "$DEST"* ]]; then
    LEN="${#DEST}"
    LINKDIR="${LINKDIR:$LEN}"
    # Trim leading "/", but still make sure it's relative
    if [ "${LINKDIR:0:1}" = "/" ]; then
        LINKDIR="${LINKDIR:1}"
    fi
    LINKDIR="./$LINKDIR"
fi


###############################################################################
# HELPER FUNCTIONS

# Check if an array contains an element
contains() {
    local item="$1"
    shift

    local i
    for i in "$@"; do
        if [[ "$i" == "$item" ]]; then
            return 0
        fi
    done
    return 1
}

# Check if a dotfile filename is valid
is_dotfile() {
    case "$1" in
        install.sh) return 1;;
        README*)    return 1;;
        NOTE*)      return 1;;
        *.BAK)      return 1;;
        *.bak)      return 1;;
        .*)         return 1;;
    esac
    return 0
}

# Check if a dotfile filename is a shell dotfile
is_shell_dotfile() {
    if contains "$1" "${SHELL_FILES[@]}" || \
       contains ".$1" "${SHELL_FILES[@]}"
    then
        return 0
    fi
    return 1
}

# Get the "dotfile name" for a file we're installing
dotfile_name() {
    if contains "$1" "${NO_DOT[@]}"; then
        echo "$1"
    else
        echo ".$1"
    fi
}


###############################################################################
# FINALLY... THE ACTUAL WORK

# Find any dotfiles that are sourced
for file in "$DIR"/*; do
    bname="$(basename "$file")"
    if is_dotfile "$bname" && is_shell_dotfile "$bname"; then
        # Add a line to source the file
        dotfile="$(dotfile_name "$bname")"
        if [ "$CHANGE" -eq 1 ]; then
            cat <<EOF >> "$dotfile"
$SHELL_PRE
. "$file"
$SHELL_POST
EOF
        fi
        echo "Source line added to $(pwd)/$dotfile for $file"
    fi
done

# Find any dotfiles that are symlinked
for file in "$LINKDIR"/*; do
    bname="$(basename "$file")"
    if is_dotfile "$bname" && ! is_shell_dotfile "$bname"; then
        # Symlink the file
        dotfile="$(dotfile_name "$bname")"
        if [ -e "$dotfile" ] && [ ! "$replace_all" ]; then
            echo -n "replace $(pwd)/$dotfile? [Y/n/a/q] "
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
            echo "$(pwd)/$dotfile symlinked to $file"
        fi
    fi
done

