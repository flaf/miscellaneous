type Ceph::Keyring = Struct[{
  'key'             => String[1],
  'capabilities'    => Struct[{
                         Optional['mon'] => Array[String[1], 1],
                         Optional['osd'] => Array[String[1], 1],
                         Optional['mds'] => Array[String[1], 1],
                       }],
  Optional['owner'] => String[1],
  Optional['group'] => String[1],
  Optional['mode']  => String[1],
}]


