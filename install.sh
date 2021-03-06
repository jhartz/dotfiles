#!/usr/bin/env bash
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

# Boolean options to set before sourcing shell files
SHELL_OPTIONS=(
    BASHRC_COLOR_PROMPT
    BASHRC_NO_USERNAME
    BASHRC_NO_UMASK
    BASHRC_NO_HOSTNAME
    BASHRC_GIT_PROMPT
)

# Include in shell files before/after the "source" line
SHELL_PRE="
############################
# Added from Jake's Dotfiles
# For more explanation of these variables (and others you can set),
# see Jake's bashrc.

BASHRC_GRAPHICAL_USER=\"$(id -un)\""

SHELL_POST="
unset BASHRC_GRAPHICAL_USER"


###############################################################################
# USAGE

# Print usage message, then exit
usage() {
    cat << EOF
Usage: install.sh [options]

Options:
    -h      Show this usage message.
    -d      Don't actually make any changes to the filesystem ("dry run").
    -a      Always ask before making changes.
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

# Whether to always ask before making changes
ALWAYS_ASK=0

# The directory to look for dotfiles in
# (default: where this script is located)
DIR="$(dirname "${BASH_SOURCE[0]}")"

# The directory to install dotfiles to
DEST="$HOME"

# Parse command-line arguments
while getopts ":hdaf:t:" opt; do
    case "$opt" in
        h)  usage
            ;;
        d)  CHANGE=0
            ;;
        a)  ALWAYS_ASK=1
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

echo "::: DESTINATION: $DEST"

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

# Ask if we should update a certain dotfile (if necessary)
ask_for_dotfile() {
    if [ "$ALWAYS_ASK" -ne 0 ] && [ ! "$update_all" ]; then
        echo -n "update $1? [Y/n/a/q] "
        read keypress
        case "$keypress" in
            n)  return 1;;
            a)  update_all="yup";;
            q)  exit 0;;
        esac
    fi
    return 0
}

# Ask if we should include an option
ask_for_option() {
    echo -n "include option $1? [Y/n] "
    read keypress
    case "$keypress" in
        n)  return 1;;
    esac
    return 0
}


###############################################################################
# FINALLY... THE ACTUAL WORK

update_all=""
replace_all=""

# Find any dotfiles that are sourced
for file in "$DIR"/*; do
    bname="$(basename "$file")"
    if is_dotfile "$bname" && is_shell_dotfile "$bname" &&
       ask_for_dotfile "$bname"
    then
        # Ask about any options
        shell_options_pre=""
        shell_options_post=""
        for option in "${SHELL_OPTIONS[@]}"; do
            if ask_for_option "$option"; then
                shell_options_pre="$shell_options_pre
$option=1"
                shell_options_post="$shell_options_post
unset $option"
            fi
        done

        # Add a line to source the file
        dotfile="$(dotfile_name "$bname")"

        if [ "$CHANGE" -eq 1 ]; then
            cat <<EOF >> "$dotfile"
$SHELL_PRE
$shell_options_pre
. "$file"
$shell_options_post
$SHELL_POST
EOF

            echo "Source line added to $dotfile for $file"
        else
            cat <<EOF
Would have added source line to $dotfile for $file like so:
$SHELL_PRE
$shell_options_pre
. "$file"
$shell_options_post
$SHELL_POST

EOF
        fi
    fi
done

# Find any dotfiles that are symlinked
for file in "$LINKDIR"/*; do
    bname="$(basename "$file")"
    if is_dotfile "$bname" && ! is_shell_dotfile "$bname" &&
       ask_for_dotfile "$bname"
    then
        # Symlink the file
        dotfile="$(dotfile_name "$bname")"

        if [ -e "$dotfile" ] && [ ! "$replace_all" ]; then
            echo -n "replace $dotfile? [Y/n/a/q] "
            read keypress
            case "$keypress" in
                n)  continue;;
                a)  replace_all="yes";;
                q)  exit 0;;
            esac
        fi

        if [ "$CHANGE" -eq 1 ]; then
            ln -nfs "$file" "$dotfile"
        fi

        echo "$dotfile symlinked to $file"
    fi
done

