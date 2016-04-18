class roles::puppetserver {

  # Import parameters.
  include '::roles::puppetserver::params'
  $is_mcollective_client  = $::roles::puppetserver::params::is_mcollective_client
  $backup_keynames        = $::roles::puppetserver::params::backup_keynames




  ##################################
  ### Include the role "generic" ###
  ##################################
  #
  # The module "puppetagent" must not manage the puppet.conf
  # file.
  class { '::puppetagent::params':
    manage_puppetconf => false,
  }
  include '::roles::generic'
  ##################################




  ###################################
  ### The puppetserver management ###
  ###################################

  # Handle of the ssh public keys for the backups.
  include '::unix_accounts::params'
  $ssh_public_keys = $::unix_accounts::params::ssh_public_keys

  $authorized_backup_keys = $backup_keynames.reduce({}) |$memo, String[1] $keyname| {

    unless $keyname in $ssh_public_keys {
      @("END"/L).fail
        ${title}: the ssh public key `${keyname}` from the parameter \
        \$::roles::puppetserver::params::backup_keynames is not \
        present among the public keys listed in the parameter \
        \$::unix_accounts::params::ssh_public_keys.
        |- END
    }

    $key = {
      $keyname => {
        'type'     => $ssh_public_keys[$keyname]['type'],
        'keyvalue' => $ssh_public_keys[$keyname]['keyvalue'],
      }
    }

    $memo + $key

  }

  class { '::puppetserver::params':
    authorized_backup_keys => $authorized_backup_keys,
  }

  # Repository Postgresql needed only for a "autonomous"
  # puppetserver (because Postgresql is installed only on
  # "autonomous" puppetserver).
  if $::puppetserver::params::profile == 'autonomous' {
    class { '::repository::postgresql':
      before => Class['::puppetserver'],
    }
  }

  include '::repository::puppet'

  class { '::puppetserver':
    require => Class['::repository::puppet'],
  }
  ###################################




  ###########################################
  ### The mcollective::clients management ###
  ###########################################
  if $::roles::puppetserver::params::is_mcollective_client {

    # The mcollective client use the middleware of the mcollective server.
    include '::mcollective::server::params'
    include '::mcomiddleware::params'

    $dcs = $datacenters ? {
      NotUndef => $datacenters,
      default  => [],
    }

    $dc = $datacenter ? {
      NotUndef => [ $datacenter ],
      default  => [],
    }

    $middleware_exchanges = $::mcomiddleware::params::exchanges
    $collectives = ($dcs + $dc + [ 'mcollective' ] + $middleware_exchanges).unique.sort

    # Repository needed to install mcollective which is the
    # puppet-agent package
    include '::repository::puppet'

    # Repository needed to install mcollective plugins.
    include '::repository::mco'

    class { 'mcollective::client::params':
      collectives        => $collectives,
      server_public_key  => $::mcollective::server::params::public_key,
      middleware_address => $::mcollective::server::params::middleware_address,
      middleware_port    => $::mcollective::server::params::middleware_port,
      mcollective_pwd    => $::mcollective::server::params::mcollective_pwd,
      puppet_ssl_dir     => $::mcollective::server::params::puppet_ssl_dir,
      mco_plugin_clients => [ 'mcollective-flaf-clients' ],
    }

    class { '::mcollective::client':
      require => [ Class['::repository::mco'],
                   Class['::repository::puppet'],
                 ],
    }

  }
  ###########################################

}


