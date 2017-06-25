class confkeeper::provider::params (
  String[1]                           $collection,
  Array[Confkeeper::GitRepository, 1] $repositories
  Optional[String[1]]                 $etckeeper_ssh_pubkey
  Array[String[1], 1]                 $supported_distributions,
) {

  $etckeeper_sshkey_path = '/root/.ssh/etckeeper_id_rsa'
  $etckeeper_known_hosts = '/root/.ssh/etckeeper_known_hosts'

}


