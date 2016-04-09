class unix_accounts (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::unix_accounts::params']) {
    include '::unix_accounts::params'
  }

  $users = $::unix_accounts::params::users

  # A user will be managed only if its 'ensure' parameter
  # is absent or present and equal to 'ignore'.
  $users_managed = $users.filter |$user, $params| {
   !('ensure' in $params) or $params['ensure'] != 'ignore'
  }


  ### Handle of each managed user ###
  $users_managed.each |$user, $params| {

    $default_values = ::unix_accounts::defaults($user)
      + { 'password' => $params['password'] }

    # $params_completed is like $params except that absent
    # keys has been replaced by present keys with a default
    # value.
    $params_completed = $default_values.reduce({}) |$memo, $entry| {
      [ $param, $default_value ] = $entry
      case $param in $params {
        true:    { $memo + { $param => $params[$param] } }
        default: { $memo + { $param => $default_value  } }
      }
    }

    # All the parameters of a unix_accounts::user resource.
    # Tag: USER_PARAMS
    $password             = $params_completed['password']
    $ensure               = $params_completed['ensure']
    $uid                  = $params_completed['uid']
    $gid                  = $params_completed['gid']
    $home                 = $params_completed['home']
    $home_unix_rights     = $params_completed['home_unix_rights']
    $managehome           = $params_completed['managehome']
    $shell                = $params_completed['shell']
    $fqdn_in_prompt       = $params_completed['fqdn_in_prompt']
    $supplementary_groups = $params_completed['supplementary_groups']
    $membership           = $params_completed['membership']
    $is_sudo              = $params_completed['is_sudo']
    $ssh_authorized_keys  = $params_completed['ssh_authorized_keys']
    $purge_ssh_keys       = $ensure ? { 'present' => true, default   => false }
    $ssh_public_keys      = $::unix_accounts::params::ssh_public_keys
    #
    # If $purge_ssh_keys is set to true when the user has
    # "ensure => absent", it can trigger errors because
    # the home has been deleted and Puppet can no longer
    # manage the ssh authorized keys (even in order to
    # purge these keys).

    # Tag: USER_PARAMS
    unix_accounts::user { $user:
      login                => $user,
      password             => $password,
      ensure               => $ensure,
      uid                  => $uid,
      gid                  => $gid,
      home                 => $home,
      home_unix_rights     => $home_unix_rights,
      managehome           => $managehome,
      shell                => $shell,
      fqdn_in_prompt       => $fqdn_in_prompt,
      supplementary_groups => $supplementary_groups,
      membership           => $membership,
      is_sudo              => $is_sudo,
      ssh_authorized_keys  => $ssh_authorized_keys,
      purge_ssh_keys       => $purge_ssh_keys,
      ssh_public_keys      => $ssh_public_keys,
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


