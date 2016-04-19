class basic_ssh::server::params (
  Enum['yes', 'without-password', 'forced-commands-only', 'no'] $permitrootlogin,
  Array[String[1], 1]                                           $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


