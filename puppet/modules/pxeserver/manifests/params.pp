class pxeserver:params (
  Optional[ Hash[String[1], Hash[String[1], Data], 1] ] $dhcp_conf,
  Hash[String[1], Array[String[1], 2, 2]]               $ip_reservations,
  Optional[ String[1] ]                                 $puppet_collection,
  Optional[ String[1] ]                                 $pinning_puppet_version,
  Optional[ String[1] ]                                 $puppet_server,
  Optional[ String[1] ]                                 $puppet_ca_server,
  Array[String[1], 1]                                   $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


