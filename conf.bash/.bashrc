# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ========== history

# don't put duplicate lines
# HISTCONTROL=ignoreboth
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=400000
HISTFILESIZE=500000

# ========== interfase

# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# use arrow for search a command
export PROMPT_COMMAND='history -a'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# short patch in command line
export PS1='$(whoami):${PWD/*\//}>'

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ========== set tab title

function tab_title {
  if [ -z "$1" ]
  then
    title=${PWD##*/} # current directory
  else
    title=$1 # first param
  fi

  default_cmd="history -a"
  if [[ $default_cmd != "${BASH_COMMAND}" ]]
  then
    title="$title:${BASH_COMMAND}"
  fi

  echo -n -e "\033]0;$title\007"
}

trap 'tab_title' DEBUG

# ========== golang settings

export GOROOT=/usr/local/go
export GOPATH=$HOME/BUFF/projects/golang
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export GOBIN=$GOPATH/bin

# ========== javascript settings
export PATH="$PATH:./node_modules/.bin"

# ========== ranger settings
export EDITOR=vim
