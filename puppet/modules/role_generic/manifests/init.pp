class role_generic {

  if !defined(Class['::role_generic::params']) {
      include '::role_generic::params'
  }

  $supported_classes = $::role_generic::params::supported_classes
  $excluded_classes  = $::role_generic::params::excluded_classes
  $included_classes  = $::role_generic::params::included_classes

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

  if $ntp_servers =~ Undef {
    @("END").regsubst('\n', ' ', 'G').fail
      $title: sorry impossible to find the data 'ntp_servers'
      in the inventory networks for this host.
      |- END
  }

  $remaining_classes.each |String[1] $a_class| {

    case $a_class {

      '::basic_ntp': {
        class { '::basic_ntp::params':
          servers => $ntp_servers # retrieved from inventory networks.
        }
        include '::basic_ntp'
      }

      # By default, it's a simple include.
      default: { include $a_class }

    }

  }

}


