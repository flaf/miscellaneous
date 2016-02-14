class raid::areca (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::repository::raid'

  ensure_packages('areca-cli', { ensure => present,})

}


