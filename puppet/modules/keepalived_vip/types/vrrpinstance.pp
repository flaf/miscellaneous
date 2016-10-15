type Keepalived_vip::VrrpInstance = Struct[{
  'virtual_router_id'      => Integer,
  'state'                  => String[1],
  Optional['nopreempt']    => Boolean,
  'interface'              => String[1],
  'priority'               => Integer,
  'auth_type'              => String[1],
  'auth_pass'              => String[1],
  'virtual_ipaddress'      => Array[String[1], 1],
  Optional['track_script'] => Variant[String[1], Keepalived_vip::VrrpScript],
}]


