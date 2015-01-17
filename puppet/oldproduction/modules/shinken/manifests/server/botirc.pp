class shinken::server::botirc {

  require 'shinken::server::params'

  $irc_pipe_file    = $shinken::server::params::irc_pipe_file
  $botirc_conf_file = $shinken::server::params::botirc_conf_file
  $irc_server       = $shinken::server::params::irc_server
  $irc_port         = $shinken::server::params::irc_port
  $irc_channel      = $shinken::server::params::irc_channel
  $irc_password     = $shinken::server::params::irc_password

  exec { 'create_irc_pipe':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => "rm -f '$irc_pipe_file' && mkfifo '$irc_pipe_file'",
    onlyif  => "[ ! -p '$irc_pipe_file' ]",
  }

  ->

  file { $irc_pipe_file:
    # No ensure, the pipe file is created
    # by an exec ressource because it's not a
    # regular file or a directory.
    ensure => undef,
    owner  => 'shinken',
    group  => 'shinken',
    mode   => 0600,
    notify => Service['botirc-parrot'],
  }

  ->

  file { 'botirc-parrot_conf':
    path    => "$botirc_conf_file",
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('shinken/server/botirc-parrot.erb'),
    notify  => Service['botirc-parrot'],
  }

  ->

  service { 'botirc-parrot':
    name       => 'botirc-parrot',
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}


