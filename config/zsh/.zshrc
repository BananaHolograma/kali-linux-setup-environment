export ZSH=$HOME/.config/zsh
export HISTFILE=$ZSH/.zsh_history
 
# How many commands zsh will load to memory.
export HISTSIZE=1000
 
# How many commands history will save on file.
export SAVEHIST=1000
 
# History won't save duplicates.
setopt HIST_IGNORE_ALL_DUPS
 
# History won't show duplicates on search.
setopt HIST_FIND_NO_DUPS
export _JAVA_AWT_WM_NONREPARENTING=1¡
 
[ -d "$ZSH/plugins/zsh-autosuggestions" ] && source "$ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
 
[ -d "$ZSH/plugins/zsh-syntax-highlighting" ] && source "$ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -d "$ZSH/plugins/colored-man-pages" ] && source "$ZSH/plugins/colored-man-pages/colored-man-pages.zsh"

# Custom Aliases
alias cat='batcat'
alias catn="/usr/bin/cat"

alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

alias kssh='kitty +kitten ssh'

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/go/bin/:$PATH"