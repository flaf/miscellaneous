class mcollective::client::params (
  Array[String[1]]             $collectives,
  String[1]                    $private_key,
  String[1]                    $public_key,
  String[1]                    $server_public_key,
  Enum['rabbitmq', 'activemq'] $connector,
  String[1]                    $middleware_address,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $mco_tag,
  Array[String[1]]             $mco_plugin_clients,
  String[1]                    $puppet_ssl_dir,
  Array[String[1], 1]          $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


