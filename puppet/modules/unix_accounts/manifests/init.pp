class unix_accounts (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::unix_accounts::params']) {
    include '::unix_accounts::params'
  }

  $users           = $::unix_accounts::params::users
  $ssh_public_keys = $::unix_accounts::params::ssh_public_keys

  # A user will be managed only if its 'ensure' parameter
  # is absent or present and equal to 'ignore'.
  $users_managed = $users.filter |$user, $params| {
   !('ensure' in $params) or $params['ensure'] != 'ignore'
  }


  ### Handle of each managed user ###
  $users_managed.each |$user, $params| {

    $default_values = ::unix_accounts::defaults()
      + { 'password' => $params['password'] }

    # $params_completed is like $params except that absent
    # keys has been replaced by present keys with a default
    # value.
    $params_completed = $default_values.reduce({}) |$memo, $entry| {
      [ $param, $default ] = $entry
      case $param in $params {
        true:    { $memo + { $param => $params[$param] } }
        default: { $memo + { $param => $default        } }
      }
    }

    $password             = $params_completed['password']
    $ensure               = $params_completed['ensure']
    $supplementary_groups = $params_completed['supplementary_groups']
    $membership           = $params_completed['membership']
    $home_unix_rights     = $params_completed['home_unix_rights']
    $fqdn_in_prompt       = $params_completed['fqdn_in_prompt']
    $is_sudo              = $params_completed['is_sudo']
    $ssh_authorized_keys  = $params_completed['ssh_authorized_keys']
    $home                 = $params_completed['home']

    $purge_ssh_keys = $ensure ? {
    # If this parameter is set to true when the user has
    # "ensure => absent", it can trigger errors because
    # the home has been deleted and Puppet can no longer
    # manage the ssh authorized keys (even in order to
    # purge these keys).
      'present' => true,
      default   => false,
    }

    unix_accounts::user { $user:
      name                 => $user,
      password             => $password,
      ensure               => $ensure,
      supplementary_groups => $supplementary_groups,
      membership           => $membership,
      home                 => $home,
      home_unix_rights     => $home_unix_rights,
      fqdn_in_prompt       => $fqdn_in_prompt,
      is_sudo              => $is_sudo,
      purge_ssh_keys       => $purge_ssh_keys,
      ssh_public_keys      => $ssh_public_keys,
      ssh_authorized_keys  => $ssh_authorized_keys,
    }

    if $user == 'root' {

      # The root user resource is in a specific class to be
      # able to define the attribute "stage" for this
      # specific class. It's possible to define this
      # attribute only for a class, not for a resource.
      include '::unix_accounts::root'

    }

  } # End of the loop of users.

}


