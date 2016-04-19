class repository::distrib::params (
  String[1]           $url,
  Boolean             $src,
  Boolean             $install_recommends,
  Boolean             $backports,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


