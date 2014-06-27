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
  'php5-gd',
  'nginx',
  'mariadb-server',
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

file { 'default-nginx-disable':
	path => '/etc/nginx/sites-enabled/default',
	ensure => absent,
	require => Package['nginx'],
}

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

file { 'remove-nginx-index.html':
  path => '/app/drupal/index.html',
  ensure => absent,
  require => Package['nginx'],
}
