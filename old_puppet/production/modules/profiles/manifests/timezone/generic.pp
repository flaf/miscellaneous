class profiles::timezone::generic ($stage = 'basis', ) {

  $timezone = hiera('timezone')

  class { '::timezone':
    timezone => $timezone,
  }

}


