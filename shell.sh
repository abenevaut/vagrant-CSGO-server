#!/bin/bash

# DEBUG - Travis-ci
TRAVIS=$1

if [[ -z "${TRAVIS}" ]]; then
  mkdir ~/www
  mkdir -p ~/serverfiles/csgo
fi

# Variables
DBHOST=localhost
DBNAME=rokket
DBUSER=root
DBPASSWD=vagrant

echo -e "\n--- Processing server installation ---\n"

echo -e "\n--- Linux update ---\n"
sudo apt-get update -y
sudo apt-get upgrade -y

echo -e "\n--- libc6-i386 & lib32gcc1 - i386 packages ---\n"
sudo dpkg --add-architecture i386
sudo apt-get update -y
sudo apt-get install libc6-i386 lib32gcc1 -y

echo -e "\n--- ia32-libs - i386 packages ---\n"
sudo dpkg --add-architecture i386
sudo apt-get update -y
sudo aptitude install ia32-libs -y

echo -e "\n--- Binaries (gdb, tmux, git ...) ---\n"
sudo apt-get install gdb tmux git -y

echo -e "\n--- MySQL ---\n"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
sudo apt-get install mysql-server -y

echo -e "\n--- Apache2 & PHP5 ---\n"
sudo apt-get install apache2-mpm-prefork apache2 php5-common libapache2-mod-php5 php5-cli php5-mysql -y

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'127.0.0.1';"
mysql -uroot -p$DBPASSWD -e "FLUSH PRIVILEGES;"

echo -e "\n--- Restart web services ---\n"

sudo service apache2 restart
sudo service mysql restart

echo -e "\n--- PHPMyAdmin ---\n"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get install phpmyadmin -y

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

echo -e "\n--- Game server Webinterface ---\n"
sudo rm -rf /var/www
cd /home/vagrant
sudo ln -s /home/vagrant/www /var/www
cd /home/vagrant/www
git clone https://github.com/aaroniker/rokket.git rokket
mv rokket/* . && mv rokket/.* . && rmdir rokket

echo "<?php phpinfo(); ?>" > /home/vagrant/www/info.php

echo "{
    \"name\": \"Rokket Panel\",
    \"url\": \"http:\/\/\",
    \"version\": \"0.4\",
    \"setup\": false,
    \"debug\": false,
    \"cache\": false,
    \"logs\": 1,
    \"emailNot\": null,
    \"email\": \"\",
    \"ip\": \"\",
    \"DB\": {
        \"host\": \"\",
        \"user\": \"root\",
        \"password\": \"vagrant\",
        \"database\": \"rokket\",
        \"prefix\": \"\"
    },
    \"SSH\": {
        \"ip\": \"127.0.0.1:22\",
        \"user\": \"root\",
        \"password\": \"vagrant\"
    },
    \"timezone\": \"Europe\/Berlin\",
    \"logincookie\": 86400,
    \"lang\": \"en_gb\",
    \"layout\": \"default\",
    \"user\": []
}
" > /home/vagrant/www/lib/config.json

mysql -uroot -p$DBPASSWD -e "CREATE TABLE IF NOT EXISTS $DBNAME.addons ( id  int(11) unsigned NOT NULL, name  varchar(255) NOT NULL, active  int(1) NOT NULL, install  int(1) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
mysql -uroot -p$DBPASSWD -e "CREATE TABLE IF NOT EXISTS $DBNAME.server ( id  int(11) NOT NULL, gameID  varchar(255) NOT NULL, name  varchar(255) NOT NULL, port  int(5) NOT NULL, status  varchar(255) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
mysql -uroot -p$DBPASSWD -e "CREATE TABLE IF NOT EXISTS $DBNAME.user ( id  int(11) NOT NULL, firstname  varchar(255) NOT NULL, name  varchar(255) NOT NULL, username  varchar(255) NOT NULL, email  varchar(255) NOT NULL, password  varchar(255) NOT NULL, salt  varchar(255) NOT NULL, admin  int(11) NOT NULL, perms  varchar(255) NOT NULL) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"
mysql -uroot -p$DBPASSWD -e "ALTER TABLE $DBNAME.addons ADD PRIMARY KEY ( id );"
mysql -uroot -p$DBPASSWD -e "ALTER TABLE $DBNAME.server ADD PRIMARY KEY ( id );"
mysql -uroot -p$DBPASSWD -e "ALTER TABLE $DBNAME.user ADD PRIMARY KEY ( id );"
mysql -uroot -p$DBPASSWD -e "ALTER TABLE $DBNAME.addons MODIFY  id  int(11) NOT NULL AUTO_INCREMENT;"
mysql -uroot -p$DBPASSWD -e "ALTER TABLE $DBNAME.server MODIFY  id  int(11) NOT NULL AUTO_INCREMENT;"
mysql -uroot -p$DBPASSWD -e "ALTER TABLE $DBNAME.user MODIFY  id  int(11) NOT NULL AUTO_INCREMENT;"
mysql -uroot -p$DBPASSWD -e "INSERT INTO $DBNAME.user (firstname,name,username,email,password,salt,admin,perms) VALUES('cvepdb','vagrant','42_vagrant','contact@cvepdb.fr',sha2('rootvagrantroot', 256),'root',1,'');"

echo -e "\n--- Install CS:GO server ---\n"
cd /home/vagrant
wget https://raw.github.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
sed -i 's/"0.0.0.0"/"192.168.56.101"/' /home/vagrant/csgoserver
chmod +x csgoserver
sudo chown vagrant:vagrant -R /home/vagrant/serverfiles
/home/vagrant/csgoserver auto-install
