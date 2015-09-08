#!/bin/bash

# Variables
DBHOST=localhost
DBNAME=rokket
DBUSER=root
DBPASSWD=vagrant

echo "Processing server installation"

sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null

# i386 packages
sudo dpkg --add-architecture i386 > /dev/null
sudo apt-get update -y -qq > /dev/null
sudo apt-get install libc6-i386 lib32gcc1 -y -qq > /dev/null

# i386 packages
sudo dpkg --add-architecture i386 > /dev/null
sudo apt-get update -y -qq > /dev/null
sudo aptitude install ia32-libs -y -q=9 > /dev/null

sudo apt-get install gdb tmux expect apache2 php5-common libapache2-mod-php5 php5-cli git -y -qq > /dev/null

# PHPmyadmin
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get -y install mysql-server-5.5 phpmyadmin > /dev/null 2>&1

# Force dependencies
sudo apt-get install -f -y -qq

/*
 * Database config
 */

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

/*
 * Webinterface
 */
 
sudo rm -rf /var/www
cd /home/vagrant
mkdir www
sudo ln -s /home/vagrant/www /var/www
cd /home/vagrant/www
git clone https://github.com/aaroniker/rokket.git
mv rokket/* . && mv rokket/.* . && rmdir rokket

/*
 * Game server
 */

echo "Install CS:GO server"

cd /home/vagrant

wget https://raw.github.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
chmod +x csgoserver

wget https://raw.githubusercontent.com/42antoine/vagrant-CSGO-server/dev/dist/installer.sh
chmod +x installer.sh

/*
 * IPTables
 */

 
/home/vagrant/csgoserver auto-install

