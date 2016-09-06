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
  ]

  case $::is_proxmox {

    true: {
      $included_classes = $authorized_classes
      $excluded_classes = [ '::network::hosts' ]
    }

    default: {
      # "repository::proxmox" is very specific for Proxmox
      # so it is removed from $included_classes in the
      # "default" case.
      #
      # Another solution could be to add "repository::proxmox"
      # in $excluded_classes and keep $included_classes =
      # $authorized_classes, but in the "default" case, it
      # seems to me more consistent to have $excluded_classes
      # empty.
      $included_classes = $authorized_classes - [ '::repository::proxmox' ]
      $excluded_classes = [] # In the "default" case, it's more consistent
                             # to have an empty array here.
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


