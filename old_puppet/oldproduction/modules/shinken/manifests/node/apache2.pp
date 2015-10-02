class shinken::node::apache2 {

  require 'shinken::node::params'

  $exported_dir         = $shinken::node::params::exported_dir
  $tag                  = $shinken::node::params::tag

  # The exported file collected by the shinken server.
  @@file { "${::fqdn}_apache2":
    path    => "$exported_dir/${::fqdn}_apache2.exp",
    content => template('shinken/node/hostname_apache2.exp.erb'),
    tag     => "$tag",
  }

}


