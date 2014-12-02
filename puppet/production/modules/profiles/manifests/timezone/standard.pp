class profiles::timezone::standard {

  $timezone = hiera('timezone')

  class { '::timezone':
    timezone => $timezone,
  }

}


