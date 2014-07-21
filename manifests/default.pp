exec { 'apt-update':
  command => '/usr/bin/apt-get update',
}

exec { 'add-maria-db-key':
  command => '/usr/bin/apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db',
}

package { 'python-software-properties':
  ensure => installed,
  require => Exec['apt-update']
}

exec { 'add-maria-db-repository':
  command => "/usr/bin/add-apt-repository 'deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.0/ubuntu precise main'",
  require => [ Exec['add-maria-db-key'], Package['python-software-properties'] ]
}

exec { 'apt-update2':
  command => '/usr/bin/apt-get update',
  require => Exec['add-maria-db-repository'],
}

package { [
  'php5-cli',
  'php5-fpm',
  'php5-mysql',
  'php5-curl',
  'php5-common',
  'php5-gd',
  'php-pear',
  'nginx',
  'mariadb-server',
  'git-core',
  'git-doc',
  'unzip',
  'rsync',
  'bzr',
  'patch',
  'curl',
  ]:
  ensure => installed,
  require => [ Exec['add-maria-db-repository'], Exec['apt-update2'] ],
}

service { 'nginx':
  ensure => running,
  require => Package['nginx'],
}

service { 'php5-fpm':
  ensure => running,
  require => Package['php5-fpm'],
}

service { 'mysql':
  ensure => running,
  require => Package['mariadb-server'],
}

# php5-fpm php.ini file
file { 'php5-fpm-ini':
  path => '/etc/php5/fpm/php.ini',
  ensure => file,
  replace => true,
  require => Package['php5-fpm'],
  source => 'puppet:///modules/php5-fpm/php.ini',
  owner => root,
  group => root,
  mode => 644,
}

# php5-fpm www.conf file
file { 'php5-fpm-www-conf':
  path => '/etc/php5/fpm/pool.d/www.conf',
  ensure => file,
  replace => true,
  require => [ Package['php5-fpm'], File['php5-fpm-ini'] ],
  source => 'puppet:///modules/php5-fpm/www.conf',
  notify => Service['php5-fpm'],
  owner => root,
  group => root,
  mode => 644,
}

# nginx.conf
file { 'drupal-nginx-conf':
  path => '/etc/nginx/nginx.conf',
  ensure => file,
  replace => true,
  require => Package['nginx'],
  source => 'puppet:///modules/nginx/nginx.conf',
  notify => Service['nginx'],
  owner => root,
  group => root,
  mode => 644,
}

# drupal site config
file { 'drupal-nginx':
	path => '/etc/nginx/sites-available/drupal',
	ensure => file,
  replace => true,
	require => Package['nginx'],
	source => 'puppet:///modules/nginx/drupal',
  notify => Service['nginx'],
  owner => root,
  group => root,
  mode => 644,
}

# remove nginx default site enabled file
file { 'default-nginx-disable':
	path => '/etc/nginx/sites-enabled/default',
	ensure => absent,
	require => Package['nginx'],
}

# link drupal site enabled file
file { 'drupal-nginx-enable':
	path => '/etc/nginx/sites-enabled/drupal',
	target => '/etc/nginx/sites-available/drupal',
	ensure => link,
	notify => Service['nginx'],
	require => [
		File['drupal-nginx'],
		File['default-nginx-disable'],
	],
  owner => root,
  group => root,
  mode => 644,
}

# remove index.html file
file { 'remove-nginx-index.html':
  path => '/app/drupal/index.html',
  ensure => absent,
  require => Package['nginx'],
}

# create mariadb config file
file { 'drupal-mariadb-config':
  path => '/etc/mysql/my.cnf',
  ensure => file,
  notify => Service['mysql'],
  source => 'puppet:///modules/mariadb/my.cnf',
  require => Package['mariadb-server'],
  owner => root,
  group => root,
  mode => 644,
}

exec { 'pear-update-console-getopt':
  command => '/usr/bin/pear upgrade --force Console_Getopt',
  require => Package['php-pear'],
}

exec { 'pear-update-pear':
  command => '/usr/bin/pear upgrade --force pear',
  require => Exec['pear-update-console-getopt'],
}

exec { 'pear-install-drush-channel':
  command => '/usr/bin/pear channel-discover pear.drush.org',
  require => Exec['pear-update-pear'],
}

exec { 'pear-install-console-table':
  command => '/usr/bin/pear install Console_Table',
  require => Exec['pear-install-drush-channel'],
}

exec { 'pear-install-drush':
  command => '/usr/bin/pear install drush/drush',
  require => Exec['pear-install-console-table'],
}
