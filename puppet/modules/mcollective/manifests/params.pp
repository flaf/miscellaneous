# Normally, the "undef" as default values should be useless.
# But currently, those are mandatory and it's probably a bug:
#
#     https://tickets.puppetlabs.com/browse/PUP-5925
#
class mcollective::params (
  Array[String[1]]             $client_collectives,
  Optional[ String[1] ]        $client_private_key = undef,
  Optional[ String[1] ]        $client_public_key = undef,
  Array[String[1]]             $server_collectives,
  Optional[ String[1] ]        $server_private_key = undef,
  Optional[ String[1] ]        $server_public_key = undef,
  Boolean                      $server_enabled,
  Enum['rabbitmq', 'activemq'] $connector,
  Optional[ String[1] ]        $middleware_address = undef,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $mco_tag,
  String[1]                    $puppet_ssl_dir,
  String[1]                    $puppet_bin_dir,
) {
}


