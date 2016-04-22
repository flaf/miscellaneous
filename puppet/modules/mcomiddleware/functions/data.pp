function mcomiddleware::data {

  $supported_distribs = ['trusty', 'jessie']
  $sp                 = 'supported_distributions';

  {
    mcomiddleware::params::stomp_ssl_ip    => '0.0.0.0',
    mcomiddleware::params::stomp_ssl_port  => 61614,
    mcomiddleware::params::ssl_versions    => [ 'tlsv1.2', 'tlsv1.1' ],
    mcomiddleware::params::puppet_ssl_dir  => undef,
    mcomiddleware::params::admin_pwd       => undef,
    mcomiddleware::params::mcollective_pwd => undef,
    mcomiddleware::params::exchanges       => [ 'mcollective' ],
   "mcomiddleware::params::${sp}"          => $supported_distribs,
  }

}


