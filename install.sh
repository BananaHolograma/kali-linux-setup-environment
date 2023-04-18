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
        read -r SUDO_PASSWORD
    done 
done

HOME_DIR="/home/$SELECTED_USER"
ROOT_DIR="/root"


# Common folders to work
target_home_config_dir="$HOME_DIR/.config"
config_backup_folder="$HOME_DIR/backup/${SELECTED_USER}.config"

function prepareEnvironmentForTheInstallation() {
    if [ -d "$target_home_config_dir" ]; then
        echo -e "${grayColour}[ PREPARATION ]$endColour ${yellowColour}Detected existing$endColour$cyanColour .config$endColour$yellowColour folder, creating backup on$endColour$cyanColour $config_backup_folder$endColour"

        mkdir -p "$config_backup_folder" \
            && cp -r "$target_home_config_dir" "$config_backup_folder"
    fi

    echo -e "${grayColour}[ PREPARATION ]$endColour$yellowColour Installing packages that are needed in the system to continue the process...$endColour"
    
    # We only need to provide the sudo password one time at the start of the script
    echo "$SUDO_PASSWORD" | sudo -S apt update

    sudo apt upgrade -y && sudo apt install -y git curl wget vim net-tools iputils-ping tldr docker.io docker-compose rsync tee
}

function setupCustomTerminalFont() {
    local fonts_dir="$HOME_DIR/.fonts"

    if [[ -f "$fonts_dir"/Hack\ Regular\ Nerd\ Font\ Complete.ttf ]]; then
        echo -e "${grayColour}[ FONTS ]$endColour$yellowColour HackNerdFont font is already installed in the system, skipping...${endColour}"
    else
        echo -e "${grayColour}[ FONTS ]$endColour$yellowColour Downloading HackNerdFont from$endColour$yellowColour https://github.com/ryanoasis/nerd-fonts$endColour"

        mkdir -p "$fonts_dir"
        
        if curl -sLo Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip; then 
            unzip -oq Hack.zip -d "$fonts_dir" && rm Hack.zip
        else 
             find "$CURRENT_DIR/config/fonts/HackNerdFont" -type f -execdir cp -t "$fonts_dir" {} +
        fi

        echo -e "${grayColour}[ FONTS ]$endColour$yellowColour Fonts installed and configured in$endColour$yellowColour $fonts_dir $endColour"
    fi
}

function setupAndConfigureKitty() {
    echo -e "${grayColour}[ KITTY ]$endColour$yellowColour Installing and configuring kitty GPU based terminal...$endColour"

    sudo apt install -y kitty \
        && cp -r "$CURRENT_DIR/config/kitty" "$target_home_config_dir"

    echo -e "${grayColour}[ KITTY ]$endColour$yellowColour Kitty GPU based terminal installed and configured on$endColour$cyanColour [ $(which kitty) ]$endColour"
}

function setupVim() {
    echo -e "${grayColour}[ VIM ]$endColour Installing and configuring VIM editor with basic initial configuration"
    local VIM_CONFIG_DIR="$CURRENT_DIR/config/vim/"
    
    sudo apt install -y vim

    if [ -f "$HOME_DIR"/.vimrc ]; then
        echo -e "${grayColour}[ VIM ]$endColour$yellowColour Detected existing .vimrc file, creating backup on$endColour$cyanColour $config_backup_folder"
        cp "$HOME_DIR"/.vimrc "$config_backup_folder"
    fi

    [[ -f "$VIM_CONFIG_DIR/.vimrc" ]] && cp "$VIM_CONFIG_DIR/.vimrc" "$HOME_DIR"

    echo -e "${grayColour}[ VIM ]$endColour$yellowColour Created$endColour$cyanColour .vimrc$endColour$yellowColour file on $HOME_DIR directory$endColour"
}

