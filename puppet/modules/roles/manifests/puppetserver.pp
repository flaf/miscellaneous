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

  # The pinnings of some packages of a Puppet server are needed too.
  include '::repository::puppetserver'

  ###################################
  ### The puppetserver management ###
  ###################################

  # Handle of the ssh public keys for the backups.
  include '::unix_accounts::params'
  $ssh_public_keys = $::unix_accounts::params::ssh_public_keys

  $authorized_backup_keys = $backup_keynames.reduce({}) |$memo, String[1] $keyname| {

    unless $keyname in $ssh_public_keys {
      @("END"/L$).fail
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

  # For a `client` puppetserver, the $datacenters global
  # variable is required.
  unless $::datacenters =~ Array[String[1], 1] {
    @("END"/L$).fail
      ${title}: sorry you must define the ENC variable \
      \$::datacenters as a non-empty array of non-empty \
      strings.
      |- END
  }

  class { '::puppetserver::params':
    authorized_backup_keys => $authorized_backup_keys,
    datacenters            => $datacenters,
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
    require => [
                 Class['::repository::puppet'],
                 Class['::repository::puppetserver'],
               ],
  }
  ###################################




  ###########################################
  ### The mcollective::clients management ###
  ###########################################
  if $::roles::puppetserver::params::is_mcollective_client {

    include '::mcollective::server::params'
    include '::roles::mcomiddleware::params'

    include '::repository::puppet'
    include '::repository::mco'

    class { 'mcollective::client::params':
      collectives        => $::roles::mcomiddleware::params::exchanges,
      server_public_key  => $::mcollective::server::params::public_key,
      middleware_address => $::mcollective::server::params::middleware_address,
      middleware_port    => $::mcollective::server::params::middleware_port,
      mcollective_pwd    => $::mcollective::server::params::mcollective_pwd,
      puppet_ssl_dir     => $::mcollective::server::params::puppet_ssl_dir,
      mco_plugins        => [ 'mcollective-flaf-clients' ],
    }

    class { '::mcollective::client':
      require => [ Class['::repository::mco'],
                   Class['::repository::puppet'],
                 ],
    }

  }
  ###########################################

}


