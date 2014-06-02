class shinken::server::reverse_proxy {

  require 'shinken::server::params'

  $html_filter_bin = $shinken::server::params::html_filter_bin
  $add_in_links    = $shinken::server::params::add_in_links

  # If $add_in_links is "_EMPTY_", it's unnecessary to create
  # the filter script.
  if ($add_in_links == '_EMPTY_') {
    $ensure_filter_bin = 'absent'
  }
  else {
    $ensure_filter_bin = 'present'
  }

  # Default values for "exec" resources.
  Exec {
    path   => '/usr/sbin:/usr/bin:/sbin:/bin',
    user   => 'root',
    group  => 'root',
    notify => Service['apache2']
  }

  package { 'apache2':
    ensure => latest,
    notify => Service['apache2']
  }

  ->

  exec { 'disable deflate':
    command => 'a2dismod deflate',
    # Exec only if there is the symlink.
    onlyif  => 'test -L /etc/apache2/mods-enabled/deflate.load',
  }

  ->

  exec { 'enable proxy_http':
    command => 'a2enmod proxy_http',
    # Exec unless there is already the symlink.
    unless  => 'test -L /etc/apache2/mods-enabled/proxy_http.load',
  }

  ->

  exec { 'enable ext_filter':
    command => 'a2enmod ext_filter',
    # Exec unless there is already the symlink.
    unless  => 'test -L /etc/apache2/mods-enabled/ext_filter.load',
  }

  ->

  file { 'shinken vhost':
    path    => '/etc/apache2/sites-available/shinken',
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('shinken/server/shinken-vhost.erb'),
    notify  => Service['apache2']
  }

  ->

  exec { 'enable shinken vhost':
    command => 'a2ensite shinken',
    # Exec unless there is already the symlink.
    unless  => 'test -L /etc/apache2/sites-enabled/shinken',
  }

  ->

  exec { 'disable default vhost':
    command => 'a2dissite default',
    # Exec only if there is already the symlink.
    onlyif  => 'test -L /etc/apache2/sites-enabled/000-default',
  }

  ->

  file { 'html_filter':
    path     => $html_filter_bin,
    ensure   => $ensure_filter_bin,
    owner    => 'root',
    group    => 'root',
    mode     => 755,
    content  => template('shinken/server/html_filter.erb'),
    notify   => Service['apache2']
  }

  ->

  service { 'apache2':
    ensure => running,
    hasstatus => true,
    hasrestart => true,
  }

}


