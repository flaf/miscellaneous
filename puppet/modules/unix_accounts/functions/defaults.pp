function unix_accounts::defaults (String[1] $login) {

  $home = $login ? {
    'root'  => '/root',
    default => "/home/${login}",
  };

  # Tag: USER_PARAMS
  {
    'ensure'               => 'present',
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
    'ssh_authorized_keys'  => [],
    'purge_ssh_keys'       => true,
    'ssh_public_keys'      => {},
    'email'                => undef,
  }

}


