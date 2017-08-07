type Monitoring::CheckDns = Hash[
  Pattern[/^[a-z][-.a-z0-9]+$/],
  Struct[{
    'fqdn'                       => String[1],
    Optional['server']           => String[1],
    Optional['expected-address'] => String[1],
    Optional['options']          => String[1],
  }],
]


