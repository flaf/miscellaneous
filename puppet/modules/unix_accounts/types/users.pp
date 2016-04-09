type Unix_accounts::Users = Hash[
  String[1],
  Struct[
    {
      'password'                       => String[1],
      Optional['ensure']               => Unix_accounts::Ensure,
      Optional['is_sudo']              => Boolean,
      Optional['supplementary_groups'] => Array[String[1]],
      Optional['membership']           => Unix_accounts::Membership,
      Optional['home_unix_rights']     => Unix_accounts::Unixrights,
      Optional['ssh_authorized_keys']  => Array[String[1]],
      Optional['fqdn_in_prompt']       => Boolean,
    }
  ]
]


