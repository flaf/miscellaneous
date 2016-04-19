class repository::postgresql::params (
  String[1]           $url,
  Boolean             $src,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


