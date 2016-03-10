function snmp::data {

  if !defined(Class['::network::params']) { include '::network::params' }
  $inventory_networks = $::network::params::inventory_networks
  $interfaces         = $::network::params::interfaces

  $interface       = $::facts['networking']['ip']
  $port            = 161
  $views           = { 'monitoring' => [ '.1.3.6.1.2.1', '.1.3.6.1.4.1' ] }
  $snmpv3_accounts = {}
  $communities     = {}

  $syslocation = $::datacenter ? {
    undef   => $::domain,
    default => $::datacenter,
  }

  $syscontact = ::network::get_param($interfaces, $inventory_networks,
                                     'admin_email', "admin@${::domain}");

  {
    snmp::params::interface       => $interface,
    snmp::params::port            => $port,
    snmp::params::syslocation     => $syslocation,
    snmp::params::syscontact      => $syscontact,
    snmp::params::snmpv3_accounts => $snmpv3_accounts,
    snmp::params::communities     => $communities,
    snmp::params::views           => $views,

    snmp::supported_distributions => ['trusty', 'jessie'],

    # Merging policy.
    lookup_options => {
      snmp::params::snmpv3_accounts => { merge => 'hash', },
      snmp::params::communities     => { merge => 'hash', },
      snmp::params::views           => { merge => 'hash', },
    },
  }

}


