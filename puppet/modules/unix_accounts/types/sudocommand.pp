type Unix_accounts::SudoCommand = Struct[{
  Optional['comment'] => Array[String[1], 1],
  'host'              => String[1],
  'run_as'            => String[1],
  'tag'               => String,
  'command'           => String[1],
}]


