class shinken::node::mysql {

  require 'shinken::node::params'

  $exported_dir         = $shinken::node::params::exported_dir
  $tag                  = $shinken::node::params::tag

  # The exported file collected by the shinken server.
  @@file { "${::fqdn}_mysql":
    path    => "$exported_dir/${::fqdn}_mysql.exp",
    content => template('shinken/node/hostname_mysql.exp.erb'),
    tag     => "$tag",
  }

}


