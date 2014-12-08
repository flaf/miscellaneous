class profiles::locales::standard ($stage = 'basis', ) {

  $default_locale = hiera('default_locale')

  class { '::locales':
    default_locale => $default_locale,
  }

}


