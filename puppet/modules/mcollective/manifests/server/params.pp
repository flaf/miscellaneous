class mcollective::server::params (
  Array[String[1]]             $collectives,
  Optional[ String[1] ]        $private_key,
  Optional[ String[1] ]        $public_key,
  Boolean                      $service_enabled,
  Enum['rabbitmq', 'activemq'] $connector,
  Optional[ String[1] ]        $middleware_address,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $mco_tag,
  String[1]                    $puppet_ssl_dir,
  String[1]                    $puppet_bin_dir,
) {
}


