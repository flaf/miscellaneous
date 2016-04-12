class roles::generic {

  if !defined(Class['::roles::generic::params']) {
      include '::roles::generic::params'
  }

  $supported_classes = $::roles::generic::params::supported_classes
  $excluded_classes  = $::roles::generic::params::excluded_classes
  $included_classes  = $::roles::generic::params::included_classes

  # All classes in $excluded_classes must belong to the
  # $supported_classes array. The goal is to avoid a case
  # where the user wants to exclude a class but he makes a
  # misprint in its name and the real class is not excluded.
  $excluded_classes.each |$a_class| {
    unless $a_class in $supported_classes {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: you want to exclude the class `${a_class}` from the
        module `${title}` but this class does not belong to the list of
        classes supported by this module. Are you sure you have not made
        a misprint?
        |- END
    }
  }

  # We check that all classes in $included_classes are in
  # $supported_classes.
  $included_classes.each |$a_class| {
    unless $a_class in $supported_classes {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: you want to include the class `${a_class}` from the
        module `${title}` but this class does not belong to the list of
        classes supported by this module. Are you sure you have not made
        a misprint?
        |- END
    }
  }

  $remaining_classes = $included_classes - $excluded_classes


  if !defined(Class['::network::params']) {
    include '::network::params'
  }

  $interfaces         = $::network::params::interfaces
  $inventory_networks = $::network::params::inventory_networks
  $ntp_servers        = ::network::get_param($interfaces, $inventory_networks, 'ntp_servers')
  $snmp_syscontact    = ::network::get_param($interfaces, $inventory_networks, 'admin_email')

  if $ntp_servers =~ Undef {
    @("END").regsubst('\n', ' ', 'G').fail
      $title: sorry impossible to find the (needed) data 'ntp_servers'
      in the inventory networks for this host.
      |- END
  }

  if $snmp_syscontact =~ Undef {
    @("END").regsubst('\n', ' ', 'G').fail
      $title: sorry impossible to find the (needed) data 'admin_email'
      in the inventory networks for this host.
      |- END
  }

  # For this class, we have retrieved NTP servers from
  # inventory networks.
  class { '::basic_ntp::params':
    servers => $ntp_servers,
  }

  class { '::snmp::params':
    syscontact => $snmp_syscontact,
  }

  $remaining_classes.each |String[1] $a_class| {

    case $a_class {

      '::snmp': {
        # With SNMP, we want to install the snmpd-extend package.
        include '::repository::shinken'
        [ 'snmpd-extend' ].ensure_packages({
          ensure  => present,
          require => Class['::repository::shinken'],
          before  => Class['::snmp'],
        })
        include '::snmp'
      }

      # By default, it's a simple include.
      default: {
        include $a_class
      }

    }

  }

}


