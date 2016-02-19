# undef because => PUP-5925
class mcomiddleware::params (
  String[1]             $stomp_ssl_ip,
  Integer[1]            $stomp_ssl_port,
  Array[String[1]]      $ssl_versions,
  String[1]             $puppet_ssl_dir,
  Optional[ String[1] ] $admin_pwd = undef,
  Optional[ String[1] ] $mcollective_pwd = undef,
  Array[String[1]]      $exchanges,
) {
}


