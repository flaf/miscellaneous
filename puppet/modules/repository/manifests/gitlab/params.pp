class repository::gitlab::params (
  String[1]           $url,
  Boolean             $src,
  Optional[String[1]] $pinning_version,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


