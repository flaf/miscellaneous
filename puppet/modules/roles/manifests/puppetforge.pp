class roles::puppetforge {

  # This present role include the role "generic".
  include '::roles::generic'

  # A parameter from this class is needed.
  include '::puppetagent::params'

  class { '::puppetforge::params':
    puppet_bin_dir => $::puppetagent::params::bindir,
  }


}


