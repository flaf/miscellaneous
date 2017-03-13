class repository::aptconf::params (
  Optional[String[1]] $apt_proxy,
  Boolean             $install_recommends,
  Boolean             $install_suggests,
  String[1]           $distrib_url,
  Boolean             $src,
  Boolean             $backports,
  Array[String[1], 1] $supported_distributions,
) {
}


