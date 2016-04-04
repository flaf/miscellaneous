function network::complete_hosts_entries (
  Hash[ String[1], Array[String[1],1] ] $hosts_entries,
) {

  $default_hosts_entries = { '127.0.1.1' => [ $::fqdn, $::hostname ] }

  # Test if fqdn or hostname are present in $hosts_entries.
  $fqdn_hostname_not_in = $hosts_entries.values.filter |$array_addresses| {
      $::fqdn in $array_addresses or $::hostname in $array_addresses
  }.empty

  $fqdn_hostname_in = !$fqdn_hostname_not_in

  case [ '127.0.1.1' in $hosts_entries, $fqdn_hostname_in ] {

    # Case where we add $default_hosts_entries in the hosts entries.
    # This case includes the case where the hosts entries are empty.
    [ false, false ]: {
      $hosts_entries_completed = $default_hosts_entries + $hosts_entries
    }

    [ default, default ]: {
      $hosts_entries_completed = $hosts_entries
    }

  };

  $hosts_entries_completed

}


