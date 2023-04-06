#!/usr/bin/env bash

set -eou pipefail

# ANSII ESCAPE CODE COLOURS
greenColour='\033[0;32m'
redColour='\033[0;31m'
blueColour='\033[0;34m'
yellowColour='\033[1;33m'
purpleColour='\033[0;35m'
cyanColour='\033[0;36m'
grayColour='\033[0;37m'

endColour='\033[0m'

CURRENT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function is_root() {
     [[ "$(id -u)" -eq 0 ]]
}

function user_exists() {
    local username=$1

    id -u "$username" &>/dev/null
}

SELECTED_USER=''
create_non_existing_user='n'

if ! is_root; then 
    echo -e "${yellowColour}[ WARNING ]$endColour$grayColour Run this script with sudo privileges$endColour"
    exit 1
fi 

while ! user_exists "$SELECTED_USER" && [ "$create_non_existing_user" = 'n' ]; do 

    read -rp "Choose a user to apply the configuration: " SELECTED_USER

    if ! user_exists "$SELECTED_USER"; then 
        echo -e "${redColour}The selected user$endColour$yellowColour $SELECTED_USER$endColour$redColour does not exists in this system.$endColour"
        
        read -rp "Do you want to create it? [y]es / [n]o " create_non_existing_user
        
        if [ "$create_non_existing_user" = 'y' ]; then 
            useradd -m -g users -G wheel "$SELECTED_USER"
            passwd "$SELECTED_USER"
        fi
    fi
done

HOME_DIR="/home/$SELECTED_USER"
ROOT_DIR="$HOME"


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
   
    pacman -Syu
    pacman -S base-devel git curl vim
}

function setupCustomTerminalFont() {
    echo -e "${grayColour}[ FONTS ]$endColour$yellowColour Downloading HackNerdFont from$endColour$yellowColour https://github.com/ryanoasis/nerd-fonts$endColour"

    local fonts_dir="$HOME_DIR/.fonts"
    mkdir -p "$fonts_dir"
     
    if curl -sLo Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip; then 
        unzip -oq Hack.zip -d "$fonts_dir" && rm Hack.zip
    else 
        cp "$CURRENT_DIR/../config/fonts/HackNerdFont/*" "$fonts_dir"
    fi 

    echo -e "${grayColour}[ FONTS ]$endColour$yellowColour Fonts installed and configured in$endColour$yellowColour $fonts_dir $endColour"
}


function setupAndConfigureKitty() {
    echo -e "${grayColour}[ KITTY ]$endColour$yellowColour Installing and configuring kitty GPU based terminal...$endColour"

    pacman -S kitty \
        && cp -r "$CURRENT_DIR/../config/kitty" "$target_home_config_dir"

    echo -e "${grayColour}[ KITTY ]$endColour$yellowColour Kitty GPU based terminal installed and configured on$endColour$cyanColour [ $(which kitty) ]$endColour"
}

function setupVim() {
    echo -e "${grayColour}[ VIM ]$endColour Installing and configuring VIM editor with basic initial configuration"
    local VIM_CONFIG_DIR="$CURRENT_DIR/../config/vim/"
    
    pacman -S vi vim

    if [ -f "$HOME_DIR"/.vimrc ]; then
        echo -e "${grayColour}[ VIM ]$endColour$yellowColour Detected existing .vimrc file, creating backup on$endColour$cyanColour $config_backup_folder"
        cp "$HOME_DIR"/.vimrc "$config_backup_folder"
    fi

    [[ -f "$VIM_CONFIG_DIR/.vimrc" ]] && cp "$VIM_CONFIG_DIR/.vimrc" "$HOME_DIR"

    echo -e "${grayColour}[ VIM ]$endColour$yellowColour Created$endColour$cyanColour .vimrc$endColour$yellowColour file on $HOME_DIR directory$endColour"
}

