#!/bin/bash

echo "Processing server installation"
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null
sudo dpkg --add-architecture i386 > /dev/null
sudo apt-get install gdb tmux expect -y -qq > /dev/null
sudo apt-get install -f -y -qq

echo "Install CS:GO server"
cd /home/vagrant
wget https://raw.github.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
chmod +x csgoserver
wget https://raw.githubusercontent.com/42antoine/vagrant-CSGO-server/dev/dist/installer.sh
chmod +x installer.sh
./installer.sh