function setupZSH() {
    echo -e "${grayColour}[ ZSH ]$endColour$yellowColour Installing and configuring zsh$endColour"

    local ZSH_CONFIG_DIR="$HOME_DIR/.config/zsh"

    sudo apt install -y zsh

    if [ -f "$HOME_DIR"/.zshrc ]; then
        echo -e "${grayColour}[ ZSH ]$endColour$yellowColour Detected existing .zshrc file, creating backup on$endColour$cyanColour $config_backup_folder"
        cp "$HOME_DIR"/.zshrc "$config_backup_folder"
    fi

    mkdir -p "$ZSH_CONFIG_DIR/plugins" 
    touch "$HOME_DIR/.zsh_history"

    if ! grep -i "go/bin" "$HOME_DIR/.zshrc"; then 
        cat "$CURRENT_DIR/config/zsh/.zshrc" >> "$HOME_DIR/.zshrc" 
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

function setupNVM() {
    if command_exists 'nvm'; then 
        echo -e "${grayColour}[ NVM ]$endColour$yellowColour NVM (Node Version Manager) is already installed, skipping...$endColour"
    else 
        echo -e "${grayColour}[ NVM ]$endColour$yellowColour Installing NVM (Node Version Manager) and set as default the LTS version$endColour"

        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        
        source "$HOME_DIR/.zshrc"

        nvm install --lts && nvm use --lts
    fi
}

function setupInfoSecTools() {
    sudo apt remove python3-httpx && sudo apt autoremove --purge
    sudo apt install -y firejail python3 python3-pip tor sqlmap dnsrecon wafw00f whois amass massdns golang-go masscan nmap brutespray ffuf exploitdb

    if [[ ! -d "/usr/share/SecLists" ]]; then 
        wget -c -nc https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip \
            && sudo unzip -oq SecList.zip -d "/usr/share/" \
            && sudo mv /usr/share/SecLists-master /usr/share/SecLists \
            && sudo rm -f SecList.zip
    fi 

    if [[ ! -f "/usr/share/wordlists/rockyou.txt" ]]; then
        echo -e "${grayColour}[ WORDLISTS ]$endColour$yellowColour Extracting rockyou.txt.gz ... $endColour"
        sudo gunzip /usr/share/wordlists/rockyou.txt.gz
    fi 

    wget --output-document crt https://raw.githubusercontent.com/s3r0s4pi3ns/crt/main/crt.sh \
        && chmod +x crt && sudo mv crt /usr/local/bin/
   
    wget --output-document randomipzer https://raw.githubusercontent.com/s3r0s4pi3ns/randomipzer/main/randomipzer.sh \
        && chmod +x randomipzer && sudo mv randomipzer /usr/local/bin/

    # GO binary path is exported on .zshrc
    if command_exists 'go'; then 
        echo -e "${cyanColour}[ GOLANG ]$endColour$yellowColour Installing golang security tools ... $endColour"

        ! command_exists 'hakrawler' && go install github.com/hakluke/hakrawler@latest 
        ! command_exists 'gau' && go install github.com/lc/gau/v2/cmd/gau@latest
        ! command_exists 'subfinder' && go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        ! command_exists 'httpx' && go install github.com/projectdiscovery/httpx/cmd/httpx@latest
        ! command_exists 'gotator' && go install github.com/Josue87/gotator@latest
        ! command_exists 'getjs' && go install github.com/003random/getJS@latest
        
        if ! command_exists 'puredns' && command_exists 'massdns'; then 
            go install github.com/d3mondev/puredns/v2@latest

            if [[ ! -d "$HOME_DIR/dns-resolvers" ]]; then 
                wget -c -nc https://github.com/trickest/resolvers/archive/refs/heads/main.zip \
                    && unzip main.zip && mv resolvers-main "$HOME_DIR/dns-resolvers" && rm main.zip
            fi
        fi 

    fi
}

function setupTerminalUtils() {
    echo -e "${grayColour}[ TERMINAL UTILS ]$endColour Installing and configuring terminal utils...$endColour"
    
    sudo apt install -y bat fzf lsd bash-completion \
        && mkdir -p ~/.local/bin && ln -sf /usr/bin/batcat ~/.local/bin/bat
}

###
# START THE INSTALLATION AND CONFIGURATION PROCESS FOR THE NEW ENVIRONMENT
###
prepareEnvironmentForTheInstallation
setupCustomTerminalFont
setupAndConfigureKitty
setupVim
setupZSH
setupTerminalUtils
setupInfoSecTools
setupNVM

# Copy the entire configuration to root home folder in order to have same configuration
sudo cp -rf "$HOME_DIR"/.config "$ROOT_DIR"
sudo cp -rf "$HOME_DIR"/.fonts "$ROOT_DIR" 
sudo cp -f "$HOME_DIR"/.zshrc "$ROOT_DIR" 
sudo cp -f "$HOME_DIR"/.vimrc "$ROOT_DIR"
