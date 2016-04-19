class timezone::params (
  Enum['Etc/UTC', 'Europe/Paris'] $timezone,
  Array[String[1], 1]             $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


