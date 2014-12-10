class profiles::hosts::params {

  $network_conf  = hiera_hash('network')
  $hosts_entries = $network_conf['hosts_entries']

  # Test if the data has been well retrieved.
  if $hosts_entries == undef {
    fail("Problem in class ${title}, `hosts_entries` data not retrieved")
  }

}


