class roles::generic::defaults {

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

  # The default value of the $included_classes parameter is directly
  # defined in the class roles::generic::params.

}



