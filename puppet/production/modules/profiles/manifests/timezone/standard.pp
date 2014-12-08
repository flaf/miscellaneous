class profiles::timezone::standard ($stage = 'basis', ) {

  $timezone = hiera('timezone')

  class { '::timezone':
    timezone => $timezone,
  }

}


