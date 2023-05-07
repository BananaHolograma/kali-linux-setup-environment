#!/usr/bin/env zsh
#shellcheck disable=1071

set -o nounset                                                                                                                                         
set -o errexit                                                                                                                                         
set -o pipefail                                                                                                                                        
     
# ANSII ESCAPE CODE COLOURS
greenColour='\033[0;32m'
redColour='\033[0;31m'
blueColour='\033[0;34m'
yellowColour='\033[1;33m'
purpleColour='\033[0;35m'
cyanColour='\033[0;36m'
grayColour='\033[0;37m'

endColour='\033[0m'

CURRENT_DIR=$(dirname -- "$(readlink -f -- "$0")")

function user_exists() {
    local username=$1

    id -u "$username" &>/dev/null
}

function command_exists() {
    local command=$1

    [[ -n "$(command -v "$command")" ]]
}

SELECTED_USER=''
SUDO_PASSWORD=''
create_non_existing_user='n'

while ! user_exists "$SELECTED_USER" && [ "$create_non_existing_user" = 'n' ]; do 

    echo -n "Choose a user to apply the configuration: "
    read -r  SELECTED_USER

    if ! user_exists "$SELECTED_USER"; then 
        echo -e "${redColour}The selected user$endColour$yellowColour $SELECTED_USER$endColour$redColour does not exists in this system.$endColour"
        
        echo -n "Do you want to create it? [y]es / [n]o "
        read -r create_non_existing_user
        
        if [ "$create_non_existing_user" = 'y' ]; then 
            useradd -m -g users -G wheel "$SELECTED_USER"
            passwd "$SELECTED_USER"
        fi
    fi


    while [[ -z $SUDO_PASSWORD ]]; do 
        echo -n "Write the sudo password for your user $SELECTED_USER to install packages with privileges: " 
        read -s SUDO_PASSWORD
        printf "\n"

    done 
done

HOME_DIR="/home/$SELECTED_USER"
ROOT_DIR="/root"


# Common folders to work
TARGET_HOME_CONFIG_DIR="$HOME_DIR/.config"
CONFIG_BACKUP_FOLDER="$HOME_DIR/backup/${SELECTED_USER}.config"

function stepNeedInstallation() {
    local tmp_folder="/tmp/custom_kali_installation"
    local step=$1

    mkdir -p "$tmp_folder"

    if [[ ! -f "$tmp_folder/$step" ]]; then 
        touch "$tmp_folder/$step"
        return 0
    else 
        echo -e "${greenColour}[ INSTALLED ]$endColour${yellowColour} The step$endColour${greenColour} $step${endColour}${yellowColour} is already installed and configured, skipping...$endColour"
        return 1
    fi 

}

function prepareEnvironmentForTheInstallation() {
    if [ -d "$TARGET_HOME_CONFIG_DIR" ]; then
        echo -e "${cyanColour}[ PREPARATION ]$endColour ${yellowColour}Detected existing$endColour$cyanColour .config$endColour$yellowColour folder, creating backup on$endColour$cyanColour $CONFIG_BACKUP_FOLDER$endColour"

        mkdir -p "$CONFIG_BACKUP_FOLDER" \
            && cp -r "$TARGET_HOME_CONFIG_DIR" "$CONFIG_BACKUP_FOLDER"
    fi

    echo -e "${cyanColour}[ PREPARATION ]$endColour$yellowColour Installing and updating packages that are needed in the system to continue the process...$endColour"
    
    # We only need to provide the sudo password one time at the start of the script
    echo "$SUDO_PASSWORD" | sudo -S apt update -yqq

    sudo apt upgrade -yqq && sudo apt install -yqq -o=Dpkg::Use-Pty=0  grc jq net-tools iputils-ping socat cifs-utils tldr awscli docker.io docker-compose rsync parallel mongodb-clients freerdp2-x11

}

function setupCustomTerminalFont() {
    local fonts_dir="$HOME_DIR/.fonts"

    if [[ -f "$fonts_dir"/Hack\ Regular\ Nerd\ Font\ Complete.ttf ]]; then
        echo -e "${cyanColour}[ FONTS ]$endColour$yellowColour HackNerdFont font is already installed in the system, skipping...${endColour}"
    else
        echo -e "${cyanColour}[ FONTS ]$endColour$yellowColour Downloading HackNerdFont from$endColour$yellowColour https://github.com/ryanoasis/nerd-fonts$endColour"

        mkdir -p "$fonts_dir"
        
        if curl --fail -sLo Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip; then 
            unzip -oq Hack.zip -d "$fonts_dir" && rm Hack.zip
        else 
             find "$CURRENT_DIR/config/fonts/HackNerdFont" -type f -execdir cp -t "$fonts_dir" {} +
        fi

        echo -e "${grayColour}[ FONTS ]$endColour$yellowColour Fonts installed and configured in$endColour$yellowColour $fonts_dir $endColour"
    fi
}

