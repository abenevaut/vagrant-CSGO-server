#!/bin/bash


# DEBUG - Travis-ci
TRAVIS=$1


# Variables
DBHOST=localhost
DBNAME=vagrant
DBUSER=root
DBPASSWD=vagrant


if [[ -z "${TRAVIS}" ]]; then

  echo -e "\n--- Processing server installation ---\n"

  APTGET="sudo apt-get -y -q=9"

  echo -e "\n--- Linux update ---\n"

else

  echo -e "\n--- Processing travis installation ---\n"

  export DEBIAN_FRONTEND=noninteractive

  mkdir ~/www
  mkdir -p ~/serverfiles/csgo

  APTGET="sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confnew\""

  echo -e "\n--- Travis linux update ---\n"

fi

eval $APTGET update
eval $APTGET upgrade

echo -e "\n--- libc6-i386 & lib32gcc1 - i386 packages ---\n"
sudo dpkg --add-architecture i386
eval $APTGET update
eval $APTGET install libc6-i386 lib32gcc1

echo -e "\n--- ia32-libs - i386 packages ---\n"
sudo dpkg --add-architecture i386
eval $APTGET update
sudo aptitude -y -q install ia32-libs

echo -e "\n--- Binaries (gdb, tmux, git ...) ---\n"
eval $APTGET install gdb tmux git

echo -e "\n--- MySQL ---\n"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
eval $APTGET install mysql-server

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'127.0.0.1';"
mysql -uroot -p$DBPASSWD -e "FLUSH PRIVILEGES;"

echo -e "\n--- Apache2 & PHP5 ---\n"
eval $APTGET install apache2-mpm-prefork apache2 php5-common libapache2-mod-php5 php5-cli php5-mysql

echo -e "\n--- Restart web services ---\n"

sudo service apache2 restart
sudo service mysql restart

echo -e "\n--- PHPMyAdmin ---\n"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
eval $APTGET install phpmyadmin

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

# /!\ WARNING
# /!\ WARNING - NEVER USE THIS RULE ON PRODUCTION SERVER
# /!\ WARNING - (Note change it with : -A INPUT -j REJECT)
# /!\ WARNING
-I INPUT -j ACCEPT

COMMIT

*nat
COMMIT

*mangle
COMMIT" > /home/vagrant/iptables.up.rules
sudo cp /home/vagrant/iptables.up.rules /etc/iptables.up.rules
sudo iptables-restore < /etc/iptables.up.rules

echo -e "\n--- Web server configuration ---\n"
sudo rm -rf /var/www
cd /home/vagrant
sudo ln -s /home/vagrant/www /var/www
cd /home/vagrant/www

echo "<?php phpinfo(); ?>" > /home/vagrant/www/info.php

echo -e "\n--- Install CS:GO server ---\n"
cd /home/vagrant
wget https://raw.github.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
sed -i 's/"0.0.0.0"/"192.168.56.101"/' /home/vagrant/csgoserver
chmod +x csgoserver
sudo chown vagrant:vagrant -R /home/vagrant/serverfiles
/home/vagrant/csgoserver auto-install
