class profiles::hosts::ceph ($stage = 'network', ) {

  #include '::profiles::hosts::params'
  #$hosts_entries = $::profiles::hosts::params::hosts_entries

  # The hostname (ie the short name) may be linked to 2
  # different IP addresses: $::ipaddress and the IP
  # of the monitor which can be different (not in the
  # same network). So, we don't append $::hostname
  # in the 'self' hosts entry.
  $hosts_entries = {
                    'self' => [ $::ipaddress, $::fqdn, ],
                   }


  # The goal is to add monitors in the hosts entries.
  $ceph_conf = hiera_hash('ceph')
  $monitors  = $ceph_conf['monitors']

  # Test if the data has been well retrieved.
  if $monitors == undef {
    fail("Problem in class ${title}, `monitors` data not retrieved")
  }

  # Update the $hosts_entries array.
  # TODO: is it possible to do that just with the puppetlabs-stdlib?
  #       I don't believe...
  # TODO: change eval_ruby_code, it must be a rvalue (more secure).
  eval_ruby_code('
      hosts_entries = $arg1
      monitors      = $arg2

      monitors.each do |name, v|
        address = v["address"]
        hostname = name
        id = v["id"]
        hosts_entries["monitors-#{id}"] = [ address, hostname ]
      end
      ', $hosts_entries, $monitors)

  class { '::network::hosts':
    hosts_entries => $hosts_entries,
  }

}


