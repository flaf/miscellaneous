define network::hosts_entry (
  $address,
  $hostnames,
) {

  unless is_ip_address($address) {
    fail("Class ${title}, `address` parameter must be an IP address.")
  }

  unless is_array($hostnames) {
    fail("Class ${title}, `hostnames` parameter must be an array.")
  }

  $hostnames_str = join($hostnames, ' ')
  $content       = "${address} ${hostnames_str}\n"

  @@file { "/etc/hosts.puppet.d/${title}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content,
  }

}


