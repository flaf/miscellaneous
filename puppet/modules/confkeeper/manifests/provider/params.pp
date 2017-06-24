class confkeeper::provider::params (
  String[1]           $collection,
  Array[String[1], 1] $supported_distributions,
) {

  $etckeeper_sshkey_path = '/root/.ssh/etckeeper_id_rsa'
  $etckeeper_known_hosts = '/root/.ssh/etckeeper_known_hosts'

}


