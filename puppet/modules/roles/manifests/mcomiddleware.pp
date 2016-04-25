class roles::mcomiddleware {

  include '::roles::mcomiddleware::params'
  include '::puppetagent::params'

  # This is a resource-like declaration, so it must be the first.
  class { '::mcomiddleware::params':
    puppet_ssl_dir => $::puppetagent::params::ssldir,
    exchanges      => $::roles::mcomiddleware::params::exchanges,
  }

  # This present role include the role "generic".
  include '::roles::generic'

  include '::mcomiddleware'

}


