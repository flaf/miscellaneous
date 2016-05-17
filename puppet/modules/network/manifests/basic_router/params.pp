class network::basic_router::params (
  Array[String[1], 1] $masqueraded_networks,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


