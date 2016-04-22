class mcomiddleware::params (
  String[1]             $stomp_ssl_ip,
  Integer[1]            $stomp_ssl_port,
  Array[String[1]]      $ssl_versions,
  Optional[ String[1] ] $puppet_ssl_dir,
  Optional[ String[1] ] $admin_pwd,
  Optional[ String[1] ] $mcollective_pwd,
  Array[String[1]]      $exchanges,
  Array[String[1], 1]   $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


