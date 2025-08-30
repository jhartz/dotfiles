# Jake's bashrc
#
# This must be sourced from somewhere like /etc/bash.bashrc or ~/.bashrc
# The file sourcing it will be called the "parent bashrc".
#
# Directions for the parent bashrc:
#   1.  Set any optional variables (BASHRC_...) in the parent bashrc.
#   2.  Source this file.
#   3.  Unset the BASHRC_... variables if your heart desires.
#
# Optional Variables:
#
#   BASHRC_COLOR_PROMPT=1
#       Use color in the shell prompt.
#
#   BASHRC_NO_USERNAME=1
#       Hide the current username from the shell prompt and window title.
#
#   BASHRC_NO_UMASK=1
#       Hide the current umask from the shell prompt.
#
#   BASHRC_NO_HOSTNAME=1
#       Hide the machine name from the shell prompt and window title.
#
#   BASHRC_GIT_PROMPT=1
#       Show git repo information in the shell prompt when applicable.
#       (Requires git-prompt.sh -- if you have git-prompt.sh in a nonstandard
#       location, be sure to source it before this file.)
#
#   BASHRC_GRAPHICAL_USER=username
#       If there is an account on the machine that should be used for anything
#       requiring a graphical environment, then set this to that account's
#       username. This is used for the "open-this" function (aka "...").


# For compatibility with older versions
[ "$BASHRC_NO_HOSTNAME" ] || BASHRC_NO_HOSTNAME="$_NO_MACHINE_NAME"
[ "$BASHRC_NO_HOSTNAME" ] || BASHRC_NO_HOSTNAME="$BASHRC_NO_MACHINE_NAME"
[ "$BASHRC_GRAPHICAL_USER" ] || BASHRC_GRAPHICAL_USER="$_GRAPHICAL_USER"
[ "$BASHRC_COLOR_PROMPT" ] || BASHRC_COLOR_PROMPT="$_BASHRC_USE_COLOR"
[ "$BASHRC_GIT_PROMPT" ] || BASHRC_GIT_PROMPT="$_GIT_PS1"


if [ -d "$HOME/bin" ]; then
    export PATH="$PATH:$HOME/bin"
fi

