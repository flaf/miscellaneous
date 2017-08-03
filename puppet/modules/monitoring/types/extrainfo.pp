type Monitoring::ExtraInfo = Struct[{
  Optional['ipmi_address'] => String[1],
  Optional['blacklist']    => Monitoring::Blacklist,
  Optional['check_dns']    => Hash[
                                Pattern[/^[a-z][-a-z0-9]+$/],
                                Struct[{
                                  'fqdn'                       => String[1],
                                  Optional['server']           => String[1],
                                  Optional['expected-address'] => String[1],
                                  Optional['options']          => String[1],
                                }],
                              ],
}]


