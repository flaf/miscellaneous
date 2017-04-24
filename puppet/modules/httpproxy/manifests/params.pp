class httpproxy::params {
  Optional[String[1]] $apt_cacher_ng_adminpwd,
  Integer[1]          $apt_cacher_ng_port,
  Array[String[1], 1] $supported_distributions,
}


