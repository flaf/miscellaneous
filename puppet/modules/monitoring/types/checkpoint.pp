type Monitoring::CheckPoint = Struct[{
  'host_name'                  => Monitoring::Hostname,
  Optional['address']          => Monitoring::Address,
  Optional['templates']        => Array[Monitoring::Template],
  Optional['custom_variables'] => Array[Monitoring::CustomVariable],
  Optional['extra_info']       => Monitoring::ExtraInfo,
  Optional['monitored']        => Boolean,
}]


