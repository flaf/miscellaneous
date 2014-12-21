class profiles::hosts::ostack {

  $ostack_conf = hiera_hash('ostack')
  $ostack_name = $ostack_conf['name']

  if $ostack_name == undef {
    fail("Problem in class ${title}, `ostack_name` data not retrieved")
  }

  include '::profiles::hosts::params'
  $hosts_entries = $::profiles::hosts::params::hosts_entries

  @@::network::hosts_entry { $::fqdn:
    tag       => $ostack_name,
    address   => $::ipaddress,
    hostnames => [ $::hostname ],
  }

  ::Network::Hosts_entry <<| tag == $ostack_name |>>

  if is_string($::additional_hosts_entries) {
    $additional = {}
    eval_ruby_code ('
               hosts_entries = eval($arg1)
               additional = $arg2
               hosts_entries.each do |key, val|
                 additional[key] = val
               end
      ', $::additional_hosts_entries, $additional)
  } else {
    $additional = $::additional_hosts_entries
  }

  $merged_hash = merge($hosts_entries, $additional)
  #$merged_hash = merge($hosts_entries, $::additional_hosts_entries)

  class { '::network::hosts':
    hosts_entries => $merged_hash,
  }

}


