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
    local domain=${1:-}

   if  isValidDomain "$domain"; then
        local base_dir="$HOME/Hunts/$domain"
        echo -e "${green}[+]$reset ${yellow}Creating initial folders and files on $base_dir to open the hunt...$reset"

        mkdir -p "$base_dir"/{recon,exploits}
        touch "$base_dir"/notes.dat

        cd "$base_dir"

        echo -e "[+] Finished succesfully, enjoy your hunt $USER!"
    else 
        echo -e "[-] The argument is not a valid domain"
    fi
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
        subfinder -d $domain --silent -nW -o "$BASE_DIR/subfinder_subdomains.txt"
       
        all_subdomains=$(cat "$BASE_DIR/*.txt" | sort -u | grep -Ev "^(2a\.|\*\.)?$domain$" | tee "$BASE_DIR/all_subdomains.txt")
        total_results=$(wc -l "$BASE_DIR/all_subdomains.txt" | grep -Eo '[0-9]+')

        echo -e "${green}[+]$reset ${yellow}Found a total of ${cyan}${total_results}$reset ${yellow}subdomains${reset}\n"
        
        echo -e "${green}[+]$reset ${yellow}Creating folders for each subdomain found${reset}\n"
        echo -e "$all_subdomains" | xargs -P10 -I {} mkdir -p "$BASE_DIR"/{}

        echo -e "${green}[+]$reset ${yellow}Running gau to fetch available urls on root domain $domain${reset}\n"
        gau --retries 3 --blacklist png,jpg,gif,jpeg,svg,css,ttf,woff --fc 404,302 --threads 50 -o "$BASE_DIR"/urls.txt "$domain" 

        echo -e "${green}[+]$reset ${yellow} Running httpx tool on gathered urls from root domain $domain${reset}\n"
        httpx -sc -ip -fr -list "$BASE_DIR"/urls.txt -o "$BASE_DIR"/http_probe

        echo -e "${green}[+]$reset ${yellow}Looking for .js files on root domain $domain${reset}\n"
        getjs --complete --url "https://$domain" --verbose --output "$BASE_DIR"/js_files.txt

        while IFS= read -r subdomain; do
            local SUBDOMAIN_BASE_DIR="$BASE_DIR/$subdomain"

            echo -e "${green}[+]$reset ${yellow}Looking for .js files on $subdomain${reset}\n"
            getjs --complete --url "https://$subdomain" --verbose --output "$SUBDOMAIN_BASE_DIR/js_files.txt"

            echo -e "${green}[+]$reset ${yellow}Running gau to fetch available urls on $subdomain${reset}\n"
            gau --retries 3 --blacklist png,jpg,gif,jpeg,svg,css,ttf,woff --fc 404,302 --threads 50 -o "$SUBDOMAIN_BASE_DIR/urls.txt" "$subdomain"

            if [[ -f "$SUBDOMAIN_BASE_DIR/urls.txt" ]]; then 
                echo -e "${green}[+]$reset ${yellow} Running httpx tool on gathered urls from subdomain $domain${reset}\n"
                httpx -sc -ip -fr -list "$SUBDOMAIN_BASE_DIR/urls.txt" -o "$SUBDOMAIN_BASE_DIR/http_probe"
            fi

        done <<< "$all_subdomains"

        end_time=$(date +%s.%N)
        elapsed_time=$(echo "$end_time - $start_time" | bc)
        printf "Enumeration finished on a total of %.2f seconds.\n" "$elapsed_time"
    else 
        echo -e "[-] The argument is not a valid domain"
    fi
}