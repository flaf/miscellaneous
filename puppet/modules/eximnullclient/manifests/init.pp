class eximnullclient {

  $params = '::eximnullclient::params'
  include $params
  $supported_distributions = ::homemade::getvar("${params}::supported_distributions", $title)

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packges( [
                   'exim4-daemon-light',
                   'heirloom-mailx',
                  ], { ensure => present }
                )

}


