type Httpproxy::SquidguardConf = Struct[{
  Optional['src']  => Hash[ String[1], Hash[String[1], Variant[String[1], Array[String[1], 1]], 1], 1],
  Optional['dest'] => Hash[ String[1], Hash[String[1], Variant[String[1], Array[String[1], 1]], 1], 1],
  'acl'            => Hash[ String[1], Hash[String[1], Variant[String[1], Array[String[1], 1]], 1], 1],
}]


