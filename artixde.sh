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

get_init_system() {
    case $(ps -p 1 -o comm=) in
        systemd)    echo "systemd" ;;
        init)       echo "sysvinit" ;;
        openrc-init) echo "openrc" ;;
        runit-init) echo "runit" ;;
        *)          echo "unknown" ;;
    esac
}

echo -e "${cyan}Welcome to artixde.SH. This script will install DE for your minimal Artix/Arch linux.${normal}"


echo -e "${cyan}Which DE you want to use? (number):${normal}"

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

echo -e "${cyan}Which DM you want to use? (number):${normal}"

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

#pacman -S sddm-openrc or sddm-runit or sddm-s6 or sddm-dinit

echo -e "${cyan}Installing Display Manager...${normal}"

init_system=$(get_init_system)

case $init_system in
    systemd)
        echo "Systemd is not supported! Installation aborted"
        ;;
    openrc)
        pacman -S --noconfirm $dm-openrc
        echo -e "${cyan}Registering Display Manager...${normal}"
        ln -sf /etc/sv/$dm /var/service
        ln -sf /etc/sv/$dm-openrc /var/service
        ;;
    runit)
        pacman -S --noconfirm $dm-runit
        echo -e "${cyan}Registering Display Manager...${normal}"
        ln -sf /etc/sv/$dm /var/service
        ln -sf /etc/sv/$dm-runit /var/service
        ;;
    *)
        echo "Unknown init system! Manual configuration required!"
        exit 1
        ;;
esac

echo -e "${green}Installation finished! Thanks for using the script!${normal}"
