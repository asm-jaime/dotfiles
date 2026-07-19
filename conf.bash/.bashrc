# Stop here for non-interactive shells.
case $- in
  *i*) ;;
  *) return ;;
esac

# Share useful history between open terminals without keeping duplicates.
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=400000
HISTFILESIZE=500000
shopt -s histappend
shopt -s checkwinsize

# Up/down search from the text already typed on the command line.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Keep the prompt compact and update the terminal title at each prompt. Using
# PROMPT_COMMAND avoids the old DEBUG trap firing for every shell command.
__dotfiles_prompt_command() {
  local last_status=$?
  history -a
  history -n
  printf '\033]0;%s\007' "${PWD##*/}"
  return "$last_status"
}
PROMPT_COMMAND=__dotfiles_prompt_command
PS1='\u:\W> '

# User-level command locations needed by the current Vim/.NET workflow.
__dotfiles_path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

for user_bin in \
  "$HOME/.local/bin" \
  "$HOME/.dotnet/tools" \
  "$HOME/.opencode/bin" \
  /usr/local/cuda-12.4/bin
do
  if [ -d "$user_bin" ]; then
    __dotfiles_path_prepend "$user_bin"
  fi
done
unset user_bin
unset -f __dotfiles_path_prepend
export PATH

if [ -d /usr/local/cuda-12.4/lib64 ]; then
  case ":${LD_LIBRARY_PATH:-}:" in
    *:/usr/local/cuda-12.4/lib64:*) ;;
    *) LD_LIBRARY_PATH="/usr/local/cuda-12.4/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" ;;
  esac
  export LD_LIBRARY_PATH
fi

export EDITOR=vim
export VISUAL=vim

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if command -v notify-send >/dev/null 2>&1; then
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history 1 | sed -E "s/^ *[0-9]+ +//; s/[;&|] *alert$//")"'
fi

if [ -f "$HOME/.bash_aliases" ]; then
  . "$HOME/.bash_aliases"
fi

if ! shopt -oq posix; then
  if [ -r /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -r /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Keep host-specific additions outside the repository-managed file.
if [ -r "$HOME/.bashrc.local" ]; then
  . "$HOME/.bashrc.local"
fi
