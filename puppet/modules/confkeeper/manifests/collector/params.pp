class confkeeper::collector::params (
  String[1]                 $collection,
  String[1]                 $address,
  String[1]                 $ssh_host_pubkey,
  Optional[String[1]]       $wrapper_cron,
  Confkeeper::ExportedRepos $additional_exported_repos,
  Array[String[1], 1]       $supported_distributions,
) {

  $non_bare_repos_path = '/home/git/non-bare-repos'

}


