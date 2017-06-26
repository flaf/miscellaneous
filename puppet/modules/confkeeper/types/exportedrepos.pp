type Confkeeper::ExportedRepos = Hash[
  String[1],
  Struct[{
    'ssh_pubkey'   => String[1],
    'repositories' => Confkeeper::GitRepositories,
  }],
]


