class raid::hpssacli (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::repository::hp_proliant'

  ensure_packages('hpssacli', { ensure => present,})

}


