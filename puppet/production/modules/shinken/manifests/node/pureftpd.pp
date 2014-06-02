class shinken::node::pureftpd {

  require 'shinken::node::params'

  $exported_dir         = $shinken::node::params::exported_dir
  $tag                  = $shinken::node::params::tag

  # The exported file collected by the shinken server.
  @@file { "${::hostname}_pureftpd":
    path    => "$exported_dir/${::hostname}_pureftpd.exp",
    content => template('shinken/node/hostname_pureftpd.exp.erb'),
    tag     => "$tag",
  }

}


