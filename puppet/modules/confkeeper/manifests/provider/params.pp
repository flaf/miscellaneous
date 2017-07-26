class confkeeper::provider::params (
  String[1]                   $collection,
  Confkeeper::GitRepositories $repositories,
  Optional[String[1]]         $wrapper_cron,
  Array[Integer[0,24], 2, 2]  $hour_range_cron,
  Boolean                     $devnull_cron,
  String[1]                   $fqdn,
  Optional[String[1]]         $etckeeper_ssh_pubkey,
  Array[String[1], 1]         $supported_distributions,
) {

  $etckeeper_sshkey_path = '/root/.ssh/etckeeper_id_rsa'
  $etckeeper_known_hosts = '/root/.ssh/etckeeper_known_hosts'

}


