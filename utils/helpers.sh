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
      echo -e "None of the following package managers are found (apt,yum,dnf,pacman or zypper)\n"
      exit 1;
    fi

    echo "$package_manager"
}


export -f whichPackageManager