class snmp::params (
  String                                                        $interface,
  Variant[Integer[1], String[1]]                                $port,
  String[1]                                                     $syslocation,
  String[1]                                                     $syscontact,
  Hash[String[1], Hash[String[1], String[1], 5, 5]]             $snmpv3_accounts,
  Hash[String[1], Array[ Hash[ String[1], String[2], 2, 2], 1]] $communities,
  Hash[String[1], Array[String[1]]]                             $views,
) {
}


