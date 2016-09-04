class eximnullclient {

  $params = '::eximnullclient::params'
  include $params
  $supported_distributions = ::homemade::getvar("${params}::supported_distributions", $title)

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


