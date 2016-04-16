class mcollective::common_paths {

  $etc_dir                 = '/etc/puppetlabs/mcollective'
  $server_keys_dir         = "${etc_dir}/server-keys"
  $allowed_clients_dir     = "${etc_dir}/allowed-clients"
  $client_keys_dir         = "${etc_dir}/client-keys"
  $server_priv_key_path    = "${server_keys_dir}/server.priv-key.pem"
  $client_priv_key_path    = "${client_keys_dir}/${::fqdn}.priv-key.pem"
  $client_pub_key_path     = "${client_keys_dir}/${::fqdn}.pub-key.pem"
  $client_pub_key_path_exp = "${allowed_clients_dir}/${::fqdn}.pub-key.pem"

  $server_pub_key_path_for_server = "${server_keys_dir}/server.pub-key.pem"
  $server_pub_key_path_for_client = "${client_keys_dir}/servers-pub-key.pem"

}


