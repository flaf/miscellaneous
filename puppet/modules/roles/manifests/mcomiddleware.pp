class roles::mcomiddleware {

  include '::roles::mcomiddleware::params'
  $additional_exchanges = $::roles::mcomiddleware::params::additional_exchanges

  # This present role include the role "generic".
  include '::roles::generic'

  $exchanges = ( $::datacenters + $additional_exchanges ).unique

  # A parameter from this class is needed.
  include '::puppetagent::params'

  class { '::mcomiddleware::params':
    puppet_ssl_dir => $::puppetagent::params::ssldir,
    exchanges      => $exchanges,
  }

  include '::mcomiddleware'

}


