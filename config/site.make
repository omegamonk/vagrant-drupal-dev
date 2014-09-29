; Drush make this makefile to build a new Drupal installation.
;
;     $ drush make --working-copy distro.make example_dir
; Uncomment and adjust as necessary.
# api = 2
# core = 7.x

# projects[drupal][type] = core
# projects[drupal][version] = "7.31"

# projects[PROFILE_NAME][type] = profile
# projects[PROFILE_NAME][download][type] = git
# projects[PROFILE_NAME][download][url] = git@github.com:my_user_name/PROFILE_NAME.git
# projects[PROFILE_NAME][download][branch] = master

; Useful tools  ================================================================
# projects[tools][type] = module
# projects[tools][subdir] = contrib
# projects[tools][download][type] = "git"
# projects[tools][download][url] = "git@github.com:michfuer/tools.git"
# projects[tools][download][branch] = "master"
