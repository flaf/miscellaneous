class unix_accounts {

  include '::unix_accounts::params'

  [
    $users,
    $ssh_public_keys,
    $rootstage,
    $supported_distributions,
  ] = Class['::unix_accounts::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # In any case, a minimal ~/.vimrc file will be created in
  # the managed homes and the minimal .vimrc required "vim"
  # installed.
  ensure_packages(['vim'], {ensure => present})

  # A user will be managed only if its 'ensure' parameter
  # is absent or present and equal to 'ignore'.
  $users_managed = $users.filter |$user, $settings| {
   !('ensure' in $settings) or $settings['ensure'] != 'ignore'
  }


  ### Handle of each managed user ###
  $users_managed.each |$user, $settings| {

    $default_settings   = ::unix_accounts::defaults(
                            $user,
                            $settings['ensure'],
                            $ssh_public_keys,
                          )

    $settings_completed = $default_settings + $settings

    unix_accounts::user { $user:
      login    => $user,
      settings => $settings_completed,
    }

    if $user == 'root' {
      # The root user resource is in a specific class to be
      # able to define the attribute "stage" for this
      # specific class. It's possible to define this
      # attribute only for a class, not for a resource.
      class { '::unix_accounts::root':
        stage => $rootstage,
      }
    }

  } # End of the loop of users.

}


