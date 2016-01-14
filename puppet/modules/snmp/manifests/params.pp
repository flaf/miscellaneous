class snmp::params (
  String                               $interface,
  Variant[Integer[1], String[1]]       $port,
  String[1]                            $syslocation,
  String[1]                            $syscontact,
  Array[Hash[String[1], String[1], 3]] $snmpv3_accounts,
  Array[Hash[String[1], Data, 2, 2]]   $communities,
  Hash[String[1], Array[String[1]]]    $views,
) {
}


