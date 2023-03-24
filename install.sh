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

package_manager="sudo pacman"

# Common folders to work
target_home_config_dir="$HOME/.config"
config_backup_folder=$target_home_config_dir/backup/${USER}.config

echo -e "${yellowColour}The package manager for the entire installation will be${endColour} ${cyanColour}$package_manager${endColour}"

function backupTargetConfigurationFolder() {
    if [ -d "$target_home_config_dir" ]; then
        echo -e "${greenColour}Detected existing .config folder${endColour}, ${yellowColour}creating backup on${endColour} ${cyanColour}$config_backup_folder"

        mkdir -p "$config_backup_folder" && cp -r "$target_home_config_dir" "$config_backup_folder"
    fi
}

function setupCustomTerminalFont() {
    echo -e "${grayColour}Downloading HackNerdFont from${endColour} ${blueColour}https://github.com/ryanoasis/nerd-fonts${endColour}"

    local fonts_dir="$HOME/.fonts"
    mkdir -p "$fonts_dir"
     
    if curl -sLo Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip; then 
        unzip -oq Hack.zip -d "$fonts_dir" && rm Hack.zip
    else 
        cp "$CURRENT_DIR/config/fonts/HackNerdFont/*" "$fonts_dir"
    fi 

    echo -e "${greenColour} Fonts installed and configured in${endColour} ${cyanColour}[ $fonts_dir ]${endColour}"
}


function setupAndConfigureKitty() {
    echo -e "${grayColour}Installing and configuring kitty GPU based terminal...${endColour}"

    "$package_manager" -S kitty \
        && cp -r "$CURRENT_DIR/config/kitty" "$target_home_config_dir"

    echo -e "${greenColour} Kitty GPU based terminal installed and configured on${endColour} ${cyanColour}[ $(which kitty) ]${endColour}"
}

function setupVim() {
    local VIM_CONFIG_DIR="$CURRENT_DIR/config/vim/"
    
    "$package_manager" -S vi vim

    [[ -f "$VIM_CONFIG_DIR/.vimrc" ]] && cp "$VIM_CONFIG_DIR/.vimrc" "$HOME"
}

function setupZSH() {
    echo -e "${grayColour} Installing and configuring zsh terminal with powerlevel10k theme${endColour}"
    local ZSH_CONFIG_DIR="$HOME/.config/zsh"

    if [ -f "$HOME"/.zshrc ]; then
        echo -e "${greenColour}Detected existing .zshrc file${endColour}, ${yellowColour}creating backup on${endColour} ${cyanColour}$config_backup_folder"
        cp "$HOME"/.zshrc "$config_backup_folder"
    fi

    "$package_manager" -S base-devel git zsh

    mkdir -p "$ZSH_CONFIG_DIR/plugins"
    touch "$ZSH_CONFIG_DIR/.zsh_history"

    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CONFIG_DIR/plugins"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  "$ZSH_CONFIG_DIR/plugins"
    cp "$CURRENT_DIR/config/zsh/plugins/colored-man-pages/*" "$ZSH_CONFIG_DIR/plugins"

    chsh -s "$(which zsh)" # Change default shell for the actual user
    zsh
}

function setupNVM() {
    echo -e "$greenColour Installing NVM (Node Version Manager) and set default LTS version$endColour"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    nvm install --lts && nvm use --lts
}

function setupBlackArchRepository() {
    echo -e "$greenColour Adding blackarch repository to make security packages available in the system$endColour"
    curl -o- https://blackarch.org/strap.sh | bash

    "$package_manager" -Syu
}

function setupFirejail() {
    echo -e "$greenColour Installing firejail and downloading stable version of firefox$endColour"
    "$package_manager"-Sy firejail 

    # We installed yay to get access firefox binaries
    git clone https://aur.archlinux.org/yay-git.git

    cd yay-git && makepkg -sri

    # firefox: Stable regular build
    # firefox-beta: Stable pre-release build
    # firefox-nightly: Unstable and testing build
    $ yay -S firefox
}

function setupTerminalUtils() {
    echo -e "$greenColour Installing and configuring terminal utils (bat, lsd ,fzf)...$endColour"
    # batcat, lsd, fzf
    $package_manager -S bat fzf lsd \
        && mkdir -p ~/.local/bin && ln -sf /usr/bin/batcat ~/.local/bin/bat
}

###
# START THE INSTALLATION AND CONFIGURATION PROCESS FOR THE NEW ENVIRONMENT
###
backupTargetConfigurationFolder
setupBlackArchRepository
setupCustomTerminalFont
setupAndConfigureKitty
setupTerminalUtils
setupVim
setupFirejail
setupNVM
setupZSH
