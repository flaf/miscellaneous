class profiles::hosts::ceph ($stage = 'network', ) {

  include '::profiles::hosts::params'
  $hosts_entries = $::profiles::hosts::params::hosts_entries

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


