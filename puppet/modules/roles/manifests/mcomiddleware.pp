class roles::mcomiddleware {

  # This present role include the role "generic".
  include '::roles::generic'

  # A parameter from this class is needed.
  include '::puppetagent::params'

  class { '::mcomiddleware::params':
    puppet_ssl_dir => $::puppetagent::params::ssldir,
    exchanges      =>, # TODO: with $::datacenters
  }

  include '::mcomiddleware'

}


