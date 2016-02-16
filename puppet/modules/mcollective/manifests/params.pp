class mcollective::params (
  Array[String[1]]             $collectives,
  String[1]                    $client_private_key,
  String[1]                    $client_public_key,
  String[1]                    $server_private_key,
  String[1]                    $server_public_key,
  Boolean                      $server_enabled,
  Enum['rabbitmq', 'activemq'] $connector,
  String[1]                    $middleware_address,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $mco_tag,
  String[1]                    $puppet_ssl_dir,
  String[1]                    $puppet_bin_dir,
) {
}


