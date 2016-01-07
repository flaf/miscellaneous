class network::params (
  Hash[String[1], Data, 1]                     $inventory_networks,
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
  Boolean                                      $restart,

  String[1]                                    $resolvconf_domain,
  Array[String[1], 1]                          $resolvconf_search,
  Integer[1]                                   $resolvconf_timeout,
  Boolean                                      $resolvconf_override_dhcp,
  Array[String[1], 1]                          $dns_servers,
  Boolean                                      $local_resolver,
  Array[String[1]]                             $local_resolver_interface,
  Array[ Array[String[1], 2, 2] ]              $local_resolver_access_control,

  Hash[ String[1], Array[String[1],1] ]        $hosts_entries,
  String                                       $hosts_from_tag,

  Variant[ Array[String[1], 1], Enum['all'] ]  $ntp_interfaces,
  Array[String[1], 1]                          $ntp_servers,
  Variant[ Array[String[1], 1], Enum['all'] ]  $ntp_subnets_authorized,
  Boolean                                      $ntp_ipv6,

  String[1]                                    $smtp_relay,
  Integer[1]                                   $smtp_port,
) {
}


