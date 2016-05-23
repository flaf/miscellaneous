type Ceph::ClusterConf = Struct[{
  'global_options'     => Hash[String[1], String[1], 1],
  'monitors'           => Hash[String[1], Ceph::Monitor, 1],
  Optional['keyrings'] => Hash[String[1], Ceph::Keyring, 1],
}]


