function mcomiddleware::data {

  $default_exchanges = $::datacenters ? {
    Array[String[1],1] => (['mcollective'] + $::datacenters).unique.sort,
    default            => ['mcollective'],
  }

  $supported_distribs = ['trusty', 'jessie']
  $sp                 = 'supported_distributions';

  {
    mcomiddleware::params::stomp_ssl_ip    => '0.0.0.0',
    mcomiddleware::params::stomp_ssl_port  => 61614,
    mcomiddleware::params::ssl_versions    => [ 'tlsv1.2', 'tlsv1.1' ],
    mcomiddleware::params::puppet_ssl_dir  => undef,
    mcomiddleware::params::admin_pwd       => undef,
    mcomiddleware::params::mcollective_pwd => undef,
    mcomiddleware::params::exchanges       => $default_exchanges,
   "mcomiddleware::params::${sp}"          => $supported_distribs,

    # Merging policy.
    lookup_options => {
      mcomiddleware::params::exchanges => { merge => 'unique', },
    },
  }

}


