#!/bin/bash

##### Functions

# Creates a default drush makefile.
create_site_make()
{
	cat <<- _EOF_ > site.make
	api = 2
	core = 7.x

	projects[drupal][type] = core
	projects[drupal][version] = "7.31"

	projects[profile_stub][type] = profile
	projects[profile_stub][download][type] = git
	projects[profile_stub][download][url] = "https://github.com/michfuer/profile_stub"
	projects[profile_stub][download][branch] = master

	# Useful tools  ================================================================
	projects[tools][type] = module
	projects[tools][subdir] = contrib
	projects[tools][download][type] = "git"
	projects[tools][download][url] = "https://github.com/michfuer/tools"
	projects[tools][download][branch] = "master"
	_EOF_
}

if [[ -f site.make ]]; then
    echo "Overwrite existing site.make file (y/n)? "
    read overwrite
    if [[ "$overwrite" = "y" ]]; then
    	create_site_make
    fi
else
	create_site_make
fi

echo -n "Build site.make (y/n)? "
read build

if [[ "$build" = "y" ]]; then
	drush make --working-copy site.make site-root
fi
