class shinken::server::admin_scripts {

  require 'shinken::server::params'
  $resources_file    = $shinken::server::params::resources_file
  $lib_dir           = $shinken::server::params::lib_dir
  $puppet_hosts_file = $shinken::server::params::puppet_hosts_file
  $manual_hosts_file = $shinken::server::params::manual_hosts_file
  $source_pass       = "$lib_dir/source_pass"
  $get_extend        = "/usr/local/sbin/get_extend"

  # Default values for the "file" resources.
  File {
    ensure => present,
  }

  file { $source_pass:
    content => template('shinken/server/source_pass.erb'),
    owner   => 'shinken',
    group   => 'shinken',
    mode    => 644,
  }

  file { $get_extend:
    content => template('shinken/server/get_extend.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 754,
  }

}


