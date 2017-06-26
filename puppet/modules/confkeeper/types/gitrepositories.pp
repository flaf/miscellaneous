type Confkeeper::GitRepositories = Hash[
  Pattern[/^\/.*$/],
  Struct[{
    'relapath'    => Pattern[/^[a-z][\/a-z0-9\-\.]+\.git$/],
    'permissions' => Array[Struct[{'rights' => String[1], 'target' => String[1]}], 1],
  }],
  1,
]


