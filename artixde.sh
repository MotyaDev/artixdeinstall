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
    # Get init
    init_process=$(ps -p 1 -o comm=)
    if grep -q 'systemd' <<< "$init_process"; then
        echo "systemd"
    elif grep -q 'openrc-init' <<< "$init_process"; then
        echo "openrc"
    elif grep -q 'runit-init' <<< "$init_process"; then
        echo "runit"
    else
        # ????
        if [ -d /etc/sv ]; then
            echo "runit"
        elif [ -f /etc/inittab ]; then
            echo "sysvinit"
        else
            echo "unknown"
        fi
    fi
}

echo -e "${cyan}Welcome to artixde.SH. This script will install DE for your minimal Artix/Arch linux.${normal}"

# DE select
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

# system update
echo -e "${cyan}Updating system...${normal}"
pacman -Syyu --noconfirm

# installing packages
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

# DM select
echo -e "${cyan}Which DM you want to use? (number):${normal}"
PS3=$'\n'"Select Display Manager: "
dm_options=("gdm" "sddm")
select dm in "${dm_options[@]}"; do
    case $dm in
        "gdm"|"sddm")
            break;;
        *) echo "Invalid option $REPLY";;
    esac
done

# Get init system
init_system=$(get_init_system)
echo -e "${cyan}Detected init system: ${init_system}${normal}"

# Installing dm and configuring
echo -e "${cyan}Installing Display Manager...${normal}"
case $init_system in
    systemd)
        pacman -S --noconfirm $dm
        systemctl enable $dm.service
        ;;
    openrc)
        pacman -S --noconfirm $dm-openrc
        rc-update add $dm-openrc default
        ;;
    runit)
        pacman -S --noconfirm $dm-runit
        ln -sv /runit/sv/$dm-runit /run/runit/service/
        ;;
    *)
        echo "Unknown init system! Trying default runit..."
        pacman -S --noconfirm $dm-runit
        ln -sv /runit/sv/$dm-runit /run/runit/service/
        ;;
esac

echo -e "${green}Installation finished! Thanks for using the script!${normal}"
