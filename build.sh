#!/bin/bash

##### Functions

# Creates a default drush makefile.
create_site_make() {
	cat <<- _EOF_ > site.make
	api = 2
	core = 7.x

	projects[drupal][type] = core
	projects[drupal][version] = "7.31"

	projects[profile_stub][type] = profile
	projects[profile_stub][download][type] = git
	projects[profile_stub][download][url] = "https://github.com/michfuer/profile_stub"
	projects[profile_stub][download][branch] = master
	_EOF_
}

# Creates a default Vagrantfile.
create_vagrantfile() {

	echo -n "Enter desired IP address e.g. 192.168.227.x. Remember to update /etc/hosts with the same address. > "
	read address

	cat <<- _EOF_ > Vagrantfile
	# -*- mode: ruby -*-
	# vi: set ft=ruby :

	# Notes::
	#   Puppet for configuration.

	# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
	VAGRANTFILE_API_VERSION = '2'

	Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	  config.vm.box = 'ubuntu/trusty64'
	  config.vm.box_url = 'https://vagrantcloud.com/ubuntu/trusty64'

	  # This will likely have to be more specific for each host
	  config.vm.provision 'puppet' do |puppet|
	    puppet.module_path = 'modules'
	  end

	  config.vm.define 'dev' do |dev|
	    dev.vm.hostname = 'dev'
	    dev.vm.network "private_network", ip: "$address"

	    # Need to add the appropriate folders to access htdocs, etc.
	    dev.vm.synced_folder 'site-root', '/app/drupal', type: 'nfs'
	  end

	  config.vm.provider 'virtualbox' do |vb|
	    # Specify the amount of memory in MB
	    vb.memory = 2048
	    # Specify the number of CPUs
	    vb.cpus = 2
	  end
	end
	_EOF_

}

# Create/Update the Vagrantfile
if [[ -f Vagrantfile ]]; then
    echo -n "Overwrite existing Vagrantfile (y/n)? "
    read overwrite
    if [[ "$overwrite" = "y" ]]; then
    	create_vagrantfile
    fi
else
	create_vagrantfile
fi

# Create/Update the site makefile
if [[ -f site.make ]]; then
    echo -n "Overwrite existing site.make file (y/n)? "
    read overwrite
    if [[ "$overwrite" = "y" ]]; then
    	create_site_make
    fi
else
	create_site_make
fi

echo -n "Build site.make (y/n)? "
read build

#

if [[ "$build" = "y" ]]; then
	echo -n "Enter desired profile branch name > "
	read profile

	drush make --working-copy site.make site-root
	cd site-root/profiles/profile_stub
	git checkout -b $profile
fi
