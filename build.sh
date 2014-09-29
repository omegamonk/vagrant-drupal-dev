#!/bin/bash

echo -n "Enter profile name > "
read profile

cat << _EOF_ > site.make
api = 2
core = 7.x

projects[drupal][type] = core
projects[drupal][version] = "7.31"

projects[$profile][type] = profile
projects[$profile][download][type] = git
projects[$profile][download][url] = "https://github.com/michfuer/profile_stub"
projects[$profile][download][branch] = master

; Useful tools  ================================================================
projects[tools][type] = module
projects[tools][subdir] = contrib
projects[tools][download][type] = "git"
projects[tools][download][url] = "https://github.com/michfuer/tools"
projects[tools][download][branch] = "master"
_EOF_

drush make --working-copy site.make site-root