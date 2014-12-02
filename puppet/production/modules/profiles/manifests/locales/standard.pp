class profiles::locales::standard {

  $default_locale = hiera('default_locale')

  class { '::locales':
    default_locale => $default_locale,
  }

}


