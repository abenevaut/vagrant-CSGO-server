#!/bin/bash

# Variables
DBHOST=localhost
DBNAME=rokket
DBUSER=root
DBPASSWD=vagrant

echo -e "\n--- Processing server installation ---\n"

echo -e "\n--- Linux update ---\n"
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null

echo -e "\n--- libc6-i386 & lib32gcc1 - i386 packages ---\n"
sudo dpkg --add-architecture i386 > /dev/null
sudo apt-get update -y -qq > /dev/null
sudo apt-get install libc6-i386 lib32gcc1 -y -qq > /dev/null

echo -e "\n--- ia32-libs - i386 packages ---\n"
sudo dpkg --add-architecture i386 > /dev/null
sudo apt-get update -y -qq > /dev/null
sudo aptitude install ia32-libs -y -q=9 > /dev/null

echo -e "\n--- Binaries (gdb, tmux, git ...) ---\n"
sudo apt-get install gdb tmux git -y -qq > /dev/null

echo -e "\n--- MySQL ---\n"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password $DBPASSWD'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $DBPASSWD'
sudo apt-get install mysql-server -y -qq > /dev/null

echo -e "\n--- Apache2 & PHP5 ---\n"
sudo apt-get install apache2 php5-common libapache2-mod-php5 php5-cli php5-mysql -y -qq > /dev/null

echo -e "\n--- Force dependencies ---\n"
sudo apt-get install -f -y -qq

echo -e "\n--- PHPMyAdmin ---\n"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get install phpmyadmin -y -qq > /dev/null

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost';"
mysql -uroot -p$DBPASSWD -e "FLUSH PRIVILEGES;"

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

-A INPUT -j LOG --log-prefix \"paquet IPv4 inattendu\"
-A INPUT -j REJECT

COMMIT

*nat
COMMIT

*mangle
COMMIT" > /home/vagrant/iptables.up.rules
sudo cp /home/vagrant/iptables.up.rules /etc/iptables.up.rules
sudo iptables-restore < /etc/iptables.up.rules

echo -e "\n--- Game server Webinterface ---\n"
sudo rm -rf /var/www
cd /home/vagrant
sudo ln -s /home/vagrant/www /var/www
cd /home/vagrant/www
git clone https://github.com/aaroniker/rokket.git rokket
mv rokket/* . && mv rokket/.* . && rmdir rokket

echo -e "\n--- Install CS:GO server ---\n"
cd /home/vagrant
wget https://raw.github.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
chmod +x csgoserver
/home/vagrant/csgoserver auto-install
