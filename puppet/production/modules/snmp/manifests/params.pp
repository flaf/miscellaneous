class snmp::params {

  $snmp = hiera_hash('snmp')

  $secname           = generate_password($snmp['secname'])
  $authpass          = generate_password($snmp['authpass'])
  $authproto         = $snmp['authproto']
  $privpass          = generate_password($snmp['privpass'])
  $privproto         = $snmp['privproto']

  $community         = $snmp['community']

  $secview           = $snmp['secview']
  $views             = $snmp['views']
  $sources           = $snmp['sources']

}


