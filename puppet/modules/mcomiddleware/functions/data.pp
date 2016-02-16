function mcomiddleware::data {

  if !defined(Class['::puppetagent::params']) { include '::puppetagent::params' }
  $puppet_ssl_dir     = $::puppetagent::params::ssldir
  $supported_distribs = ['trusty', 'jessie'];

  {
    mcomiddleware::params::stomp_ssl_ip    => '0.0.0.0',
    mcomiddleware::params::stomp_ssl_port  => 61614,
    mcomiddleware::params::ssl_versions    => [ 'tlsv1.2', 'tlsv1.1' ],
    mcomiddleware::params::puppet_ssl_dir  => $puppet_ssl_dir,
    mcomiddleware::params::admin_pwd       => 'NOT-DEFINED',
    mcomiddleware::params::mcollective_pwd => 'NOT-DEFINED',
    mcomiddleware::params::exchanges       => [ 'mcollective' ],

    mcomiddleware::supported_distributions => $supported_distribs,
  }

}


