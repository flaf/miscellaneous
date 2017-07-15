type Confkeeper::AllinoneReader = Struct[{
  'username'   => Pattern[/^[\-a-z0-9]+$/],
  'ssh_pubkey' => String[1],
}]


