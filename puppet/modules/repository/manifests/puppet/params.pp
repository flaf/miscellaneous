class repository::puppet::params (
  String[1]           $url,
  Boolean             $src,
  Optional[String[1]] $collection,
  Optional[String[1]] $pinning_agent_version,
  Optional[String[1]] $pinning_server_version,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


