type Monitoring::CheckDns = Hash[
  Pattern[/^[a-z][-.a-z0-9]+$/], # The description of the DNS check.
  Struct[{
    'fqdn'                       => String[1],
    Optional['server']           => String[1], # The server to request.
    Optional['expected-address'] => String[1],
    Optional['options']          => String[1],
  }],
]


