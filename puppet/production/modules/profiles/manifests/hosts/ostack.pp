class profiles::hosts::ostack ($stage = 'network', ) {

  $ostack_conf = hiera_hash('ostack')
  $ostack_name = $ostack_conf['name']

  if $ostack_name == undef {
    fail("Problem in class ${title}, `ostack_name` data not retrieved")
  }

  include '::profiles::hosts::params'
  $hosts_entries = $::profiles::hosts::params::hosts_entries

  ::network::hosts_entry { $::fqdn:
    tag       => $ostack_name,
    address   => $::ipaddress,
    hostnames => [ $::hostname ],
  }

  class { '::network::hosts':
    hosts_entries => $hosts_entries,
    imported_tag  => $ostack_name,
  }

}


