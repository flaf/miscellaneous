type Pxeserver::Dhcpconf = Struct[{
  'netname'              => String[1],
  'range'                => Array[String[1], 3, 3],
  Optional['router']     => String[1],
  Optional['dns-server'] => Array[String[1], 1],
}]


