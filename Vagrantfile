# -*- mode: ruby -*-
# vi: set ft=ruby :

# Notes::
#   Puppet for configuration.

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Common Setup.
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  # This will likely have to be more specific for each host
  config.vm.provision 'puppet' do |puppet|
    puppet.module_path = 'modules'
  end

  config.vm.define 'dev' do |dev|
    dev.vm.hostname = 'dev'
    dev.vm.network "private_network", ip: "192.168.227.5"
    
    # Need to add the appropriate folders to access htdocs, etc.
    dev.vm.synced_folder 'site-root', '/app/drupal', owner: 'www-data', group: 'www-data'
  end

  config.vm.provider 'virtualbox' do |vb|
    # Specify the amount of memory in MB
    vb.memory = 512
    # Specify the number of CPUs
    vb.cpus = 2
  end
end
