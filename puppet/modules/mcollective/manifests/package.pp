# This is a private class.
class mcollective::package {

  require '::repository::puppet'
  ensure_packages(['puppet-agent'], { ensure => present, })

  # This class will contain variables to define common paths
  # between servers and clients mcollective.
  $etc_dir             = '/etc/puppetlabs/mcollective'
  $server_keys_dir     = "${etc_dir}/server-keys"
  $client_keys_dir     = "${etc_dir}/client-keys"
  $allowed_clients_dir = "${etc_dir}/allowed-clients"

}


