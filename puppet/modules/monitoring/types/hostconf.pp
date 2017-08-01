type Monitoring::HostConf = Struct[{
  'host_name'                  => Monitoring::Hostname,
  'address'                    => String[1],
  'templates'                  => Array[Monitoring::Template, 1],
  Optional['custom_variables'] => Array[Monitoring::CustomVariable],
  Optional['extra_info']       => Array[Monitoring::ExtraInfo],
  Optional['monitored']        => Boolean,
}]