for d in $HOME/.gem/ruby/*/bin; do
    if [ -d "$d" ]; then
        export PATH="$PATH:$d"
    fi
done

if [ ! "$EDITOR" ]; then
    export EDITOR="vim"
fi

# Don't record commands that start with a space in the history ("ignorespace"),
# and don't record duplicates ("ignoredups")
HISTCONTROL=ignoreboth
# Append to history file, rather than overwriting
shopt -s histappend
# Keep lots of history
HISTFILESIZE=1000000
HISTSIZE=1000000
# Write the history after every command
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"


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

shut-up() {
    "$@" >/dev/null 2>&1
}

cmd-exists() {
    shut-up which "$1"
}


#############
## Aliases ##
#############


alias t=true

# Some systems don't support --color for grep or ls
if echo test | shut-up grep --color=auto test; then
    alias grep='grep --color=auto'
fi
_ls_args=""
if shut-up ls --color=auto; then
    _ls_args="$_ls_args --color=auto"
elif [ -z "$CLICOLOR" ] && shut-up ls -F; then
    # On Macs, people set CLICOLOR to tell ls to use color.
    # If this isn't set, then assume ls doesn't support color,
    # and always use the -F option.
    _ls_args="$_ls_args -F"
fi
if shut-up ls --group-directories-first; then
    _ls_args="$_ls_args --group-directories-first"
fi
if shut-up ls -N; then
    _ls_args="$_ls_args -N"
fi
alias ls="ls $_ls_args"

# Try to work around various differences in "ps" and "top"
if shut-up ps --sort '-%cpu'; then
    # It's GNU ps; use --sort
    alias pscpu="ps aux --sort '-%cpu'"
    alias psmem="ps aux --sort '-%mem'"
    # Assume we have GNU top (TODO: this isn't always true)
    alias topcpu="top -o '%CPU'"
    alias topmem="top -o '%MEM'"
else
    # It's (probably) BSD ps; hopefully "r" and "m" do what we want
    alias pscpu="ps auxr"
    alias psmem="ps auxm"
    alias topcpu="top -o cpu"
    alias topmem="top -o size"
fi

alias lsq='/bin/ls'
alias la='ls -A'
alias ll='ls -alF'
alias lh='ll -h'
alias l='ls -F'
alias ..='cd .. && ls'
alias ,,='cd - && ls'

alias exir='exit'
alias cim=vim
alias bim=vim
alias v='vim -p'

alias dump='hexdump -C'

alias wp='telnet telnet.wmflabs.org'
alias weather='curl wttr.in'

if cmd-exists git; then
    alias fir=git
    alias fur=git
    alias submodule='git submodule update --init --recursive'
    #alias go='git checkout'
    # (conflicts with golang)
fi

if cmd-exists swapon; then
    alias topswap="swapon --show"
    alias swaptop="swapon --show"
fi

if cmd-exists journalctl; then
    alias syslogtail='journalctl -xe'
    alias syslog='journalctl -xe'
fi

if cmd-exists sudo; then
    alias root='sudo -EHs'
    # Some common typos (I'm a terrible typist...)
    alias tooy='sudo -EHs'
    alias duso=sudo
    alias sodu=sudo
fi

# cd && ls
c() {
    cd "$@" && ls
}

# cd - && ls
-() {
    cd - && ls
}

# cd && ll
cl() {
    cd "$@" && ls -alF
}

# mkdir && cd
mc() {
    mkdir "$@" && cd "${@:$#}" && ls
}


###################
## Mini-Programs ##
###################


# Temp HTTP server
temp-http-server() {
    if cmd-exists python3; then
        python3 -m http.server "$@"
    elif cmd-exists python2; then
        python2 -m SimpleHTTPServer "$@"
    else
        # Probably python 2
        python -m SimpleHTTPServer "$@"
    fi
}
if ! cmd-exists http; then
    alias http=temp-http-server
fi


# "telnet" thru SSL/TLS
# (mostly because I can never remember the damn openssl incantation)
telnet-ssl() {
    if [ $# -eq 0 -o $# -gt 2 ]; then
        echo "Usage:  telnet-ssl  host  [port]"
        return 2
    elif [ $# -eq 1 ]; then
        openssl s_client -connect "$1:443"
    else
        openssl s_client -connect "$1:$2"
    fi
}
telnet-imap-starttls() {
    if [ $# -eq 0 -o $# -gt 2 ]; then
        echo "Usage:  telnet-starttls-imap  host  [port]"
        return 2
    elif [ $# -eq 1 ]; then
        openssl s_client -debug -starttls imap -crlf -connect "$1:143"
    else
        openssl s_client -debug -starttls imap -crlf -connect "$1:$2"
    fi
}
telnet-ssl-sni() {
    if [ $# -eq 0 -o $# -gt 2 ]; then
        echo "Usage:  telnet-ssl-sni  host  [port]"
        return 2
    elif [ $# -eq 1 ]; then
        openssl s_client -servername "$1" -connect "$1:443"
    else
        openssl s_client -servername "$1" -connect "$1:$2"
    fi
}


# Calculator
=() {
    local calc="$@"
    if [ "$calc" ] ; then
        bc -l <<< "scale=8;$calc"
    else
        man bc
    fi
}
alias bc2='bc -l <( echo "scale=2;" )'
alias bc4='bc -l <( echo "scale=4;" )'
alias bc8='bc -l <( echo "scale=8;" )'

# Time calculator
==() {
    local hours=0
    local mins=0
    while true; do
        local utime=0
        printf "%02d:%02d += " "$hours" "$mins"
        read utime
        if [ ! "$utime" ]; then
            break
        fi

        local parts=(${utime//:/ })
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

        # TODO: handle negatives
    done
}

# Feet and inches calculator
===() {
    local feet=0
    local inches=0
    while true; do
        local input=0
        printf "%02d' %02d\" += " "$feet" "$inches"
        read input
        if [ ! "$input" ]; then
            break
        fi

        if [ "$input" = "in" ]; then
            printf "%02d\"\n" "$(expr "$feet" '*' 12 + "$inches")"
            continue
        fi

        input="${input//\'/\' }"
        input="${input//\"/\" }"
        input="${input//-/ - }"
        negative=
        saw_feet_or_inches=no
        for part in $input; do
            case "$part" in
                -)
                    # Negation part
                    if [ "$saw_feet_or_inches" = yes ]; then
                        echo "Ignoring negation in the middle of the expression (negation should only be at the front)"
                    else
                        negative=-
                    fi
                    ;;
                *\')
                    # Feet part
                    feet="$(expr "$feet" + "$negative${part:0: -1}")"
                    saw_feet_or_inches=yes
                    ;;
                *\")
                    # Inches part
                    inches="$(expr "$inches" + "$negative${part:0: -1}")"
                    saw_feet_or_inches=yes
                    ;;
                *)
                    echo "Unknown part: $part"
                    ;;
            esac
        done

        # Make sure inches < 12
        while [ "$inches" -ge 12 ]; do
            feet="$(expr "$feet" + 1)"
            inches="$(expr "$inches" - 12)"
        done

        # Make sure inches > 0
        while [ "$inches" -lt 0 ]; do
            feet="$(expr "$feet" - 1)"
            inches="$(expr "$inches" + 12)"
        done

        # If feet are negative, make sure inches are too
        if [ "$feet" -lt 0 -a "$inches" -gt 0 ]; then
            feet="$(expr "$feet" + 1)"
            inches="$(expr "$inches" - 12)"
        fi
    done
}

# sudo shortcut
please() {
    local lastcmd="$(fc -ln -- -1)"
    if [ "$1" = "please" ] || [ "$1" = "plz" ] || [ "$1" = "" ]; then
        sudo $lastcmd
    else
        sudo "$@"
    fi
}
alias plz=please
alias bitch=please
alias bitch,=please

# open something using "open" or "xdg-open" as the graphical user
open_this_user="$BASHRC_GRAPHICAL_USER"
open-this() {
    local item="$1"
    if [ ! "$item" ]; then
        # No item specified, use current directory
        item="."
    fi

    local opener=open
    if cmd-exists xdg-open; then
        opener=xdg-open
    fi

    if [ "$open_this_user" ]; then
        sudo -EHu "$open_this_user" $opener "$item" >/dev/null 2>&1
    else
        $opener "$item" >/dev/null 2>&1
    fi
}
open-this-deprecated() {
    echo "Deprecated; use \`, $@' instead"
    open-this "$@"
}
# TODO: Once we stop using ... for open-this, use it for "cd ../.. && ls"
alias ...=open-this-deprecated
alias ,=open-this

# do something in a subshell with a different mask, or change the umask
switch_umask() {
    local mask="$1"
    shift
    if [ "$#" -gt 0 ]; then
        (                               \
            ORIG_UMASK="$(umask -S)";   \
            umask "$mask";              \
            echo -n "umask: ";          \
            umask -S;                   \
            "$@";                       \
            echo "umask: $ORIG_UMASK";  \
        )
    else
        umask "$mask"
        echo -n "umask: "
        umask -S
    fi
}
alias .u='switch_umask  0077'
alias .g='switch_umask  0027'
alias .go='switch_umask 0022'
alias .gw='switch_umask 0002'


##################
## Shell Prompt ##
##################


_pwd() {
    local dir="$(pwd)"
    if [ "${dir:0:${#HOME}}" = "$HOME" ]; then
        dir="~${dir:${#HOME}}"
    fi
    echo "$dir"
}


if [ "$BASHRC_GIT_PROMPT" ]; then
    if [ -r /usr/share/git/completion/git-prompt.sh ]; then
        . /usr/share/git/completion/git-prompt.sh
    elif [ -r /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
        . /usr/share/git-core/contrib/completion/git-prompt.sh
    fi
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
fi

_ps1_git_prompt="$BASHRC_GIT_PROMPT"

_ps1_dir_setup() {
    dir="$(_pwd)"
    if [ ! "$dir" ]; then
        return
    fi

    local git_ps1=""
    if [ "$_ps1_git_prompt" ]; then
        git_ps1="$(__git_ps1 " (%s)")"
    fi

    local git_repo_dir=""
    local git_repo_sub_dir=""

    # If we're in a git repository...
    if [ "$git_ps1" ]; then
        local this_dir=""
        local other_dirs=""

        # Find the root of the repo (look until we're in the root of the repo
        # or at the root of the filesystem or home directory)
        # TODO: avoid using "cd" here since it breaks using "cd -"
        local orig_pwd="$(pwd)"
        until [ -d .git ] || [ "${#dir}" -le 2 ]; do
            # Not at the root of the git repo yet
            cd ..
            other_dirs="$(echo "$dir" | sed 's/\/[^/]*$//')"
            this_dir="${dir:${#other_dirs}}"
            dir="$other_dirs"
            git_repo_dir="$this_dir$git_repo_dir"
        done
        cd "$orig_pwd"

        # Make pretty
        other_dirs="$(echo "$dir" | sed 's/\/[^/]*$//')"
        this_dir="${dir:$(expr "${#other_dirs}" "+" "1")}"

        dir="$other_dirs/"
        git_repo_sub_dir="$git_repo_dir"
        git_repo_dir="$this_dir"
    fi

    _ps1_dir="$dir"
    _ps1_git_repo_name="$git_repo_dir"
    _ps1_git_repo_dir="$git_repo_sub_dir$git_ps1"
}

_ps1_dir_a() {
    # The part of the path before the git repo
    echo "$_ps1_dir"
}

_ps1_dir_b() {
    # The name of the root dir of the git repo
    echo "$_ps1_git_repo_name"
}

_ps1_dir_c() {
    # The subdirectory of the root dir of the git repo that we're in
    # (and the "__git_ps1" info, including branch, etc.)
    echo "$_ps1_git_repo_dir"
}

_ps1_job_count() {
    local running=$(jobs -rp | wc -l | tr -d ' ')
    local stopped=$(jobs -sp | wc -l | tr -d ' ')
    ((running+stopped)) && echo "${running}r/${stopped}s "
}

_ps1_kube() {
    if type -t kube_ps1 >/dev/null; then
        echo "$(kube_ps1) "
    fi
}


PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_ps1_dir_setup"

use_color=""
if [ "$BASHRC_COLOR_PROMPT" ]; then
    case "$TERM" in
        xterm*|rxvt*|Eterm|aterm|kterm|gnome*|screen)
            use_color=1
            ;;
    esac
fi

if [ "$use_color" ]; then
    # These are only meant to be used in the PS1
    red="\\[$(tput setaf 1)\\]"
    green="\\[$(tput setaf 2)\\]"
    yellow="\\[$(tput setaf 3)\\]" # This is more of a "mustard yellow"
    blue="\\[$(tput setaf 4)\\]"
    purple="\\[$(tput setaf 5)\\]"
    teal="\\[$(tput setaf 6)\\]"

    bold="\\[$(tput bold)\\]"
    reset="\\[$(tput sgr0)\\]"
fi

name_part=""
[ "$BASHRC_NO_USERNAME" ] || name_part="$name_part"'\u'
[ "$BASHRC_NO_UMASK" ] || name_part="$name_part"'[$(a="$(umask)"; echo "${a:1}")]'
[ "$BASHRC_NO_HOSTNAME" ] || name_part="$name_part"'@\h'
if [ ! "$BASHRC_NO_USERNAME" ] || [ ! "$BASHRC_NO_UMASK" ] || [ ! "$BASHRC_NO_HOSTNAME" ]; then
    name_part="$name_part"':'
fi

last_part='\$'
[ "$(id -u)" -eq 0 ] && last_part="$red#"

# [return code] [job counts] [kube] username@hostname:pwd [git branch] $
PS1="$bold$teal"'$(a="$?"; if [ "$a" -ne 0 ]; then echo "$a "; fi)'"$reset$teal"'$(_ps1_job_count)'"$reset"'$(_ps1_kube)'"$name_part$teal"'$(_ps1_dir_a)'"$bold"'$(_ps1_dir_b)'"$reset$teal"'$(_ps1_dir_c)'"$last_part$reset"' '

if [ "$use_color" ]; then
    unset red
    unset green
    unset yellow
    unset blue
    unset purple
    unset teal
    unset bold
    unset reset
fi
unset use_color
unset name_part
unset last_part

PS2='> '
PS3='> '
PS4='+ '

# Set the terminal title bar (using magic escape codes in PROMPT_COMMAND)
case "$TERM" in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        middle=""
        [ "$BASHRC_NO_USERNAME" ] || middle="$middle"'${USER}'
        [ "$BASHRC_NO_HOSTNAME" ] || middle="$middle"'@${HOSTNAME%%.*}'
        if [ ! "$BASHRC_NO_USERNAME" ] || [ ! "$BASHRC_NO_HOSTNAME" ]; then
            middle="$middle"':'
        fi
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s%s\007" "'"$middle"'" "$(_pwd)"'
        unset middle
        ;;

    screen)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        ;;
esac

