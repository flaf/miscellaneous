function monitoring::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  {
    monitoring::host::params::host_name        => $::facts['networking']['hostname'],
    monitoring::host::params::address          => $::facts['networking']['ip'],
    monitoring::host::params::templates        => ['linux_tpl'],
    monitoring::host::params::custom_variables => [],
    monitoring::host::params::extra_info       => [],
    monitoring::host::params::monitored        => true,

    monitoring::server::params::additional_hosts     => [],
    monitoring::server::params::additional_blacklist => [],
    monitoring::server::params::filter_tags          => [],
  }

}


