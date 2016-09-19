class rsyncd::params (
  Rsyncd::Modules     $modules,
  Rsyncd::Users       $users,
  Array[String[1], 1] $supported_distributions,
) {

  $secret_file = '/etc/rsyncd.secret'

}


