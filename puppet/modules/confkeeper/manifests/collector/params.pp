class confkeeper::collector::params (
  String[1]                         $collection,
  String[1]                         $address,
  String[1]                         $ssh_host_pubkey,
  Optional[String[1]]               $wrapper_cron,
  Array[Integer[0,24], 2, 2]        $hour_range_cron,
  Confkeeper::ExportedRepos         $additional_exported_repos,
  Array[Confkeeper::AllinoneReader] $allinone_readers,
  Array[String[1], 1]               $supported_distributions,
) {

  $non_bare_repos_path = '/home/git/non-bare-repos'

}