function setupZSH() {
    echo -e "${grayColour}[ ZSH ]$endColour$yellowColour Installing and configuring zsh terminal with powerlevel10k theme$endColour"
    local ZSH_CONFIG_DIR="$HOME_DIR/.config/zsh"

    if [ -f "$HOME_DIR"/.zshrc ]; then
        echo -e "${grayColour}[ ZSH ]$endColour$yellowColour Detected existing .zshrc file, creating backup on$endColour$cyanColour $config_backup_folder"
        cp "$HOME_DIR"/.zshrc "$config_backup_folder"
    fi

    pacman -S zsh

    mkdir -p "$ZSH_CONFIG_DIR/plugins"
    touch "$ZSH_CONFIG_DIR/.zsh_history"

    git clone https://github.com/zsh-users/zsh-autosuggestions.git zsh-autosuggestions
    rm -rf zsh-autosuggestions/.git && mv zsh-autosuggestions "$ZSH_CONFIG_DIR/plugins/"

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting
    rm -rf zsh-syntax-highlighting/.git && mv zsh-syntax-highlighting "$ZSH_CONFIG_DIR/plugins/"

    cp "$CURRENT_DIR/../config/zsh/plugins/colored-man-pages/*" "$ZSH_CONFIG_DIR/plugins"

    cat "$CURRENT_DIR/../config/zsh/.zshrc" >> "$ZSH_CONFIG_DIR/.zshrc" 

    source "$HOME_DIR/.zshrc"

    chsh -s "$(which zsh)" # Change default shell for the actual user
    zsh
}

function setupNVM() {
    echo -e "${grayColour}[ NVM ]$endColour$yellowColour Installing NVM (Node Version Manager) and set as default the LTS version$endColour"

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

    source "$HOME_DIR/.zshrc"

    nvm install --lts \
        && nvm use --lts
}

function setupBlackArchRepository() {
    echo -e "${grayColour}[ BLACKARCH ]$endColour Adding blackarch repository to make security packages available in the system$endColour"
    
    curl -sO https://blackarch.org/strap.sh

    if [ "$(echo "5ea40d49ecd14c2e024deecf90605426db97ea0c" strap.sh | sha1sum -c)" ]; then 
        chmod +x ./strap.sh && bash strap.sh
        pacman -Syu
        pacman -S ffuz sqlmap smbmap smbrelay sublist3r nmap dnsrecon wireshark-cli john hashcat crackmapexec set metasploit
    else 
        echo -e "${redColour}[ ERROR ]$endColour Checksum for$yellowColour strap.sh$endColour is not valid, the installation file has been altered"
    fi
}

function setupFirejail() {
    echo -e "${grayColour}[ FIREJAIL ]$endColour Installing firejail and downloading stable version of firefox$endColour"

    pacman -Sy firejail firefox
}

function setupTerminalUtils() {
    echo -e "${grayColour}[ TERMINAL UTILS ]$endColour Installing and configuring terminal utils...$endColour"
    
    pacman -S bat fzf lsd man-db man-pages bash-completion \
        && mkdir -p ~/.local/bin && ln -sf /usr/bin/batcat ~/.local/bin/bat
}

function localeGeneration() {
    echo -e "${grayColour}[ LOCALE ]$endColour Unpacking locales for ES and US to make them available in the system"
   
    local default_keymap='es'

    sed -i 's/^#es_ES/es_ES/g' /etc/locale.gen
    sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    sed -i 's/^#en_US ISO-8859-1/en_US ISO-8859-1/' /etc/locale.gen

    locale-gen 

    echo "KEYMAP=$default_keymap" > /etc/vconsole.conf

    loadkeys $default_keymap

    echo -e "${grayColour}[ LOCALE ]$endColour Finished locale generation, default keymap set as '$default_keymap'"
}

###
# START THE INSTALLATION AND CONFIGURATION PROCESS FOR THE NEW ENVIRONMENT
###
prepareEnvironmentForTheInstallation
localeGeneration
setupBlackArchRepository
setupCustomTerminalFont
setupAndConfigureKitty
setupTerminalUtils
setupVim
setupFirejail
setupZSH
setupNVM

# Copy the entire configuration to root home folder in order to have same configuration
cp -p "$HOME_DIR/.config" "$ROOT_DIR" "$HOME_DIR/.zshrc" "$ROOT_DIR" "$HOME_DIR/.fonts" "$ROOT_DIR" "$HOME_DIR/.vimrc" "$ROOT_DIR"