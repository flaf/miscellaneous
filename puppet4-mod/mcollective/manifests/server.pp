# TODO: add feature to manage subcollectives.
#       https://docs.puppetlabs.com/mcollective/configure/server.html#collectives
class mcollective::server (
  String[1]                    $server_private_key,
  String[1]                    $server_public_key,
  Enum['rabbitmq', 'activemq'] $connector,
  String[1]                    $middleware_server,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $puppet_ssl_dir,
  Array[String[1], 1]          $supported_distributions,
  #####$client_public_keys,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::repository::puppet'

  ensure_packages(['puppet-agent'], { ensure => present, })

  $mco_ssl_dir             = '/etc/puppetlabs/mcollective/ssl'
  $server_private_key_file = "${mco_ssl_dir}/server-private.pem"
  $server_public_key_file  = "${mco_ssl_dir}/server-public.pem"

  file { $mco_ssl_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0500',
    require => Package['puppet-agent'],
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { $server_private_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $server_private_key,
    require => Package['puppet-agent'],
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { $server_public_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $server_public_key,
    require => Package['puppet-agent'],
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { '/etc/puppetlabs/mcollective/server.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'mcollective/server.cfg.epp',
                    { 'server_private_key_file' => $server_private_key_file,
                      'server_public_key_file'  => $server_public_key_file,
                      'mco_ssl_dir'             => $mco_ssl_dir,
                      'puppet_ssl_dir'          => $puppet_ssl_dir,
                      'connector'               => $connector,
                      'middleware_server'       => $middleware_server,
                      'middleware_port'         => $middleware_port,
                      'mcollective_pwd'         => $mcollective_pwd,
                      'puppet_ssl_dir'          => $puppet_ssl_dir,
                    }
                  ),
    require => Package['puppet-agent'],
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  $etc_default = @(END)
    ### This file is managed by Puppet, don't edit it. ###
    #START=true
    #DAEMON_OPTS="--pid ${pidfile}"
    pidfile="/var/run/mcollectived-puppetlabs.pid"
    daemonopts="--pid=${pidfile} --config=/etc/puppetlabs/mcollective/server.cfg"

    | END

  file { '/etc/default/mcollective':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $etc_default,
    require => Package['puppet-agent'],
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  ## Public keys of the mcollective clients.
  #$defaults = {
  #  require => Package['mcollective'],
  #  before  => Service['mcollective'],
  #  notify  => Service['mcollective'],
  #}
  #create_resources('::mcollective::mco_client_public_key', $client_public_keys, $defaults)

  service { 'mcollective':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

}


