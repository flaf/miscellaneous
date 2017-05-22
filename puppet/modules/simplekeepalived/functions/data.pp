function simplekeepalived::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $supported_distributions = [
                               'xenial',
                             ];

  {
    simplekeepalived::params::virtual_router_id       => undef,
    simplekeepalived::params::interface               => $::facts['networking']['primary'],
    simplekeepalived::params::priority                => 100,
    simplekeepalived::params::nopreempt               => true,
    simplekeepalived::params::auth_pass               => undef,
    simplekeepalived::params::virtual_ipaddress       => undef,
    simplekeepalived::params::track_script            => undef,
    simplekeepalived::params::supported_distributions => $supported_distributions,
  }

}


