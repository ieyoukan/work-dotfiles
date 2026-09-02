# Generic interactive zsh configuration for macOS.

if command -v zed >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-zed --wait}"
else
  export EDITOR="${EDITOR:-vim}"
fi
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"

typeset -U path PATH
path=("$HOME/.local/bin" $path)

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INTERACTIVE_COMMENTS
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

autoload -Uz compinit
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{cyan}(%b)%f'
PROMPT='%F{blue}%n@%m%f %F{green}%1~%f${vcs_info_msg_0_} %# '

alias ls='ls -GF'
alias ll='ls -lhGF'
alias la='ls -lahGF'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph -20'
alias reload='exec zsh'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --group-directories-first'
  alias la='eza -lah --group-directories-first'
fi
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

for plugin in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -r "$plugin" ]] && source "$plugin" && break
done

for plugin in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -r "$plugin" ]] && source "$plugin" && break
done

# Machine-, company-, and identity-specific settings stay outside Git.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
