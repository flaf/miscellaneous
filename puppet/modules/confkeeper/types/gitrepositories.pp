type Confkeeper::GitRepositories = Hash[
  Pattern[/^\/[\-\.\_\/a-zA-Z0-9]*[a-zA-Z0-9]$/],
  Struct[{
    Optional['relapath']    => Pattern[/^[a-z][\/a-z0-9\-\.]+\.git$/],
    Optional['permissions'] => Array[Struct[{'rights' => String[1], 'target' => String[1]}], 1],
    'gitignore'             => Optional[Array[String]],
  }],
  1,
]


