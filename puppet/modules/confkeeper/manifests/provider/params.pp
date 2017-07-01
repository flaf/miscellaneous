class confkeeper::provider::params (
  Confkeeper::GitRepositories $repositories,
  String[1]                   $fqdn,
  Optional[String[1]]         $etckeeper_ssh_pubkey,
  Array[String[1], 1]         $supported_distributions,
) {

  $etckeeper_sshkey_path = '/root/.ssh/etckeeper_id_rsa'
  $etckeeper_known_hosts = '/root/.ssh/etckeeper_known_hosts'

}


