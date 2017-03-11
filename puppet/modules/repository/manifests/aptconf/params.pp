class repository::aptconf::params (
  Optional[String[1]] $apt_proxy,
  String[1]           $keyserver,
  Boolean             $install_recommends,
  Array[String[1], 1] $supported_distributions,
) {
}


