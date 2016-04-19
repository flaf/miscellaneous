class basic_ntp::params (
  Variant[ Array[String[1], 1], Enum['all'] ] $interfaces,
  Array[String[1], 1]                         $servers,
  Variant[ Array[String[1], 1], Enum['all'] ] $subnets_authorized,
  Boolean                                     $ipv6,
  Array[String[1], 1]                         $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


