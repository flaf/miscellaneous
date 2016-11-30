function roles::data {

  $authorized_classes = [
    '::unix_accounts',
    '::network',
    '::network::hosts',
    '::network::resolv_conf',
    '::basic_ntp',
    '::repository::distrib',
    '::raid',
    '::basic_ssh::server',
    '::basic_ssh::client',
    '::basic_packages',
    '::keyboard',
    '::locale',
    '::timezone',
    '::puppetagent',
    '::mcollective::server',
    '::snmp',
    '::repository::proxmox',
    '::eximnullclient',
  ]

  # Here the policy for $included_classes and
  # $excluded_classes:
  #
  # a) $included_classes = $authorized_classes - [ "some specific classes..." ]
  # b) $excluded_classes = [ "some not-so-specific classes..." ]
  #
  case $::is_proxmox {

    true: {
      # In fact, set the proxmox repository is useless (and
      # crashes an simple "apt-get update") if we have no
      # license.
      $included_classes = $authorized_classes - [ '::repository::proxmox' ]
      $excluded_classes = [ '::network::hosts', '::eximnullclient' ]
    }

    default: {
      $included_classes = $authorized_classes - [ '::repository::proxmox' ]
      $excluded_classes = [ '::eximnullclient' ]
    }

  }

  $dcs = $datacenters ? {
    NotUndef => $datacenters,
    default  => [],
  }

  $dc = $datacenter ? {
    NotUndef => [ $datacenter ],
    default  => [],
  }

  $default_exchanges = ($dcs + $dc + ['mcollective']).unique.sort;

  {
    roles::generic::params::authorized_classes => $authorized_classes,
    roles::generic::params::included_classes   => $included_classes,
    roles::generic::params::excluded_classes   => $excluded_classes,

    roles::mcomiddleware::params::exchanges => $default_exchanges,

    lookup_options => {
      roles::mcomiddleware::params::exchanges => { merge => 'unique' },
    },
  }

}


