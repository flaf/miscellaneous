class shinken::node::mysql_repl {

  require 'shinken::node::params'

  $exported_dir         = $shinken::node::params::exported_dir
  $tag                  = $shinken::node::params::tag

  # The exported file collected by the shinken server.
  @@file { "${::hostname}_mysql_repl":
    path    => "$exported_dir/${::hostname}_mysql_repl.exp",
    content => template('shinken/node/hostname_mysql_repl.exp.erb'),
    tag     => "$tag",
  }

}


