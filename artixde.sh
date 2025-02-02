#!/bin/bash

if ! [[ $(id -u) = 0 ]]; then
    echo "This script must be run as root!"
    exit 1
fi

export install_log="$(mktemp -t install_logXXX)"
export red="\033[1;31m"
export green="\033[1;32m"
export cyan="\033[0;36m"
export normal="\033[0m"

# This updates your system
pacman -Syyu

# This installs the following packages
sudo pacman -S xorg plasma plasma-wayland-session kde-applications

# This enables Simple Desktop Display Manager
systemctl enable sddm

# This enables the Network Manager
systemctl enable NetworkManager
