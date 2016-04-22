class puppetforge::params (
  String[1]                           $puppetforge_git_url,
  String[1]                           $commit_id,
  String[1]                           $remote_forge,
  String[1]                           $address,
  Integer[1]                          $port,
  Integer[1]                          $pause,
  Array[String[1]]                    $modules_git_urls,
  Integer[1]                          $release_retention,
  Optional[ Puppetforge::Sshkeypair ] $sshkeypair,
  Array[String[1], 1]                 $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


