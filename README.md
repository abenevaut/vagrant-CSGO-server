# vagrant-CSGO-server
Vagrant deployement for CSGO game server. Use this tool to easily start new addons development or for fun!

###### /!\ Project for developers - never use this project to make online game server!

master [![Build Status](https://travis-ci.org/42antoine/vagrant-CSGO-server.svg?branch=master)](https://travis-ci.org/42antoine/vagrant-CSGO-server) | dev [![Build Status](https://travis-ci.org/42antoine/vagrant-CSGO-server.svg?branch=dev)](https://travis-ci.org/42antoine/vagrant-CSGO-server)

# Install vagrant

Go to https://www.vagrantup.com/downloads.html and download / install vagrant for your system.

## Install Virtualbox

Vagrant works with a vm manager, by default you can work with virtualbox.

Go to  https://www.virtualbox.org/wiki/Downloads and download / install vagrant for your system.

# Deploy your server CS:GO

Clone this repository :

	$> git clone https://github.com/42antoine/vagrant-CSGO-server.git
	$> cd vagrant-CSGO-server
	$> vagrant up
	$> vagrant ssh
	$> ./csgoserver start

Stop the game server

	$> ./csgoserver stop

Update the game server

	$> ./csgoserver update

The "debug" mode functionality - for moders, run server instance to debug transaction

	$> ./csgoserver debug

## Services

Your server is now running on !

### MySQL

	- username : root
	- password : vagrant
	
### Apache2, PHP

On the vagrant vm, a web server is installed. You can access it via 127.0.0.1:8088
The "Rokket" game server manager is installed as default website (https://github.com/aaroniker/rokket).
You can also use phpmyadmin at this address 127.0.0.1:8088/phpmyadmin

All website content is available from you computer in : vagrant-CSGO-server/www *(1)

### CS:Go game server

Use the ./csgoserver script to start / update / stop / debug your server.
All the action list is accessed like this (inside the vm) :
	
	$> ./csgoserver
	@seealso https://github.com/dgibbs64/linuxgsm/wiki/Usage
	
To connect to your game server, use 192.168.56.101:27015 as server IP.
This IP is forced in the VM configuration file.

	- rcon password : rconpassword

All csgo server content is available from you computer in : vagrant-CSGO-server/csgo *(1)
	
## VM file sharing
	
*(1) : On project root directory, you can see "www" and "csgo" directories. These folders are shared from VM, use it to share game server configuration or website with the VM.

## See also

https://github.com/dgibbs64/linuxgsm/wiki/Usage

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/42antoine/vagrant-csgo-server/trend.png)](https://bitdeli.com/free "Bitdeli Badge")