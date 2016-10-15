type Keepalived_vip::VrrpScript = Struct[{
  'script'   => String[1],
  'interval' => Integer,
  'weight'   => Integer,
}]


