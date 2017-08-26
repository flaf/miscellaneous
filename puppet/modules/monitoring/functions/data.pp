function monitoring::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $fqdn = $::facts['networking']['fqdn']
  $ip   = $::facts['networking']['ip']

  $default_extra_info = {
    'check_dns' => {
      "DNS-${fqdn}" => {
        'fqdn'             => $fqdn,
        'expected-address' => '$HOSTADDRESS$',
      },
    },
  };

  {
    monitoring::host::params::host_name        => $fqdn,
    monitoring::host::params::address          => $ip,
    monitoring::host::params::templates        => ['linux_tpl*'],
    monitoring::host::params::custom_variables => [],
    monitoring::host::params::extra_info       => $default_extra_info,
    monitoring::host::params::ipmi_template    => undef,
    monitoring::host::params::monitored        => true,

    monitoring::server::params::additional_checkpoints => [],
    monitoring::server::params::additional_blacklist   => [],
    monitoring::server::params::filter_tags            => [],

    # Merging policy.
    lookup_options => {
      monitoring::host::params::templates        => {merge => 'unique'},
      monitoring::host::params::custom_variables => {merge => 'unique'},
      monitoring::host::params::extra_info       => {merge => 'deep'},

      monitoring::server::params::additional_checkpoints => {merge => 'unique'},
      monitoring::server::params::additional_blacklist   => {merge => 'unique'},
    },

  }

}


