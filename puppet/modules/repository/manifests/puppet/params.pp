class repository::puppet::params (
  String[1]           $url,
  Boolean             $src,
  String[1]           $apt_key_fingerprint,
  Optional[String[1]] $collection,
  Optional[String[1]] $pinning_agent_version,
  Array[String[1], 1] $supported_distributions,
) {
}


