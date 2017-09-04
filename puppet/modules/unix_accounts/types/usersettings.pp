type Unix_accounts::UserSettings = Struct[{
  'password'                       => String[1],
  'ensure'                         => Unix_accounts::Ensure,
  Optional['uid']                  => Integer,
  Optional['gid']                  => Variant[Integer, String[1]],
  Optional['home']                 => String[1],
  Optional['home_unix_rights']     => Unix_accounts::Unixrights,
  Optional['managehome']           => Boolean,
  Optional['shell']                => String[1],
  Optional['fqdn_in_prompt']       => Boolean,
  Optional['supplementary_groups'] => Array[String[1]],
  Optional['membership']           => Unix_accounts::Membership,
  Optional['is_sudo']              => Boolean,
  Optional['ssh_authorized_keys']  => Array[String[1]],
  Optional['purge_ssh_keys']       => Boolean,
  Optional['ssh_public_keys']      => Unix_accounts::SshPublicKeys,
  Optional['email']                => String[1],
}]
# Tag: USER_PARAMS


