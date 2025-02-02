#!/bin/bash

if [[ $(id -u) != 0 ]]; then
    echo "This script must be run as root!"
    exit 1
fi

install_log="$(mktemp -t install_log.XXXXXX)"
red="\033[1;31m"
green="\033[1;32m"
cyan="\033[0;36m"
normal="\033[0m"

echo -e "${cyan}Welcome to artixde.SH. This script will install DE for your minimal Artix/Arch linux.${normal}"

# Desktop Environment Selection
PS3=$'\n'"Which DE you want to use? (number): "
options=("gnome" "plasma" "cinnamon" "mate")
select de in "${options[@]}"; do
    case $de in
        "gnome"|"plasma"|"cinnamon"|"mate")
            break;;
        *) echo "Invalid option $REPLY";;
    esac
done

echo -e "${green}DE installation started! Your DE: ${de}${normal}"

# Update system
echo -e "${cyan}Updating system...${normal}"
pacman -Syyu --noconfirm

# Install packages
echo -e "${cyan}Installing packages...${normal}"
case $de in
    "plasma")
        pacman -S --noconfirm xorg xorg-server plasma plasma-wayland-session kde-applications
        ;;
    "gnome")
        pacman -S --noconfirm xorg xorg-server gnome
        ;;
    "mate")
        pacman -S --noconfirm xorg xorg-server mate mate-extra system-config-printer blueman connman-gtk
        ;;
    "cinnamon")
        pacman -S --noconfirm xorg xorg-server cinnamon connman-gtk
        ;;
esac

clear

# Display Manager Selection
PS3=$'\n'"Which DM you want to use? (number): "
dm_options=("gdm" "sddm")
select dm in "${dm_options[@]}"; do
    case $dm in
        "gdm"|"sddm")
            break;;
        *) echo "Invalid option $REPLY";;
    esac
done

echo -e "${cyan}Installing Display Manager...${normal}"
pacman -S --noconfirm $dm

echo -e "${cyan}Registering Display Manager...${normal}"
ln -sf /etc/sv/$dm /var/service

echo -e "${green}Installation finished! Thanks for using the script!${normal}"
