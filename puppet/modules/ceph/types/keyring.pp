type Ceph::Keyring = Struct[{
  'key'                    => String[1],
  'properties'             => Array[String[1], 1],
  Optional['radosgw_host'] => String[1],
  Optional['rgw_dns_name'] => String[1],
  Optional['owner']        => String[1],
  Optional['group']        => String[1],
  Optional['mode']         => String[1],
}]


