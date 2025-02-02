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

echo -ne "${cyan}Welcome to artixde.SH. This script will install DE for your minimal Artix/Arch linux."

echo -e "\nWhich DE system do you want to use?"
    options=("gnome" "plasma" "cinnamon" "mate")
    select_option $? 1 "${options[@]}"
    case $? in
    0) export de="gnome"
        export zaglyshka=("zaglyshka" "zaglyshka-zaglyshka");;
    1) export de="plasma"
        export init_programs=("zaglyshka" "zaglyshka-zaglyshka");;
    2) export de="cinnamon"
        export init_programs=("zaglyshka" "zaglyshka-zaglyshka");;
    3) export de="mate"
        export init_programs=("zaglyshka-zaglyshka" "zaglyshka-zaglyshka");;
    esac

echo -e "${normal} DE installation started! Your DE: ${de}"

echo -e "${cyan} Updating system..."
pacman -Syyu --noconfirm

echo -e "${cyan} Installing packages..."

if [[ "${de}" == "plasma" ]]; then
        sudo pacman -S xorg xorg-server plasma plasma-wayland-session kde-applications --noconfirm
elif [[ "${de}" == "gnome" ]]; then
        pacman -S xorg xorg-server --noconfirm
        pacman -S gnome --noconfirm
fi
elif [[ "${de}" == "mate" ]]; then
        pacman -S xorg xorg-server --noconfirm
        pacman -S mate mate-extra system-config-printer blueman connman-gtk --noconfirm
fi
elif [[ "${de}" == "cinnamon" ]]; then
        pacman -S xorg xorg-server --noconfirm
        pacman -S cinnamon connman-gtk --noconfirm
fi

echo -e "\nWhich display manager do you want to use?"
    options=("gdm" "sddm")
    select_option $? 1 "${options[@]}"
    case $? in
    0) export de="gdm"
        export zaglyshka=("zaglyshka" "zaglyshka-zaglyshka");;
    1) export de="sddm"
        export init_programs=("zaglyshka" "zaglyshka-zaglyshka");;
    esac

echo -e "${cyan} Registering and installing DM"

if [[ "${de}" == "gdm" ]]; then
        pacman -S gdm --noconfirm
elif [[ "${de}" == "sddm" ]]; then
        pacman -S sddm -noconfirm
fi


echo -e "${cyan} Registering DM"

if [[ "${de}" == "gdm" ]]; then
        sudo ln -s /etc/sv/gdm /var/service
elif [[ "${de}" == "sddm" ]]; then
        sudo ln -s /etc/sv/sddm /var/service
fi

echo -e "${cyan} Installation finished! Thanks for installing!"

#sudo ln -s /etc/sv/sddm /var/service

# This updates your system
#pacman -Syyu

# This installs the following packages
#sudo pacman -S xorg plasma plasma-wayland-session kde-applications

# This enables Simple Desktop Display Manager
#systemctl enable sddm

# This enables the Network Manager
#systemctl enable NetworkManager
