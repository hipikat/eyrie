#
# This Vagrantfile tells Vagrant how to tell Virtualbox how to build boxes.
# You can find the definitions for the boxes in config/vagrants.yaml
#
# Boxes are seeded with Salt, and have states and settings applied, and packages
# installed, according to the definitions in the vagrants.yaml file.
#

# Load config for the set of machines defined in config/vagrants.yaml
require 'yaml'
vagrants = YAML.load_file('config/vagrants.yaml', aliases: true)

Vagrant.configure("2") do |vagrant_config|

  # Creates a Vagrant machine definition
  def setup_base_vm(vm, name, vm_config)

    # Configure vm from config
    project_root = vm_config.key?('project_root') ? vm_config['project_root'] : '/vagrant'
    vm.vm.synced_folder "./", project_root
    vm.vm.box = vm_config['box']
    vm.vm.hostname = "#{name}"
    # vm.vm.network "public_network"
    vm.vm.network "private_network", ip: vm_config['private_ip'], virtualbox__intnet: 'intnet'
    vm_config['forwarded_ports'].each do |guest_port, host_port|
      vm.vm.network "forwarded_port", guest: guest_port, host: host_port
    end
    vm.vm.provider "virtualbox" do |vb|
      vb.name = "#{name}-#{Time.now.strftime("%Y-%m-%d-%H%M")}"
      vb.memory = vm_config['memory']
      vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
      vb.customize ["modifyvm", :id, "--accelerate2dvideo", "off"]

      # Apply additional VirtualBox settings
      if vm_config.has_key?("virtualbox")
        vm_config["virtualbox"].each do |vbox_setting, value|
          vb.public_send("#{vbox_setting}=", value)
        end
      end
    end

    # Synchronise Salt states and pillars
    vm.vm.synced_folder "./config/salt/states", "/srv/salt"
    vm.vm.synced_folder "./config/salt/pillars", "/srv/pillar"

    # Sync folders listed in the vm config
    if vm_config.key?('folder_mappings')
      vm_config['folder_mappings'].each do |host_folder, vm_folder|
        vm.vm.synced_folder host_folder, vm_folder
      end
    end

    vm.vm.provision "shell", inline: <<-SHELL

      # Link local executables into the guest's PATH
      for file in #{project_root}/scripts/vagrant/*; do
        [ -x "$file" ] && sudo ln -sf "$file" "/usr/local/bin/$(basename "$file")"
      done

      # Set up a swap file if one doesn't already exist
      if [ ! -f /swapfile ]; then
        echo "Creating #{vm_config['swap']} swapfile..."
        sudo fallocate -l #{vm_config['swap']} /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /config/fstab  # Ensure swap is re-enabled on boot
      else
        echo "Swap file already exists, skipping creation."
      fi

      # Update APT cache if it's over a day old
      last_updated_cache_file=$(find /var/cache/apt -type f -printf '%T@ %p\n' | sort -n -r | head -n1 | cut -d' ' -f2-)
      last_mod_time=$(stat -c %Y "$last_updated_cache_file")
      cache_updated_seconds=$(($(date +%s) - $last_mod_time))
      if [ $cache_updated_seconds -gt 86400 ]; then
        echo "Running apt-get update..."
        apt-get update
      else
        if [ $cache_updated_seconds -ge 3600 ]; then
          hours=$(($cache_updated_seconds / 3600))
          apt_cache_age="$hours hour(s) old."
        elif [ $cache_updated_seconds -ge 60 ]; then
          minutes=$(($cache_updated_seconds / 60))
          apt_cache_age="$minutes minute(s) old."
        else
          apt_cache_age="$cache_updated_seconds second(s) old."
        fi
        echo "Not updating apt cache; it's only $apt_cache_age"
      fi
      # Install system pacakges required for bootstrapping Salt
      # TODO: get rid of some of these once you have packages installing with Salt
      apt-get install -y \
        build-essential \
        dkms \
        linux-headers-$(uname -r) \
        wget \
        gnupg \
        git \
        screen \
        python3-git \
        python3-pygit2

      # Create directories for Salt configuration
      sudo mkdir -p /etc/salt/minion.d /etc/salt/grains /etc/salt/keys

      # Symlink Salt minion configuration and grains, based on the box's environment
      sudo ln -sf #{project_root}/config/salt/minion.vagrant.conf /etc/salt/minion
      sudo ln -sf #{project_root}/config/salt/grains/base.sls /etc/salt/grains/01-base.sls
      #{vm_config['environment'].each_with_index.map { |env, index|
        "sudo ln -sf #{project_root}/config/salt/minion.d/#{env}.conf /etc/salt/minion.d/#{sprintf('%02d', index + 1)}-#{env}.conf; " +
        "sudo ln -sf #{project_root}/config/salt/grains/#{env}.sls /etc/salt/grains/#{sprintf('%02d', index + 2)}-#{env}.sls"
      }.join("\n")}

      # Symlink a public key for salt-formula to access GitHub
      # TODO: ensure it exists before any of this gets underway
      sudo ln -sf #{project_root}/var/keys/eyrie-github-ro{,.pub} /etc/salt/keys/

      # Clone salt-formula, if it hasn't been already
      if [ ! -d "/srv/formulas/salt-formula" ]; then
        echo "Cloning saltstack-formula into /srv/formulas/..."
        git clone -b v1.12.0 https://github.com/saltstack-formulas/salt-formula.git /srv/formulas/salt-formula
      fi

      # Check if SaltStack is already installed and skip installation if it is
      if ! command -v salt-call > /dev/null 2>&1; then
        echo "Installing Salt minion..."
        wget -O bootstrap-salt.sh https://bootstrap.saltproject.io
        sh bootstrap-salt.sh -P -s 1
      else
        echo "SaltStack already installed. Skipping installation."
      fi

      # Restart Salt minion to apply configuration changes
      # systemctl restart salt-minion
      # echo "Checking for salt-minion readiness..."
      # until sudo systemctl is-active --quiet salt-minion; do
      #   echo "Waiting for salt-minion to start..."
      #   sleep 2
      # done
      # echo "salt-minion is active and running."

      # Apply Highstate
      salt.reload-formulas
      echo "Applying Salt Highstate..."
      sudo salt-call --local state.apply --state-verbose=False
    SHELL
  end

  # Define VMs based on YAML configuration
  vagrants.each do |vm_name, vm_settings|

    # Skip VM definitions for entries starting with an underscore
    next if vm_name.start_with?('_')

    # Define each VM in vagrants.yaml
    vagrant_config.vm.define vm_name do |vm_config|
      setup_base_vm(vm_config, vm_name, vm_settings)
    end

    # Ensure the latest VirtualBox Guest Additions
    vagrant_config.vbguest.auto_update = true

  end
end

