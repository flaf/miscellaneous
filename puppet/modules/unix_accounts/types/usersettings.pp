type Unix_accounts::UserSettings = Struct[{
  'password'                       => String[1],
  'ensure'                         => Unix_accounts::Ensure,
  'uid'                            => Optional[Integer],
  'gid'                            => Optional[Variant[Integer, String[1]]],
  Optional['home']                 => String[1],
  Optional['home_unix_rights']     => Unix_accounts::Unixrights,
  Optional['managehome']           => Boolean,
  Optional['shell']                => String[1],
  Optional['fqdn_in_prompt']       => Boolean,
  Optional['supplementary_groups'] => Array[String[1]],
  Optional['membership']           => Unix_accounts::Membership,
  Optional['is_sudo']              => Boolean,
  Optional['sudo_commands']        => Array[Unix_accounts::SudoCommand],
  Optional['ssh_authorized_keys']  => Array[String[1]],
  Optional['purge_ssh_keys']       => Boolean,
  Optional['ssh_public_keys']      => Unix_accounts::SshPublicKeys,
  'email'                          => Optional[String[1]],
  Optional['extra_info']           => Hash[String[1], Data],
}]
# Tag: USER_PARAMS


