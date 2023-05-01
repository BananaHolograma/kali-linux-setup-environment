# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

function erase_history { local HISTSIZE=0; }

function zshaddhistory_erase_history {
  [[ $1 != [[:space:]]#erase_history[[:space:]]# ]]
}
zshaddhistory_functions+=(zshaddhistory_erase_history)


# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

configure_prompt() {
    prompt_symbol=㉿
    # Skull emoji for root terminal
    #[ "$EUID" -eq 0 ] && prompt_symbol=💀
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
            # Right-side prompt with exit codes and background processes
            #RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'
            ;;
        oneline)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{%(#.red.blue)}%n@%m%b%F{reset}:%B%F{%(#.blue.green)}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
        backtrack)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n@%m%b%F{reset}:%B%F{blue}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac
    unset prompt_symbol
}

# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [ "$color_prompt" = yes ]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1

    configure_prompt

    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=white,underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[path]=bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%(#.#.$) '
fi
unset color_prompt force_color_prompt

toggle_oneline_prompt(){
    if [ "$PROMPT_ALTERNATIVE" = oneline ]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%n@%m: %~\a'
    ;;
*)
    ;;
esac

precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$NEWLINE_BEFORE_PROMPT" = yes ]; then
        if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
            _NEW_LINE_BEFORE_PROMPT=1
        else
            print ""
        fi
    fi
}

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

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

export CHROME_DESKTOP_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36"
export EDGE_DESKTOP_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.69"
export FIREFOX_DESKTOP_AGENT="Mozilla/5.0 (Windows NT 10.0; rv:111.0) Gecko/20100101 Firefox/111.0"
export ANDROID_MOBILE_AGENT="Mozilla/5.0 (Linux; Android 11; SM-A507FN) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Mobile Safari/537.36"
export IPHONE_MOBILE_AGENT="Mozilla/5.0 (iPhone; CPU iPhone OS 16_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) GSA/258.1.520699392 Mobile/15E148 Safari/604.1"
export GOOGLE_BOT_DESKTOP_AGENT="Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Chrome/W.X.Y.Z Safari/537.36"

# Custom Aliases
alias cat='batcat'
alias catn="/usr/bin/cat"

alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

alias kssh='kitty +kitten ssh'

alias nmap='grc nmap --script-args http.useragent="$CHROME_DESKTOP_AGENT"'
alias wpscan="grc wpscan --ua $FIREFOX_DESKTOP_AGENT"
alias curl="curl -A $EDGE_DESKTOP_AGENT"
alias wget="wget -U $ANDROID_MOBILE_AGENT"

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

##( Colors
#
#( fg
red='\e[31m'
lred='\e[91m'
green='\e[32m'
lgreen='\e[92m'
yellow='\e[33m'
lyellow='\e[93m'
blue='\e[34m'
lblue='\e[94m'
magenta='\e[35m'
lmagenta='\e[95m'
cyan='\e[36m'
lcyan='\e[96m'
grey='\e[90m'
lgrey='\e[37m'
white='\e[97m'
black='\e[30m'
##)
#( bg
b_red='\e[41m'
b_lred='\e[101m'
b_green='\e[42m'
b_lgreen='\e[102m'
b_yellow='\e[43m'
b_lyellow='\e[103m'
b_blue='\e[44m'
b_lblue='\e[104m'
b_magenta='\e[45m'
b_lmagenta='\e[105m'
b_cyan='\e[46m'
b_lcyan='\e[106m'
b_grey='\e[100m'
b_lgrey='\e[47m'
b_white='\e[107m'
b_black='\e[40m'
##)
#( special
reset='\e[0;0m'
bold='\e[01m'
italic='\e[03m'
underline='\e[04m'
inverse='\e[07m'
conceil='\e[08m'
crossedout='\e[09m'
bold_off='\e[22m'
italic_off='\e[23m'
underline_off='\e[24m'
inverse_off='\e[27m'
conceil_off='\e[28m'
crossedout_off='\e[29m'
##)
#)

isValidDomain() {
    local domain=${1:-}

    # Seems that ZSH does not support return directly [[ ... ]]
    if [[ -n $domain && $domain =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.[a-zA-Z]{2,24}$ ]]; then 
        return 0
    else 
        return 1
    fi
}

startDomainHunt() {
    local DOMAIN=${1:-}

   if  isValidDomain "$DOMAIN"; then
        local BASE_DIR="$HOME/Hunts/$DOMAIN"
        echo -e "${green}[+]$reset ${yellow}Creating initial folders and files on $BASE_DIR to open the hunt...$reset"

        mkdir -m 766 -p "$BASE_DIR"/{recon,exploits}
        touch "$BASE_DIR"/notes.dat
       
        cd "$BASE_DIR"

        echo -e "[+] Finished succesfully, enjoy your hunt $USER!"
    else 
        echo -e "[-] The argument is not a valid domain"
    fi
}

fetchDomainData() {
    local DOMAIN=$1
    local BASE_DIR=${2:-"$HOME/Hunts/$(echo $DOMAIN | awk -F "." '{print $(NF-1)"."$NF}')/recon/$DOMAIN"}
    # Translate example.com to example\.com to make valid as value on regex
    local regex_domain=$(echo $DOMAIN | sed 's/\./\\./g')

    echo -e "${green}[+]$reset ${yellow}Running gau to fetch available urls on domain $DOMAIN${reset}"
    gau --retries 3 --blacklist png,jpg,gif,jpeg,svg,css,ttf,woff --fc 404,302 --threads 50 --o "$BASE_DIR/urls.txt" "$DOMAIN" 

    if [[ -f "$BASE_DIR/urls.txt" ]]; then 
        echo -e "${green}[+]$reset ${yellow}Running httpx tool on gathered urls from domain $DOMAIN${reset}\n"
        grep -Ei "$regex_domain" "$BASE_DIR/urls.txt" | sort -u | httpx -favicon -title -method -sc -ip -fr -o "$BASE_DIR/http_probe"
    
        echo -e "${green}[+]$reset ${yellow}Gathering extra urls and js files with hakrawler on domain $DOMAIN${reset}\n"
        cat "$BASE_DIR/http_probe" | awk '{print $1}' | sort -u | hakrawler -t 20 -proxy http://127.0.0.1:9050 -timeout 5 >> "$BASE_DIR/urls.txt"
    fi

    echo -e "${green}[+]$reset ${yellow}Looking for .js files on domain $DOMAIN${reset}\n"
    getjs --insecure --complete --url "https://$DOMAIN" --output "$BASE_DIR/js_files.txt"
}

runEnumeration() {
    local domain=${1:-$(basename $PWD)}

    if  isValidDomain "$domain"; then
        local start_time=$(date +%s.%N)
        local BASE_DIR="$HOME/Hunts/$domain/recon"

        echo -e "${green}[+]$reset ${yellow}Initial enumeration started for domain $domain${reset}\n"
        crt -o "$BASE_DIR" $domain

        echo -e "${green}[+]$reset ${yellow}Running amass basic enumeration, be patient...${reset}\n"
        amass enum --passive -d $domain -o "$BASE_DIR/amass_subdomains.txt"

        echo -e "${green}[+]$reset ${yellow}Running subfinder passive enumeration${reset}\n"
        subfinder -d $domain -sources "alientvault,anubis,commoncrawl,digitorus,dnsdumpster,hackertarget,rapiddns,riddler,waybackarchive" -silent -nW -o "$BASE_DIR/subfinder_subdomains.txt"
       
        # Make grepable the TLD termination like .com, .es .org, etc
        regex_domain=$(echo $domain | sed 's/\./\\./g')

        # Filter and remove duplicates
        find "$BASE_DIR" -type f -name '*subdomains.txt' -not -name "all_subdomains.txt" -not -name "asn.txt" -exec cat {} >> "$BASE_DIR/all_subdomains.txt" \;
        cat "$BASE_DIR/all_subdomains.txt" | grep -Ev "(2a\.|\*\.)+$regex_domain" | grep -Ev "^(www.)?$regex_domain$" | sort -u > .tmp && mv .tmp "$BASE_DIR/all_subdomains.txt"

        total_results=$(wc -l "$BASE_DIR/all_subdomains.txt" | grep -Eo '[0-9]+')
        echo -e "${green}[+]$reset ${yellow}Found a total of ${cyan}${total_results}$reset ${yellow}subdomains${reset}"
        
        # Create a folder for each subdomain
        cat "$BASE_DIR/all_subdomains.txt" | xargs -P10 -I {} mkdir -m 766 -p "$BASE_DIR/{}"

        echo -e "${green}[+]$reset ${yellow}Retrieving ASN numbers for the given subdomains${reset}"
        cat "$BASE_DIR/all_subdomains.txt" | dnsx -silent -asn -o "$BASE_DIR/asn.txt"

        echo -e "${green}[+]$reset ${yellow}DNS lookup on $domain${reset}\n"
        dnsrecon -a -d "$domain" > "$BASE_DIR/dns.txt"
        dig @1.1.1.1 "$domain" >> "$BASE_DIR/dns.txt"
        whois -h whois.radb.net $(dig +short "$domain" | head -1) > "$BASE_DIR/whois.txt"
        cat "$BASE_DIR/all_subdomains.txt" | xargs -P4 -I {} host {} >> "$BASE_DIR/hosts.txt"  
       
        echo -e "${green}[+]$reset${yellow} Adding extra permuted subdomains and resolve with puredns to retrieve only valid domains...${reset}"
        gotator -sub "$BASE_DIR/all_subdomains.txt" -perm /usr/share/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -depth 1 -numbers 10 -mindup -adv -md -silent > "$BASE_DIR/subdomains_to_resolve.txt"

        if [[ -f "$BASE_DIR/subdomains_to_resolve.txt" ]]; then
            puredns resolve "$BASE_DIR/subdomains_to_resolve.txt" -r "$HOME/dns-resolvers/resolvers.txt" --resolvers-trusted "$HOME/dns-resolvers/resolvers-trusted.txt" --write "$BASE_DIR/valid_subdomains.txt"
        fi 
        
        fetchDomainData "$domain" "$BASE_DIR" 1>/dev/null &

        cat "$BASE_DIR/valid_subdomains.txt" 2>/dev/null || cat "$BASE_DIR/all_subdomains.txt" | xargs -P10 -I {} zsh -c '. "$HOME/.zshrc"; DOMAIN="{}"; eval "$(typeset -f fetchDomainData)"; fetchDomainData "$DOMAIN"'  
   
        end_time=$(date +%s.%N)
        elapsed_time=$(echo "$end_time - $start_time" | bc)
        printf "Enumeration finished for $domain on a total of %.2f seconds.\n" "$elapsed_time"
    else 
        echo -e "[-] The argument is not a valid domain"
    fi
}
