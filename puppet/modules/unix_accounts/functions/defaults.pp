function unix_accounts::defaults (
  String[1]                    $login,
  Unix_accounts::Ensure        $ensure,
  Unix_accounts::SshPublicKeys $ssh_public_keys = {},
) {

  $home = $login ? {
    'root'  => '/root',
    default => "/home/${login}",
  }

  # If "purge_ssh_keys" is set to true when the user has
  # "ensure => absent", it can trigger errors because the
  # home has been deleted and Puppet can no longer manage
  # the ssh authorized keys (even in order to purge these
  # keys).
  $purge_ssh_keys = $ensure ? {
    'present' => true,
    default   => false
  };

  # Tag: USER_PARAMS
  #
  # Default values of non-optional keys of
  # Unix_accounts::UserSettings structure.
  {
    'uid'                  => undef,
    'gid'                  => undef,
    'home'                 => $home,
    'home_unix_rights'     => '0750',
    'managehome'           => true,
    'shell'                => '/bin/bash',
    'fqdn_in_prompt'       => false,
    'supplementary_groups' => [],
    'membership'           => 'inclusive',
    'is_sudo'              => false,
    'sudo_commands'        => [],
    'ssh_authorized_keys'  => [],
    'purge_ssh_keys'       => $purge_ssh_keys,
    'ssh_public_keys'      => $ssh_public_keys,
    'email'                => undef,
    'extra_info'           => {},
  }

}


