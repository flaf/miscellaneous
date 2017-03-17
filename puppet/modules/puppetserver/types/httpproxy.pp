type Puppetserver::HttpProxy = Struct[{
  'host'           => String[1],
  'port'           => Integer[1],
  'in_puppet_conf' => Boolean,
}]


