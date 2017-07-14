type Confkeeper::ExportedRepos = Hash[
  String[1],
  Struct[{
    Optional['account'] => String[1],
    'ssh_pubkey'        => String[1],
    'repositories'      => Confkeeper::GitRepositories,
  }],
]


