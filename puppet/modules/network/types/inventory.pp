type Network::Inventory = Hash[String[1], Struct[{
  'comment'               => Array[String[1], 1],
  'vlan_id'               => String[1],
  'vlan_name'             => String[1],
  'cidr_address'          => String[1],
  Optional['datacenters'] => Array[String[1], 1],
  Optional['gateway']     => String[1],
  Optional['admin_email'] => String[1],
  Optional['ntp_servers'] => Array[String[1], 1],
  Optional['dns_servers'] => Array[String[1], 1],
  Optional['dns_search']  => Array[String[1], 1],
  Optional['routes']      => Hash[String[1], Struct[{ 'to' => String[1], 'via' => String[1] }] ,1],
  Optional['dhcp_range']  => Array[String[1], 2, 2],
  Optional['smtp_relay']  => String[1],
  Optional['smtp_port']   => Integer[1],
}], 1]


