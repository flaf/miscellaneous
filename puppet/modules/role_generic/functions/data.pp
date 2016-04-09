function role_generic::data {

  # All the classes handled by this module.
  $supported_classes = [
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
    true:    { $excluded_classes = [ '::network::hosts' ] }
    default: { $excluded_classes = [ ]                    }
  };

  {
    role_generic::params::supported_classes => $supported_classes,

    # Default value defined in the class role_generic::params.
    #role_generic::params::included_classes  => $supported_classes,

    role_generic::params::excluded_classes  => $excluded_classes,
  }

}


