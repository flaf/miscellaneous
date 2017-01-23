class roles::moobotnode (
  Enum[ 'cargo', 'lb', 'captain' ] $nodetype,
) {

  include '::network::params'

  $interfaces         = $::network::params::interfaces
  $inventory_networks = $::network::params::inventory_networks
  $smtp_relay         = $::network::params::smtp_relay
  $smtp_port          = $::network::params::smtp_port

  include '::moo::params'
  $moobot_tmp = $::moo::params::moobot_conf

  $docker_conf  = $moobot_tmp['docker'] +
    { 'smtp_relay' => $smtp_relay,
      'smtp_port'  => $smtp_port,
    }

  # The moobot is completed.
  $moobot_conf = $moobot_tmp + ( { 'docker' => $docker_conf } )

  case $nodetype {

    'cargo': {

      $primary_address            = $::facts['networking']['ip']
      $iptables_allow_dns         = true
      $docker_iface               = lookup('moo::cargo::params::docker_iface')
      $docker_bridge_cidr_address = lookup('moo::cargo::params::docker_bridge_cidr_address')

      # To monitor the "backup" cron task.
      $default_backup_cmd = ::moo::data()['moo::cargo::params::backup_cmd']
      $backup_cmd         = ::roles::wrap_cron_mon($default_backup_cmd, 'backup-moodles')
      $rsync_filedir_cmd  = ::roles::wrap_cron_mon("${default_backup_cmd} --no-sqldump", 'rsync-filedirs')

      class { '::network::resolv_conf::params':
        local_resolver_interface      => [ $primary_address ],
        local_resolver_access_control => [ [$docker_bridge_cidr_address, 'allow'] ],
      }

      class { '::ceph::params':
        nodetype => 'clientnode',
      }

      include '::roles::ceph'

      unless $docker_iface in $interfaces {
        @("END"/L).fail
          ${title}: the value of the key `moo::cargo::params::docker_iface` \
          (`${docker_iface}`) is not an interface of the parameter \
          `network::params::interfaces` which is forbidden.
          |-END
      }

      # The value of $docker_gateway is the gateway of the
      # interface $docker_iface.
      $docker_gateway = ::network::get_param(
        { $docker_iface => $interfaces[$docker_iface] },
        $inventory_networks,
        'gateway',
        undef
      )

      include '::ceph::params'
      $ceph_account = $::ceph::client_accounts[0]

      case $::hostname {

        /^cargo01/: {
          $make_backups = true
        }

        default: {
          $make_backups = false
          $seed         = 'cargo-cron-rsync-filedir'
          # No backup in cargoXY with XY != '01' but a rsync
          # of the filedir sometimes.
          cron { 'rsync-filedir':
            ensure  => present,
            user    => 'root',
            command => $rsync_filedir_cmd,
            hour    => 20 + fqdn_rand(4, $seed), # ie 20, 21, 22 or 23.
            minute  => fqdn_rand(60, $seed),
            weekday => fqdn_rand(7, $seed),
            require => Class["::moo::${nodetype}"],
          }
        }
      }

      class { 'moo::cargo::params':
        moobot_conf             => $moobot_conf,
        docker_dns              => [ $primary_address ],
        docker_gateway          => $docker_gateway,
        iptables_allow_dns      => $iptables_allow_dns,
        ceph_account            => $ceph_account,
        backup_cmd              => $backup_cmd,
        make_backups            => $make_backups,
      }

    }

    'lb': {

      include 'roles::generic'

      # (i) No longer the case. Now, the VIP is checked via SNMP directly.
      #
      # We want to be able to monitor if the VIP(s) is (are) present.
      #$default_cron_check_cmd = ::keepalived_vip::data()['keepalived_vip::params::cron_check_cmd']
      #$cron_check_cmd         = ::roles::wrap_cron_mon($default_cron_check_cmd, 'check-vip')

      class { '::keepalived_vip::params':
        # (i) No longer the case. Now, the VIP is checked via SNMP directly.
        #cron_check_vip => ::roles::is_number_one(),
        #cron_check_cmd => $cron_check_cmd,
        before         => Class['::keepalived_vip'],
      }

      include '::keepalived_vip'

      class { "moo::${nodetype}::params":
        moobot_conf => $moobot_conf,
      }

    }

    'captain': {

      # To monitor the "backup" cron task.
      $default_backup_cmd = ::moo::data()['moo::captain::params::backup_cmd']
      $backup_cmd         = ::roles::wrap_cron_mon($default_backup_cmd, 'dump-captain-db')

      include 'roles::generic'

      class { "moo::${nodetype}::params":
        moobot_conf => $moobot_conf,
        backup_cmd  => $backup_cmd,
      }

    }

  }

  include '::repository::moobot'

  class { "::moo::${nodetype}":
    require => Class['::repository::moobot']
  }

}


