class profile_timezone ($stage = 'basis', ) {

  $timezone = hiera('timezone')

  class { '::timezone':
    timezone => $timezone,
  }

}


