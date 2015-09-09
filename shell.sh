#!/bin/bash

# Variables
DBHOST=localhost
DBNAME=rokket
DBUSER=root
DBPASSWD=vagrant

echo -e "\n--- Processing server installation ---\n"

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
#echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
#echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | sudo debconf-set-selections
#echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | sudo debconf-set-selections
#echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | sudo debconf-set-selections
#echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | sudo debconf-set-selections
#sudo apt-get -y install phpmyadmin > /dev/null 2>&1

# Force dependencies
sudo apt-get install -f -y -qq

/*
 * Database config
 */

echo -e "\n--- Setting up our MySQL user and db ---\n"
#mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
#mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost';"
#mysql -uroot -p$DBPASSWD -e "FLUSH PRIVILEGES;"

/*
 * IPTables
 */

echo -e "\n--- IP Tables ---\n"

echo "*filter

-P INPUT DROP
-P FORWARD ACCEPT
-P OUTPUT ACCEPT

-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -p igmp -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp --dport ssh -j ACCEPT
-A INPUT -p tcp --dport http -j ACCEPT
-A INPUT -p tcp --dport https -j ACCEPT

#
# Steam Rules -----
# https://forums.alliedmods.net/showthread.php?t=163467
#

-A INPUT -p udp --dport 1200 --jump ACCEPT
-A INPUT -p udp --dport 27000 --jump ACCEPT
-A INPUT -p tcp --dport 27020 --jump ACCEPT
-A INPUT -p tcp --dport 27039 --jump ACCEPT
-A INPUT -p udp --dport 27020 --jump ACCEPT
-A INPUT -p udp -d 127.0.0.1 --dport 27015
-A INPUT -p tcp -d 127.0.0.1 --dport 27015 --jump ACCEPT

#
# !Steam Rules -----
#

-A INPUT -j LOG --log-prefix 'paquet IPv4 inattendu'
-A INPUT -j REJECT

COMMIT

*nat
COMMIT

*mangle
COMMIT" > /home/vagrant/iptables.up.rules

sudo cp /home/vagrant/iptables.up.rules /etc/iptables.up.rules
sudo iptables-restore < /etc/iptables.up.rules

/*
 * Webinterface
 */

sudo rm -rf /var/www
cd /home/vagrant
sudo ln -s /home/vagrant/www /var/www
cd /home/vagrant/www
git clone https://github.com/aaroniker/rokket.git rokket
mv rokket/* . && mv rokket/.* . && rmdir rokket

/*
 * Game server
 */

echo -e "\n--- Install CS:GO server ---\n"

cd /home/vagrant

wget https://raw.github.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
chmod +x csgoserver

/home/vagrant/csgoserver auto-install

