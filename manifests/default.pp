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
  'nginx',
  'mariadb-server',
  'git-core',
  'git-doc',
  'unzip',
  'rsync',
  'bzr',
  'patch',
  'curl',
  # Grab dependencies for mailcatcher.
  # Gets the C++ compiler (g++) that we need.
  'build-essential',
  # SQLite is a C library that implements a SQL database engine.
  'libsqlite3-dev',
  'ruby-dev',
  ]:
  ensure => installed,
  require => [ Exec['add-maria-db-repository'], Exec['apt-update2'] ],
}

package { 'mailcatcher':
  provider => gem,
  ensure => installed,
  require => [ Package['build-essential'], Package['libsqlite3-dev'], Package['ruby-dev'] ],
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

# Add a default root user that can connect from a wildcard interface.
mysql_user { 'root@192.168.%':
  ensure                   => 'present',
  max_connections_per_hour => '0',
  max_queries_per_hour     => '0',
  max_updates_per_hour     => '0',
  max_user_connections     => '0',
}

mysql_grant { 'root@192.168.%/*.*':
  ensure     => 'present',
  options    => ['GRANT'],
  privileges => ['ALL'],
  table      => '*.*',
  user       => 'root@192.168.%',
}

exec { 'composer-install':
  command => '/usr/bin/curl -sS https://getcomposer.org/installer | php',
  environment => ["HOME=/home/vagrant"],
  require => Package['php5-cli'],
  unless => '/usr/bin/which composer',
}

exec { 'composer-mv':
  command => '/bin/mv composer.phar /usr/bin/composer',
  require => Exec['composer-install'],
  unless => '/usr/bin/which composer',
}

file { 'composer-add-path':
  path => '/etc/profile.d/append-composer-path.sh',
  ensure => file,
  content => 'PATH=$PATH:$HOME/.composer/vendor/bin',
  require => Exec['composer-install'],
}

exec { 'drush-install':
  command => '/usr/bin/composer global require drush/drush:7.1.0',
  environment => ["HOME=/home/vagrant"],
  require => Exec['composer-mv'],
  unless => '/usr/bin/which drush',
}
