# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below.
Vagrant.configure(2) do |config|

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "debian/jessie64"

  config.vm.provider "virtualbox" do |vb|
      file_to_disk = File.realpath( "." ).to_s + "/disk.vdi"

      if ARGV[0] == "up" && ! File.exist?(file_to_disk)
         puts "Creating 15GB disk #{file_to_disk}."
         vb.customize [
              'createhd',
              '--filename', file_to_disk,
              '--format', 'VDI',
              '--size', 15 * 1024 # 15 GB
              ]
         vb.customize [
              'storageattach', :id,
              '--storagectl', 'SATA Controller',
              '--port', 1, '--device', 0,
              '--type', 'hdd', '--medium',
              file_to_disk
              ]
      end
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  config.vm.network "forwarded_port", guest: 80, host: 8088

  # Private network
  config.vm.network :private_network, ip: "192.168.56.101"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./www", "/home/vagrant/www"
  config.vm.synced_folder "./csgo", "/home/vagrant/serverfiles/csgo"

  # Provision script
  config.vm.provision "shell", path: "shell.sh", privileged: false

end
