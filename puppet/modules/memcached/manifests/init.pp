class memcached (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages( [ 'memcached' ], { ensure => present } )

}


