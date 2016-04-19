class repository::mco::params (
  String[1]           $url,
  String[1]           $key_url,
  String[1]           $fingerprint,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


