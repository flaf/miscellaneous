class unix_accounts::params (
  Unix_accounts::Users           $users,
  Unix_accounts::Ssh_public_keys $ssh_public_keys,
  String[1]                      $rootstage,
  Array[String[1], 1]            $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


