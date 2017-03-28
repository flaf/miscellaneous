type Unix_accounts::SshPublicKeys = Hash[
  String[1],
  Struct[
    {
      Optional['type'] => String[1],
      'keyvalue'       => String[1],
      Optional['tags'] => Array[String[1]],
    }
  ]
]