function setupAndConfigureKitty() {
    echo -e "${cyanColour}[ KITTY ]$endColour$yellowColour Installing and configuring kitty GPU based terminal...$endColour"

    sudo apt install -yqq -o=Dpkg::Use-Pty=0 kitty \
        && cp -r "$CURRENT_DIR/config/kitty" "$TARGET_HOME_CONFIG_DIR"

    echo -e "${cyanColour}[ KITTY ]$endColour$yellowColour Kitty GPU based terminal installed and configured on$endColour$cyanColour [ $(which kitty) ]$endColour"
}

function setupVim() {
    echo -e "${cyanColour}[ VIM ]$endColour Installing and configuring VIM editor with basic initial configuration"
    local VIM_CONFIG_DIR="$CURRENT_DIR/config/vim"
    
    sudo apt install -yqq -o=Dpkg::Use-Pty=0 vim

    if [ -f "$HOME_DIR"/.vimrc ]; then
        echo -e "${grayColour}[ VIM ]$endColour$yellowColour Detected existing .vimrc file, creating backup on$endColour$cyanColour $CONFIG_BACKUP_FOLDER"
        cp "$HOME_DIR"/.vimrc "$CONFIG_BACKUP_FOLDER"
    fi

    [[ -f "$VIM_CONFIG_DIR/.vimrc" ]] && cp -f "$VIM_CONFIG_DIR/.vimrc" "$HOME_DIR"

    echo -e "${cyanColour}[ VIM ]$endColour$yellowColour Created$endColour$cyanColour .vimrc$endColour$yellowColour file on $HOME_DIR directory$endColour"
}

function setupZSH() {
    echo -e "${cyanColour}[ ZSH ]$endColour$yellowColour Installing and configuring zsh$endColour"

    local ZSH_CONFIG_DIR="$HOME_DIR/.config/zsh"

    sudo apt install -yqq -o=Dpkg::Use-Pty=0 zsh

    if [ -f "$HOME_DIR"/.zshrc ]; then
        echo -e "${grayColour}[ ZSH ]$endColour$yellowColour Detected existing .zshrc file, creating backup on$endColour$cyanColour $CONFIG_BACKUP_FOLDER"
        cp "$HOME_DIR"/.zshrc "$CONFIG_BACKUP_FOLDER"
    fi

    mkdir -p "$ZSH_CONFIG_DIR/plugins" 
    touch "$HOME_DIR/.zsh_history"

    if ! grep -i "go/bin" "$HOME_DIR/.zshrc"; then 
        cat "$CURRENT_DIR/config/zsh/.zshrc" > "$HOME_DIR/.zshrc" 
    fi

    if [[ ! -d "$ZSH_CONFIG_DIR/plugins/zsh-autosuggestions" ]]; then 
        git clone https://github.com/zsh-users/zsh-autosuggestions.git zsh-autosuggestions
        rm -rf zsh-autosuggestions/.git && mv zsh-autosuggestions "$ZSH_CONFIG_DIR/plugins/"
    fi
 
    if [[ ! -d "$ZSH_CONFIG_DIR/plugins/zsh-syntax-highlighting" ]]; then 
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting
        rm -rf zsh-syntax-highlighting/.git && mv zsh-syntax-highlighting "$ZSH_CONFIG_DIR/plugins/"
    fi

    source "$HOME_DIR/.zshrc"
}

