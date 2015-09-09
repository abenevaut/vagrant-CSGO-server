# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below.
Vagrant.configure(2) do |config|

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "vagrant-debian78-64"

  # Box URL
  config.vm.box_url = "http://pub.cvepdb.fr/vagrant/boxes/vagrant-debian78-64/package.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.

  # Accessing "localhost:27915" will access port 27015 on the guest machine.
  config.vm.network "forwarded_port", guest: 27015, host: 27015
  config.vm.network "forwarded_port", guest: 1200, host: 1200
  config.vm.network "forwarded_port", guest: 27000, host: 27000
  config.vm.network "forwarded_port", guest: 27039, host: 27039
  config.vm.network "forwarded_port", guest: 27020, host: 27020
  config.vm.network "forwarded_port", guest: 80, host: 8088

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./www", "/home/vagrant/www"
  config.vm.synced_folder "./csgo", "/home/vagrant/serverfiles/csgo"

  # Provision script
  config.vm.provision "shell", path: "shell.sh", privileged: false

end
