type Monitoring::ExtraInfo = Struct[{
  Optional['ipmi_address'] => Monitoring::Address,
  Optional['blacklist']    => Monitoring::Blacklist,
  Optional['check_dns']    => Monitoring::CheckDns,
}]


