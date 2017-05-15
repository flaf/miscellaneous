class roles::httpproxy {

  include '::roles::generic'
  include '::network::params'

  $interfaces         = $::network::params::interfaces
  $inventory_networks = $::network::params::inventory_networks
  $admin_email        = ::network::get_param($interfaces, $inventory_networks, 'admin_email')

  unless $admin_email =~ NotUndef {
    @("END"/L$).fail
      ${title}: sorry the variable \$admin_email is undefined.
      |- END
  }

  # We take all CIDR of the current datacenter.
  $squid_allowed_networks = $::network::params::inventory_networks.filter |$entry| {
    $settings = $entry[1];
    $::datacenter in $settings['datacenters']
  }.reduce([]) |$memo, $entry| {
    $memo + [$entry[1]['cidr']]
  }.unique

  class { '::httpproxy::params':
    enable_puppetforgeapi  => true,
    squid_allowed_networks => $squid_allowed_networks,
    squidguard_admin_email => $admin_email,
  }

  include '::httpproxy'

}


