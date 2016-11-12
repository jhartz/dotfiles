# Jake's bashrc
#
# This must be sourced from somewhere like /etc/bash.bashrc or ~/.bashrc
# The file sourcing it will be called the "parent bashrc".
#
# Directions for the parent bashrc:
#   0.  To enable color, set _BASHRC_USE_COLOR in the parent bashrc.
#   1.  If there is only one account on the machine who runs a graphical
#       environment (X11), then, in the parent bashrc, set _GRAPHICAL_USER to
#       this user account. This is used for the "open"/"openfolder" functions.
#   2.  To hide the machine name from the from PS1 and PROMPT_COMMAND, set
#       _NO_MACHINE_NAME in the parent bashrc.
#   3.  To enable special PS1 stuff when inside a git repo, set _GIT_PS1 in
#       the parent bashrc.
#   4.  Source this file.
#   5.  Unset _NO_MACHINE_NAME if your heart desires.


if [ -d "$HOME/bin" ]; then
    export PATH="$PATH:$HOME/bin"
fi

for d in $HOME/.gem/ruby/*/bin; do
    if [ -d "$d" ]; then
        export PATH="$PATH:$d"
    fi
done


#############
## Aliases ##
#############


alias t=true

# Some systems don't support --color for grep or ls
if echo test | grep --color test >/dev/null 2>&1; then
    alias grep='grep --color'
fi
if ls --color=auto >/dev/null 2>&1; then
    alias ls='ls --color=auto -N'
fi

alias lsq='/bin/ls'
alias la='ls -A'
alias ll='ls -alF'
alias lh='ll -h'
alias l='ls -F'

alias submodule='git submodule update --init --recursive'
#alias go='git checkout'
# (conflicts with golang)

alias exir='exit'
alias cim=vim
alias bim=vim
alias v='vim -p'

alias psmem="ps aux --sort '-%mem' | head"
alias pscpu="ps aux --sort '-%cpu' | head"
alias topcpu="top -o '%CPU'"
alias topmem="top -o '%MEM'"
alias swaptop="swapon --show"

alias syslogtail='journalctl -xe'
alias syslog='journalctl -xe'
alias dump='hexdump -C'

alias root='sudo -EHs'

alias duso=sudo
alias sodu=sudo


###########################
## Bash Settings/Exports ##
###########################


export EDITOR="vim"


########################
## Shortcut Functions ##
########################


succeed() {
    echo "GOOD"
    return 0
}

fail() {
    >&2 echo "BAD"
    return 1
}


# Temp HTTP server
http() {
    if which python3 >/dev/null 2>&1; then
        python3 -m http.server "$@"
    elif which python2 >/dev/null 2>&1; then
        python2 -m SimpleHTTPServer "$@"
    else
        # Probably python 2
        python -m SimpleHTTPServer "$@"
    fi
}


# Calculator
=() {
    local calc="$@"
    if [ "$calc" ] ; then
        bc -l <<< "scale=10;$calc"
    else
        man bc
    fi
}

# Time calculator
==() {
    local hours=0
    local mins=0
    while true; do
        local time=0
        printf "%02d:%02d += " "$hours" "$mins"
        read time
        if [ ! "$time" ]; then
            break
        fi

        local parts=(${time//:/ })
        if [ "${#parts[@]}" = 1 ]; then
            # Just minutes
            mins="$(expr "$mins" + "${parts[0]}")"
        else
            # hours:minutes
            hours="$(expr "$hours" + "${parts[0]}")"
            mins="$(expr "$mins" + "${parts[1]}")"
        fi
        # Make sure mins < 60
        while [ "$mins" -ge 60 ]; do
            hours="$(expr "$hours" + 1)"
            mins="$(expr "$mins" - 60)"
        done
    done
}

# cd && ls
c() {
    cd "$@" && ls
}

# cd && ll
cl() {
    cd "$@" && ls -alF
}

# mkdir && cd
mc() {
    mkdir "$@" && cd "${@:$#}" && ls
}

# sudo shortcut
bitch() {
    lastcmd="$(fc -ln -- -1)"
    if [ "$1" = "please" ] || [ "$1" = "plz" ] || [ "$1" = "" ]; then
        sudo $lastcmd
    else
        sudo "$@"
    fi
}
alias bitch,=bitch
alias please=bitch
alias plz=bitch

# open something using xdg-open as the graphical user
open() {
    item="$1"
    if [ ! "$item" ]; then
        # No item specified, use current directory
        item="."
    fi

    if [ "$_GRAPHICAL_USER" ]; then
        sudo -EHu "$_GRAPHICAL_USER" xdg-open "$item"
    else
        xdg-open "$item"
    fi
}
openfolder() {
    item="$1"
    if [ ! "$item" ]; then
        # No item specified; use current directory
        item="$(pwd)"
    fi
    item="$(dirname "$item")"

    if [ "$_GRAPHICAL_USER" ]; then
        sudo -EHu "$_GRAPHICAL_USER" xdg-open "$item"
    else
        xdg-open "$item"
    fi
}
alias ..=open
alias ...=openfolder

# do something in a subshell with a different mask
subshell_u() {
    (umask 077; "$@")
}
subshell_go() {
    (umask 022; "$@")
}
alias .u=subshell_u
alias .go=subshell_go


##################
## Shell Prompt ##
##################


if [ "$_GIT_PS1" ]; then
    [ -r /usr/share/git/completion/git-prompt.sh ] && . /usr/share/git/completion/git-prompt.sh
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1
fi

# /home/jake/bin/include/colors
if [ "$_BASHRC_USE_COLOR" ]; then
    case ${TERM} in
      xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)" # This is more of a "mustard yellow"
        BLUE="$(tput setaf 4)"
        PURPLE="$(tput setaf 5)"
        TEAL="$(tput setaf 6)"

        BOLD="$(tput bold)"
        BLACK="$(tput sgr0)"
        ;;
    esac
fi


__jobscount() {
  local stopped=$(jobs -sp | wc -l)
  local running=$(jobs -rp | wc -l)
  ((running+stopped)) && echo -n "${running}r/${stopped}s "
}


__curdir() {
    local dir="$1"

    # If the parameters were passed correctly...
    if [ ! "$dir" ]; then
        return
    fi

    # If we're not worrying about the git stuff...
    if [ ! "$_GIT_PS1" ]; then
        if [ "$2" = 1 ]; then
            echo "$dir"
        fi
        return
    fi

    local gitRepoDir=""
    local gitRepoSubDir=""


    # If we're in a git repository...
    if [ "$(__git_ps1)" != "" ]; then
        local thisDir=""
        local otherDirs=""

        # Find the root of the repo
        while true; do
            # If we're in the root of the repo or at the root of the filesystem
            # or the home directory...
            if ls .git >/dev/null 2>&1 || [ "${#dir}" -lt 3 ]; then
                break
            else
                # Not at the root of the git repo yet
                cd ..
                otherDirs="$(echo "$dir" | sed 's/\/[^/]*$//')"
                thisDir="${dir:${#otherDirs}}"
                dir="$otherDirs"
                gitRepoDir="$thisDir$gitRepoDir"
            fi
        done

        # Make pretty
        otherDirs="$(echo "$dir" | sed 's/\/[^/]*$//')"
        thisDir="${dir:$(expr "${#otherDirs}" "+" "1")}"

        dir="$otherDirs/"
        gitRepoSubDir="$gitRepoDir"
        gitRepoDir="$thisDir"
    fi

    if [ "$2" = "1" ]; then
        # The part of the path before the git repo
        echo "$dir"
    elif [ "$2" = "2" ]; then
        # The name of the root dir of the git repo
        echo "$gitRepoDir"
    elif [ "$2" = "3" ]; then
        # Subdirectory of the root dir of the git repo that we're in
        echo -n "$gitRepoSubDir"
        __git_ps1 " (%s)"
    fi
}


# Adjusted shell level stuff
# (used to be in PS1; taken out cause it's pretty useless)
#if [ "$SHLVL_TOP" = "" ]; then
#    export SHLVL_TOP="$SHLVL"
#fi
#SHLVL_ADJ="$(expr "$SHLVL" - "$SHLVL_TOP")"


hostname_part='@\h'
if [ "$_NO_MACHINE_NAME" ]; then hostname_part=""; fi

# [return code] [job counts] username@hostname:pwd [git branch] $
PS1='\['"$BOLD$TEAL"'\]$(a="$?"; if [ "$a" != "0" ]; then echo "$a "; fi)\['"$TEAL"'\]$(__jobscount)\['"$BLACK"'\]\u'"$hostname_part"':\['"$TEAL"'\]$(__curdir "\w" 1)\['"$BOLD"'\]$(__curdir "\w" 2)\['"$BLACK$TEAL"'\]$(__curdir "\w" 3)\$\['"$BLACK"'\] '
#PS1='$(a="$?"; if [ "$a" != "0" ]; then echo "$a "; fi)\u@\h:\w\$ '
PS2='> '
PS3='> '
PS4='+ '

unset hostname_part


case ${TERM} in
  xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
    #PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
    middle=""
    middle_user=0
    if [ "$(id -un)" != "$_GRAPHICAL_USER" ]; then middle_user=1; fi
    middle_hostname=1
    if [ "$_NO_MACHINE_NAME" ]; then middle_hostname=0; fi

    if [ $middle_user -eq 1 ]; then
        middle="$middle"'${USER}'
    fi
    if [ $middle_hostname -eq 1 ]; then
        if [ $middle_user -eq 1 ]; then
            middle="$middle"'@'
        fi
        middle="$middle"'${HOSTNAME%%.*}'
    fi
    if [ $middle_user -eq 1 -o $middle_hostname -eq 1 ]; then
        middle="$middle"':'
    fi

    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'echo -ne "\033]0;'"$middle"'${PWD/#$HOME/\~}\007"'
    unset middle
    unset middle_user
    unset middle_hostname
    ;;

  screen)
    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
    ;;
esac

