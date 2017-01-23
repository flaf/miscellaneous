class roles::mcomiddleware {

  include '::puppetagent::params'

  # This class must be declared via a resource-like
  # declaration before the class roles::generic which makes
  # an include of mcomiddleware::params.
  class { '::mcomiddleware::params':
    puppet_ssl_dir => $::puppetagent::params::ssldir,
  }

  # This present role include the role "generic".
  include '::roles::generic'

  include '::mcomiddleware'

}


