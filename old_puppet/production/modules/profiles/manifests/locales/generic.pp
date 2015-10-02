class profiles::locales::generic ($stage = 'basis', ) {

  $default_locale = hiera('default_locale')

  class { '::locales':
    default_locale => $default_locale,
  }

}


