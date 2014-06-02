class shinken::node::raid {

  require 'shinken::node::params'

  $exported_dir         = $shinken::node::params::exported_dir
  $tag                  = $shinken::node::params::tag

  # The exported file collected by the shinken server.
  @@file { "${::hostname}_raid":
    path    => "$exported_dir/${::hostname}_raid.exp",
    content => template('shinken/node/hostname_raid.exp.erb'),
    tag     => "$tag",
  }

}


