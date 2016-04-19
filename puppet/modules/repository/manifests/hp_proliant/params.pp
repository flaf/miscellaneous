class repository::hp_proliant::params (
  String[1]           $url,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


