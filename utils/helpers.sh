#!/usr/bin/env bash

function whichPackageManager() {
    local package_manager=''

    # Ubuntu, Debian and Linux mint
    if [ -n "$(command -v apt-get)" ] || [ -n "$(command -v apt)" ]; then
	package_manager="sudo apt" 
    
    # CentOS, RHEL and Fedora
    elif [ -n "$(command -v yum)" ]; then
	package_manager="sudo yum"
    elif [ -n "$(command -v dnf)" ]; then
	package_manager="sudo dnf"
   
   # Arch Linux and Manjaro Systems
    elif [ -n "$(command -v pacman)" ]; then
	package_manager="sudo pacman -S"
    # OpenSuse systems
    elif [ -n "$(command -v zypper)" ]; then
	package_manager="sudo zypper"
    else 
      echo -e "None of the following package managers are found (apt,yum,dnf,pacman or zypper)"
      echo -e ""
      exit 1;
    fi

    echo "$package_manager"
}

function backupTargetConfigurationFolder() {
    if [ -d "$target_home_config_dir" ]; then
        echo -e "${greenColour}Detected existing .config folder${endColour}, ${yellowColour}creating backup on${endColour} ${cyanColour}$target_home_config_dir/backup/.${USER}_config${endColour}"
        
        local -r config_backup_folder=$target_home_config_dir/backup/
        mkdir -p "$config_backup_folder" && cp -r "$target_home_config_dir" "$config_backup_folder" && mv "$config_backup_folder"/.config "$config_backup_folder/.${USER}_config"
    fi
}

export -f whichPackageManager