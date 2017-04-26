type Httpproxy::PGPPublicKey = Struct[{
  'name'      => Pattern[/^[a-z][a-z0-9\-\.]+$/],
  'id'        => Pattern[/^0x[0-9A-F]{40,}$/],
  'content'   => String[1],
}]


