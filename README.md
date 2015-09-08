# vagrant-CSGO-server
Vagrant deployement for CSGO server

/!\ Project in development

# Install vagrant

Go to https://www.vagrantup.com/downloads.html and download / install vagrant for your system.

## Install Virtualbox

Vagrant works with a vm manager, by default you can work with virtualbox.

Go to  https://www.virtualbox.org/wiki/Downloads and download / install vagrant for your system.

# Deploy your server CS:GO

clone this repository :

	$> git clone https://github.com/42antoine/vagrant-CSGO-server.git
	$> cd vagrant-CSGO-server
	$> vagrant up

## Services

	Your server is now running on.

### MySQL

	- username : root
	- password : vagrant
	
### Apache2, PHP

	On the vagrant vm, a web server is installed. You can access it via 127.0.0.1:8088
	The "Rokket" game server manager is installed as default website. You have to configure it to use it (Note : automated installation is in progress).
	You can also use phpmyadmin at this address 127.0.0.1:8088/phpmyadmin

### CS:Go game server

	Use the ./csgoserver script to start / update / stop your server.
	
	To connect to your game server, use 127.0.0.1:27915 as server IP.

	- rcon password : rconpassword
	
## VM file sharing
	
	On project root directory, you can see "www" and "csgo" directories. These folders are shared from VM, use it to share game server configuration or website with the VM.

	
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/42antoine/vagrant-csgo-server/trend.png)](https://bitdeli.com/free "Bitdeli Badge")