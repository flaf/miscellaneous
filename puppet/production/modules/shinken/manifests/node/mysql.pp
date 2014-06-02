class shinken::node::mysql {

  require 'shinken::node::params'

  $exported_dir         = $shinken::node::params::exported_dir
  $tag                  = $shinken::node::params::tag

  # The exported file collected by the shinken server.
  @@file { "${::hostname}_mysql":
    path    => "$exported_dir/${::hostname}_mysql.exp",
    content => template('shinken/node/hostname_mysql.exp.erb'),
    tag     => "$tag",
  }

}


