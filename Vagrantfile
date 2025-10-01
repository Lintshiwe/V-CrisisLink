# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Use a minimal Debian box (smaller footprint)
  config.vm.box = "debian/bullseye64"
  config.vm.hostname = "crisislink"
  
  # Increase boot timeout to 600 seconds (10 minutes)
  config.vm.boot_timeout = 600
  
  # Configure VM resources and stability settings
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048" # 2GB RAM
    vb.cpus = 2
    vb.name = "crisislink_vm"
    # Disable GUI as it's not needed for headless operation
    vb.gui = false
    
    # Disable features that might cause issues
    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    vb.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
    vb.customize ["modifyvm", :id, "--usb", "off"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
  end

  # Port forwarding to access the applications
  config.vm.network "forwarded_port", guest: 3000, host: 3000 # Frontend
  config.vm.network "forwarded_port", guest: 5000, host: 5000 # Backend API

  # Enable synced folder to access the provision script
  config.vm.synced_folder ".", "/vagrant"

  # First stage provisioning - basic requirements
  config.vm.provision "shell", inline: <<-SHELL
    echo "🚨 Installing basic requirements..."
    apt-get update
    apt-get install -y git curl
    echo "✅ Basic setup complete. Starting main provisioning..."
  SHELL
  
  # Second stage provisioning - run the full provision script
  config.vm.provision "shell", inline: <<-SHELL
    echo "� Running the main provisioning script..."
    sudo bash /vagrant/provision.sh
    echo "✅ Provisioning completed!"
  SHELL
  
  # Message displayed after vagrant up
  config.vm.post_up_message = "
    🎉 CrisisLink VM setup is complete!
    
    Your application is now running and available at:
      • Frontend: http://localhost:3000
      • Backend API: http://localhost:5000
    
    To access the VM:   vagrant ssh
    To stop the VM:     vagrant halt
    To suspend VM:      vagrant suspend
    To destroy the VM:  vagrant destroy
  "
end