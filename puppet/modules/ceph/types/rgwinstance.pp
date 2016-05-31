type Ceph::RgwInstance = Struct[{
  'hosts'                  => Array[String[1], 1],
  'keyring'                => String[1],
  Optional['port']         => Integer,
  Optional['rgw_dns_name'] => String[1],
}]


