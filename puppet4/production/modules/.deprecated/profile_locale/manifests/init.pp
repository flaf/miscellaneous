class profile_locale (
  $stage = 'basis',
) {

  $default_locale = hiera('default_locale')

  class { '::locale':
    default_locale => $default_locale,
  }

}


