class snmp::params (
  String[1]                              $interface,
  Integer[1]                             $port,
  String[1]                              $syslocation,
  String[1]                              $syscontact,
  Hash[ String[1], Snmp::Snmpv3account ] $snmpv3_accounts,
  Hash[ String[1], Snmp::Community ]     $communities,
  Hash[ String[1], Snmp::View, 1 ]       $views,
) {
}


