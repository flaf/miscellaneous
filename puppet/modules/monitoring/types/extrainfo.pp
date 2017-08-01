type Monitoring::ExtraInfo = Struct[{
  Optional['ipmi_address'] => String[1],
  Optional['blacklist']    => Monitoring::Blacklist,
}]


