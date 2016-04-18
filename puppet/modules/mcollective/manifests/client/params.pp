class mcollective::client::params (
  Array[String[1]]             $collectives,
  Optional[String[1]]          $private_key,
  Optional[String[1]]          $public_key,
  Optional[String[1]]          $server_public_key,
  Enum['rabbitmq', 'activemq'] $connector,
  Optional[String[1]]          $middleware_address,
  Optional[Integer[1]]         $middleware_port,
  Optional[String[1]]          $mcollective_pwd,
  String[1]                    $mco_tag,
  Array[String[1]]             $mco_plugin_clients,
  Optional[String[1]]          $puppet_ssl_dir,
  Array[String[1], 1]          $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $collectives_sorted = $collectives.unique.sort

}


