type Snmp::Snmpv3account = Struct[
  {
    'name'                => String[1],
    'authpass'            => String[1],
    Optional['authproto'] => String[1],
    'privpass'            => String[1],
    Optional['privproto'] => String[1],
    Optional['view']      => String[1],
  }
]


