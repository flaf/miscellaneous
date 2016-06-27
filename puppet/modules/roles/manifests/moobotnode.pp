class roles::moobotnode {

  include '::roles::moobotnode::params'
  $nodetype = $::roles::moobotnode::params::nodetype

  include '::moo::common::params'
  $moobot_conf = $::moo::common::params::moobot_conf,

  case $nodetype {

    'cargo': {

      $docker_dns                 = $::facts['networking']['ip']
      $iptables_allow_dns         = true
      $docker_iface               = lookup('moo::cargo::params::docker_iface')
      $docker_bridge_cidr_address = lookup('moo::cargo::params::docker_bridge_cidr_address')

      class { '::network::resolv_conf::params':
        local_resolver_interface      => $docker_dns,
        local_resolver_access_control => [ [$docker_bridge_cidr_address, 'allow'] ],
      }

      class { '::ceph::params':
        nodetype => 'clientnode',
      }

      include '::roles::ceph'

      include '::network::params'

      $interfaces         = $::network::params::interfaces
      $inventory_networks = $::network::params::inventory_networks

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

      include '::ceph::node::params'
      $ceph_account = $::ceph::node::client_accounts[0]

      $make_backups = $::hostname ? {
        /^cargo01/ => true,
        default    => false,
      }

      class { 'moo::cargo::params':
        moobot_conf             => $moobot_conf,
        docker_dns              => $docker_dns,
        docker_gateway          => $docker_gateway,
        iptables_allow_dns      => $iptables_allow_dns,
        ceph_account            => $ceph_account,
        backups_retention       => 60,
        backups_moodles_per_day => 13,
        make_backups            => $make_backups,
      }

    }

    'lb': {
      include 'roles::generic'
      include '::keepalived_vip'
      class { "moo::${nodetype}::params":
        moobot_conf => $moobot_conf,
      }
    }

    'captain': {
      include 'roles::generic'
      class { "moo::${nodetype}::params":
        moobot_conf => $moobot_conf,
      }
    }

  }

  include "::moo::${nodetype}"

}


