#!/bin/bash
 
echo "Processing server installation"

sudo apt-get update -qq > /dev/null
sudo apt-get upgrade -qq > /dev/null
sudo dpkg --add-architecture i386 > /dev/null
sudo apt-get install gdb mailutils postfix tmux ca-certificates lib32gcc1 ia32-libs > /dev/null


echo "Install CS:GO server"

cd /home/vagrant
wget https://raw.github.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
chmod +x csgoserver
# ./csgoserver install