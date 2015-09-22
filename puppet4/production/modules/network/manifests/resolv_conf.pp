# TODO: add the boolean parameter "local_resolver".
#       If true, it installs unbound (for instance)
#       and the server uses:
#
#           nameserver localhost
#           nameserver <the list of $nameservers parameter>
#
#       in resolv.conf. And unbound will forwards to
#       the nameservers in $nameservers.
#
class network::resolv_conf (
  String[1]           $domain,
  Array[String[1], 1] $search,
  Array[String[1], 1] $nameservers,
  Integer[1]          $timeout,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $interfaces = ::network::data()['network::interfaces']

  # Get the interfaces configured via DHCP.
  # Be careful, with .filter if the first argument is
  # a hash, the loop entry is an array with [key, value].
  $dhcp_ifaces = $interfaces.filter |$iface| {
    $dhcp_families = ['inet', 'inet6'].filter |$family| {
      if $iface[1].has_key($family) and $iface[1][$family]['method'] == 'dhcp' {
        true
      } else {
        false
      }
    }
    !$dhcp_families.empty
  }

  # No DHCP, so we can manage the resolv.conf file.
  # Indeed, if at least one interface is configured
  # via DHCP, this file will be (and should be) updated
  # via the DHCP mechanism, not via Puppet. It seems
  # to me more logical.
  if $dhcp_ifaces.empty {

    # With "ensure => file" is the file is a symlink to
    # "../run/resolvconf/resolv.conf", the symlink will
    # be removed and replaced by a regular file. So,
    # resolvconf mechanism will be disabled.
    file { '/etc/resolv.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('network/resolv.conf.epp',
                     { 'domain'      => $domain,
                       'search'      => $search,
                       'nameservers' => $nameservers,
                       'timeout'     => $timeout,
                     }
                    ),
    }

  }

}


