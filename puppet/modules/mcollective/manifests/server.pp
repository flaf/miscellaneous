class mcollective::server (
  Array[String[1]]             $collectives,
  String[1]                    $server_private_key,
  String[1]                    $server_public_key,
  Boolean                      $server_enabled,
  Enum['rabbitmq', 'activemq'] $connector,
  String[1]                    $middleware_address,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $mco_tag,
  String[1]                    $puppet_ssl_dir,
  Array[String[1], 1]          $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::mcollective::package'

  # Just shortcuts.
  $server_keys_dir     = $::mcollective::package::server_keys_dir
  $allowed_clients_dir = $::mcollective::package::allowed_clients_dir
  $client_keys_dir     = $::mcollective::package::client_keys_dir

  # Paths of important files.
  $server_priv_key_path = "${server_keys_dir}/server.priv-key.pem"
  $server_pub_key_path  = "${server_keys_dir}/server.pub-key.pem"

  $default_collectives = $::datacenter ? {
    undef   => [ 'mcollective' ],
    default => [ 'mcollective', $::datacenter ],
  }
  $collectives_final_value = $default_collectives.concat($collectives).unique()

  # mcollective::client and mcollective::server will manage this
  # directory because the client keys are very sensitive. If a
  # node is no longer a mcollective client, we want to remove the
  # client keys (especially the client private key).
  if !defined(File[$client_keys_dir]) {
    file { $client_keys_dir:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0500',
      recurse => true,
      purge   => true,
    }
  }

  file { [ "${server_keys_dir}",
           "${allowed_clients_dir}"
         ]:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0500',
    recurse => true,
    purge   => true,
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { $server_priv_key_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $server_private_key,
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { $server_pub_key_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $server_public_key,
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  # Import the exported public keys of mcollective clients with the tag.
  File <<| tag == $mco_tag |>> {
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  file { '/etc/puppetlabs/mcollective/server.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'mcollective/server.cfg.epp',
                    {
                      'collectives'         => $collectives_final_value,
                      'server_priv_key_path'=> $server_priv_key_path,
                      'server_pub_key_path' => $server_pub_key_path,
                      'allowed_clients_dir' => $allowed_clients_dir,
                      'puppet_ssl_dir'      => $puppet_ssl_dir,
                      'connector'           => $connector,
                      'middleware_address'  => $middleware_address,
                      'middleware_port'     => $middleware_port,
                      'mcollective_pwd'     => $mcollective_pwd,
                    }
                  ),
    before  => Service['mcollective'],
    notify  => Service['mcollective'],
  }

  # TODO: workaround for PUP-5232.
  #       https://tickets.puppetlabs.com/browse/PUP-5232
  if $::lsbdistcodename == 'trusty' {
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
      before  => Service['mcollective'],
      notify  => Service['mcollective'],
    }
  }

  $ensure_mco = $server_enabled ? {
    true  => 'running',
    false => 'stopped',
  }

  service { 'mcollective':
    ensure     => $ensure_mco,
    hasstatus  => true,
    hasrestart => true,
    enable     => $server_enabled,
  }

}


