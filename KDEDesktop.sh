#!/bin/bash

# This updates your system
pacman -Syyu

# This installs the following packages
sudo pacman -S xorg plasma plasma-wayland-session kde-applications

# This enables Simple Desktop Display Manager
systemctl enable sddm

# This enables the Network Manager
systemctl enable NetworkManager