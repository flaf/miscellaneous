function roles::data {

  $common_classes = [
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
  ]

  case $::is_proxmox {

    true: {
      $excluded_classes  = [ '::network::hosts' ]
      $supported_classes = $common_classes + [ '::repository::proxmox' ]
    }

    default: {
      $excluded_classes  = []
      $supported_classes = $common_classes
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
    roles::generic::params::supported_classes => $supported_classes,
    roles::generic::params::excluded_classes  => $excluded_classes,
    roles::generic::params::included_classes  => $supported_classes,

    roles::mcomiddleware::params::exchanges => $default_exchanges,

    lookup_options => {
      roles::mcomiddleware::params::exchanges => { merge => 'unique' },
    },
  }

}


