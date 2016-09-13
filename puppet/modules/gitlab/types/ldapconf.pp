type Gitlab::LdapConf = Variant[
  Enum['none'],
  Struct[
    {
      'host'                          => String[1],
      'port'                          => Integer[1],
      'uid'                           => String[1],
      'method'                        => Enum['plain', 'ssl', 'tls'],
      'bind_dn'                       => String[1],
      'password'                      => String[1],
      'allow_username_or_email_login' => Boolean,
      'block_auto_created_users'      => Boolean,
      'base'                          => String[1],
    }
  ]
]


