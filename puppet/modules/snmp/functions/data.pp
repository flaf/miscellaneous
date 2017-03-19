function snmp::data {

  $interface       = $::facts['networking']['ip']
  $port            = 161
  $views           = { 'monitoring' => [ '.1.3.6.1.2.1', '.1.3.6.1.4.1' ] }
  $syscontact      = "admin@${::domain}"
  $snmpv3_accounts = {}
  $communities     = {}

  $syslocation = $::datacenter ? {
    undef   => $::domain,
    default => $::datacenter,
  }

  $sd                      = 'supported_distributions'
  $supported_distributions = [
                              'trusty',
                              'xenial',
                              'jessie',
                             ];

  {
    snmp::params::interface       => $interface,
    snmp::params::port            => $port,
    snmp::params::syslocation     => $syslocation,
    snmp::params::syscontact      => $syscontact,
    snmp::params::snmpv3_accounts => $snmpv3_accounts,
    snmp::params::communities     => $communities,
    snmp::params::views           => $views,
   "snmp::params::${sd}"          => $supported_distributions,

    # Merging policy.
    lookup_options => {
      snmp::params::snmpv3_accounts => { merge => 'deep', },
      snmp::params::communities     => { merge => 'deep', },
      snmp::params::views           => { merge => 'deep', },
    },
  }

}


