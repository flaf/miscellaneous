function unix_accounts::defaults (Optional[String[1]] $login = undef ) {

  $home = $login ? {
    'root'  => '/root',
    undef   => undef,
    default => "/home/${login}",
  };

  {
    'ensure'               => 'present',
    'supplementary_groups' => [],
    'membership'           => 'inclusive',
    'home_unix_rights'     => '0750',
    'fqdn_in_prompt'       => false,
    'is_sudo'              => false,
    'ssh_authorized_keys'  => [],
    'ssh_public_keys'      => {},
    'purge_ssh_keys'       => false,
    'home'                 => $home,
  }

}


