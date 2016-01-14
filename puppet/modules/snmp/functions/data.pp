function snmp::data {

  include '::network::params'
  $inventory_networks = $::network::params::inventory_networks
  $interfaces         = $::network::params::interfaces
  $conf               = lookup('snmp', Hash[String[1], Data, 1], 'hash', {})

  $interface = $conf['interface'] ? {
    undef   => '',
    default => $conf['interface'],
  }

  $port = $conf['port'] ? {
    undef   => 161,
    default => $conf['port'],
  }

  $syslocation = $conf['syslocation'] ? {
    undef   => $::datacenter ? { undef => $::domain, default => $::datacenter },
    default => $conf['syslocation'],
  }

  # TODO: currently a puppet bug https://tickets.puppetlabs.com/browse/PUP-5209
  #$syscontact = ::network::get_param($interfaces, $inventory_networks,
  #                                   'admin_email', "admin@${::domain}")
  $syscontact = "admin@${::domain}"

  $snmpv3_accounts = $conf['snmpv3_accounts'] ? {
    undef   => [],
    default => $conf['snmpv3_accounts'],
  }

  $communities = $conf['communities'] ? {
    undef   => [],
    default => $conf['communities'],
  }

  $views = $conf['views'] ? {
    undef   => { 'monitoring' => [ '.1.3.6.1.2.1', '.1.3.6.1.4.1' ] },
    default => $conf['views'],
  };

  {
    snmp::params::interface       => $interface,
    snmp::params::port            => $port,
    snmp::params::syslocation     => $syslocation,
    snmp::params::syscontact      => $syscontact,
    snmp::params::snmpv3_accounts => $snmpv3_accounts,
    snmp::params::communities     => $communities,
    snmp::params::views           => $views,

    snmp::supported_distributions => ['trusty', 'jessie'],
  }

}