function setupInfoSecTools() {
    echo -e "${cyanColour}[ INFOSEC TOOLS ]$endColour${yellowColour} Installing infosec tools...$endColour"
   
    sudo apt remove python3-httpx subfinder && sudo apt autoremove --purge
    sudo apt install -yqq -o=Dpkg::Use-Pty=0 firejail python3 python3-pip xxd ghidra tor sqlmap dnsrecon wafw00f burpsuite whois amass massdns golang-go masscan nmap brutespray ffuf exploitdb openjdk-11-jdk maven
    
    if [[ ! -d "/usr/share/SecLists" ]]; then 
        wget -c -nc https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip \
            && sudo unzip -oq SecList.zip -d "/usr/share/" \
            && sudo mv /usr/share/SecLists-master /usr/share/SecLists \
            && sudo rm -f SecList.zip
    fi 
    
    echo -e "${cyanColour}[ INFOSEC TOOLS ]$endColour${yellowColour} Preparing wordlists...$endColour"

    if [[ ! -d "/usr/share/wordlists" ]]; then 
        sudo apt install wordlists
    fi 
    
    if [[ ! -f "/usr/share/wordlists/rockyou.txt" ]]; then
        echo -e "${cyanColour}[ INFOSEC TOOLS ]$endColour${yellowColour} Extracting rockyou.txt.gz ... $endColour"
        sudo gunzip /usr/share/wordlists/rockyou.txt.gz
    fi 

    echo -e "${cyanColour}[ INFOSEC TOOLS ]$endColour${yellowColour} Downloading and configuring custom bash libraries... $endColour"

    libraries=(crt randomipzer ipharvest) 
    for library in "${libraries[@]}"
    do 
        wget --output-document "$library" https://raw.githubusercontent.com/s3r0s4pi3ns/"$library"/main/"$library".sh \
            && chmod +x "$library" && sudo mv "$library" /usr/local/bin/
    done 
    
    if [[ ! -d "$HOME_DIR"/xmlrpcpwn ]]; then 
        git clone https://github.com/s3r0s4pi3ns/xmlrpcpwn.git
        cd xmlrpcpwn && python3 setup.py install --user
        cd ..
        rm -rf xmlrpcpwn
    fi

    if [[ ! -d "$HOME_DIR"/jwt_sec_tool ]]; then 
        JWT_TOOL_DIR="$HOME_DIR"/jwt_sec_tool/jwt_tool.py

        python3 -m pip install termcolor cprint pycryptodomex requests
        git clone https://github.com/ticarpi/jwt_tool jwt_sec_tool
        chmod +x "$JWT_TOOL_DIR" && sudo cp "$JWT_TOOL_DIR" /usr/local/bin/jwt_tool
    fi 

    # GO binary path is exported on .zshrc
    if command_exists 'go'; then 
        echo -e "${cyanColour}[ INFOSEC TOOLS ]$endColour$yellowColour Installing golang security tools ... $endColour"

        ! command_exists 'hakrawler' && go install github.com/hakluke/hakrawler@latest 
        ! command_exists 'gau' && go install github.com/lc/gau/v2/cmd/gau@latest
        ! command_exists 'subfinder' && go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        ! command_exists 'httpx' && go install github.com/projectdiscovery/httpx/cmd/httpx@latest
        ! command_exists 'gotator' && go install github.com/Josue87/gotator@latest
        ! command_exists 'getjs' && go install github.com/003random/getJS@latest
        ! command_exists 'dnsx' && go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
        
        if ! command_exists 'puredns' && command_exists 'massdns'; then 
            echo -e "${cyanColour}[ INFOSEC TOOLS ]$endColour$yellowColour Setup valid DNS resolvers... $endColour"

            go install github.com/d3mondev/puredns/v2@latest

            if [[ ! -d "$HOME_DIR/dns-resolvers" ]]; then 
                mkdir -p "$HOME_DIR/dns-resolvers" \
                    && cp "$CURRENT_DIR"/dns-resolvers/{resolvers-trusted,resolvers}.txt "$HOME_DIR"/dns-resolvers
            fi     
        fi

    fi
}

function setupTerminalUtils() {
    echo -e "${cyanColour}[ TERMINAL UTILS ]$endColour ${yellowColour}Installing and configuring terminal utils...$endColour"
    
    sudo apt install -y bat fzf lsd bash-completion \
        && mkdir -p ~/.local/bin && ln -sf /usr/bin/batcat ~/.local/bin/bat
}

function setupScripts() {
        echo -e "${cyanColour}[ CUSTOM SCRIPTS ]$endColour ${yellowColour}Copying custom scripts into$endColour ${cyanColour}$HOME_DIR/scripts..$endColour"

        mkdir -p "$HOME_DIR/scripts" \
            && cp -rf "$CURRENT_DIR/scripts" "$HOME_DIR"
}

###
# START THE INSTALLATION AND CONFIGURATION PROCESS FOR THE NEW ENVIRONMENT
###
stepNeedInstallation "PREPARE_ENVIRONMENT" -eq 0 && prepareEnvironmentForTheInstallation
setupCustomTerminalFont
stepNeedInstallation "KITTY_GPU_TERMINAL" && setupAndConfigureKitty
stepNeedInstallation "VIM" -eq 0 && setupVim
stepNeedInstallation "ZSH" -eq 0 && setupZSH
stepNeedInstallation "TERMINAL_UTILS" -eq 0 && setupTerminalUtils
stepNeedInstallation "CUSTOM_SCRIPTS" -eq 0 && setupScripts
stepNeedInstallation "INFOSEC_TOOLS" -eq 0 && setupInfoSecTools

# Copy the entire configuration to root home folder in order to have same configuration
sudo cp -rf "$HOME_DIR"/.config "$ROOT_DIR"
sudo cp -rf "$HOME_DIR"/.fonts "$ROOT_DIR" 
sudo cp -f "$HOME_DIR"/.zshrc "$ROOT_DIR" 
sudo cp -f "$HOME_DIR"/.vimrc "$ROOT_DIR"
