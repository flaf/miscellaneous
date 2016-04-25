class roles::mcomiddleware {

  include '::roles::mcomiddleware::params'
  include '::puppetagent::params'

  # This present role include the role "generic".
  include '::roles::generic'

  class { '::mcomiddleware::params':
    puppet_ssl_dir => $::puppetagent::params::ssldir,
    exchanges      => $::roles::mcomiddleware::params::exchanges,
  }

  include '::mcomiddleware'

}


