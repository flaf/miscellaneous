# User-defined type which provided an exported hosts entry.
# Be careful that each title of the exported hosts entries
# is unique.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# *address:*
# A string which represents the IP address of the hosts entries.
# A value like "@ipaddress" or "@ipaddress_eth1" is allowed,
# the string will be correctly interpreted.
# This parameter is mandatory and has no default value.
#
# *hostnames:*
# An array of hostames mapped to to the previous address.
# A value like [ "@fqdn", "@hostname" ] is allowed,
# the strings will be correctly interpreted.
# This parameter is mandatory and has no default value.
#
# == Sample Usages
#
#  ::network::hosts_entry { $::fqdn:
#    address   => $::ipaddress,
#    hostnames => [ $::fqdn, $::hostname ],
#  }
#
#  # Hosts entries will be shared between the cluster foo members.
#  class { '::network::hosts':
#    imported_tag => 'cluster-foo',
#  }
#
define network::hosts_entry (
  $address,
  $hostnames,
) {

  # No, because value like "@ipadress" for instance is accepted too.
  #
  #unless is_ip_address($address) {
  #  fail("Class ${title}, `address` parameter must be an IP address.")
  #}

  validate_string($address)

  unless is_array($hostnames) {
    fail("Class ${title}, `hostnames` parameter must be an array.")
  }

  $tmp = {
          'key' => concat([$address], $hostnames)
         }

  # We use this function just to replace @xxx values.
  # Warning, $ht has a different structure from $tmp.
  $ht = update_hosts_entries($tmp)

  # The real address (for instance, if $address == "@ipaddress",
  # now $addr contains the real IP address).
  $keys  = keys($ht)
  $addr  = $keys[0]

  $hostnames_str = join($ht[$addr], ' ')
  $content       = "${addr} ${hostnames_str}\n"

  @@file { "/etc/hosts.puppet.d/${title}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content,
  }

}


