#
# This Vagrantfile tells Vagrant how to tell Virtualbox how to build boxes.
# You can find the definitions for the boxes in etc/vagrants.yaml
#
# Boxes are seeded with Salt, and have states and settings applied, and packages
# installed, according to the definitions described in the vagrants.yaml file.
#

# Require the YAML module
require 'yaml'

# Load the YAML file
config_yaml = YAML.load_file('etc/vagrants.yaml', aliases: true)

Vagrant.configure("2") do |config|

  def setup_base_vm(vm, name, vm_config, vbox_config = nil)
    vm.vm.box = vm_config['box']
    vm.vm.hostname = "#{name}"
    vm.vm.provider "virtualbox" do |vb|
      timestamp = Time.now.strftime("%Y-%m-%d-%H%M")
      vb.name = "#{name}-#{timestamp}"
      vb.memory = vm_config['memory']

      # Apply additional VirtualBox settings from the YAML file
      if vbox_config
        vbox_config.each do |key, value|
          if value.is_a?(Hash)
            # Handle nested hash options if needed, or skip/raise error
            # For example, you might want to log a warning or raise an exception:
            # raise "Nested hash configurations are not supported for VirtualBox: #{key} => #{value.inspect}"
            puts "Skipping configuration for #{key} because it expects a hash value."
          else
            vb.public_send("#{key}=", value)
          end
        end
      end
    end

    # Set up synced folders, shell provisions, etc.
    vm.vm.synced_folder "./etc/salt/pillars", "/srv/pillar", type: "rsync",
      rsync__exclude: ".git/",
      rsync__args: ["--verbose", "--archive", "--delete", "-z"]

    vm.vm.synced_folder "./etc/salt/root", "/srv/salt", type: "rsync",
      rsync__exclude: ".git/",
      rsync__args: ["--verbose", "--archive", "--delete", "-z"]

    # Provision scripts and other setup
    vm.vm.provision "shell", inline: <<-SHELL
      sudo fallocate -l #{vm_config['swap']} /swapfile
      sudo chmod 600 /swapfile
      sudo mkswap /swapfile
      sudo swapon /swapfile
      echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

      sudo chown -R vagrant:vagrant /srv/pillar
      sudo chown -R vagrant:vagrant /srv/salt
    SHELL

    vm.vm.provision "file", source: "./etc/salt/root/docker.sls", destination: "/srv/salt/docker.sls"
    vm.vm.provision "shell", inline: <<-SHELL

      # Check if APT update is needed
      if [ ! -f /var/lib/apt/periodic/update-success-stamp ] || [ $(( $(date +%s) - $(stat -c %Y /var/lib/apt/periodic/update-success-stamp) )) -gt 86400 ]; then
        echo "Running apt-get update..."
        apt-get update
      fi
      apt-get install -y wget gnupg git

      # Check if the salt-formula directory exists before cloning
      if [ ! -d "/srv/salt/salt-formula" ]; then
        git clone https://github.com/saltstack-formulas/salt-formula.git /srv/salt/salt-formula
      fi

      # Check if SaltStack is already installed and skip installation if it is
      if ! command -v salt-call > /dev/null 2>&1; then
        echo "Installing SaltStack..."
        wget -O bootstrap-salt.sh https://bootstrap.saltproject.io
        sh bootstrap-salt.sh -P -M
        echo "file_client: local" > /etc/salt/minion
      else
        echo "SaltStack already installed. Skipping installation."
      fi

      # Restart Salt minion to apply configuration changes
      systemctl restart salt-minion
      echo "Checking for salt-minion readiness..."
      until sudo systemctl is-active --quiet salt-minion; do
        echo "Waiting for salt-minion to start..."
        sleep 2
      done
      echo "salt-minion is active and running."

      # Run salt-call with sudo
      sudo salt-call --local state.apply docker -l debug
    SHELL
  end

  # Define VMs based on YAML configuration
  config_yaml.each do |vm_name, vm_settings|
    # Skip VM definitions for entries starting with an underscore
    next if vm_name.start_with?('_')

    config.vm.define vm_name do |vm_config|
      setup_base_vm(vm_config, vm_name, vm_settings, vm_settings['virtualbox'])
    end
  end

end

