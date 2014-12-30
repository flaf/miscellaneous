define hosts::entry (
  $address,
  $hostnames,
  $only_exported = false,
) {

  require '::hosts'

  validate_string($address)

  unless is_empty($address) {
    fail("Class ${title}, `address` parameter must be a non empty string.")
  }

  $addr = inline_tepmplate(str2erb($address))

  unless is_ip_address($addr) {
    fail("Class ${title}, `address` parameter must be an IP address after \
expansion.")
  }



  #unless is_array($hostnames) {
  #  fail("Class ${title}, `hostnames` parameter must be an array.")
  #}

  #$tmp = {
  #        'key' => concat([$address], $hostnames)
  #       }

  ## We use this function just to replace @xxx values.
  ## Warning, $ht has a different structure from $tmp.
  #$ht = update_hosts_entries($tmp)

  ## The real address (for instance, if $address == "@ipaddress",
  ## now $addr contains the real IP address).
  #$keys  = keys($ht)
  #$addr  = $keys[0]

  #$hostnames_str = join($ht[$addr], ' ')
  #$content       = "${addr} ${hostnames_str}\n"

  #@@file { "/etc/hosts.puppet.d/${title}.conf":
  #  ensure  => present,
  #  owner   => 'root',
  #  group   => 'root',
  #  mode    => '0644',
  #  content => $content,
  #}

}


