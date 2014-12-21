define network::hosts_entry (
  $address,
  $hostnames,
) {

  require '::network::hosts_entry_dir'

  if is_array($hostnames) {
    $hosts_array = $hostnames
  } else {
    if is_string($hostnames) {
      # It's a bug but if $hostnames is an array with only
      # one value, the parameter is a simple string in the
      # collected resource:
      #
      #     https://tickets.puppetlabs.com/browse/PDB-170
      #
      $hosts_array = [ $hostnames, ]
    } else {
      fail("Class ${title}, `hostnames` parameter must be an array.")
    }
  }

  $hostnames_str = join($hosts_array, ' ')
  $content       = "${address} ${hostnames_str}\n"

  file { "/etc/hosts.puppet.d/${title}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content,
  }

}


