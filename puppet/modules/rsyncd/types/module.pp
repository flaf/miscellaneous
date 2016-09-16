type Rsyncd::Module = Struct[
  {
    'path'                   => String[1],
    Optional['comment']      => String[1],
    'read_only'              => Boolean,
    Optional['list']         => Boolean,
    'uid'                    => String[1],
    'gid'                    => String[1],
    Optional['exclude']      => String[1],
    Optional['auth_users']   => Array[String[1], 1],
    Optional['secrets_file'] => String[1],
    Optional['hosts_allow']  => Array[String[1], 1],
  }
]

# Warning: Here, we prefer to avoid space in the name of
# parameters. For instance "read only" is changed to
# "read_only" etc. I prefer to avoid keys with spaces in its
# name in hiera even if it's possible in theory (for
# instance I have tested and lookup('a key with spaces')
# works well).

