type Confkeeper::GitRepositories = Array[
  Struct[{
    relapath    => Pattern[/^[a-z][\/a-z0-9\-\.]+\.git$/],
    permissions => Array[String[1], 2, 2],
  }],
  1
]


