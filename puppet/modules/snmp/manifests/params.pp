class snmp::params (
  String[1]                                        $interface,
  Integer[1]                                       $port,
  String[1]                                        $syslocation,
  String[1]                                        $syscontact,
  Hash[ String[1], Hash[String[1], String[1], 3] ] $snmpv3_accounts,
  Hash[ String[1], Hash[String[1], Data, 2, 2] ]   $communities,
  Hash[ String[1], Array[String[1], 1], 1 ]        $views,
) {
}


