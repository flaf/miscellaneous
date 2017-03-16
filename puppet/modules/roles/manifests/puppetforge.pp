class roles::puppetforge {

  # This present role include the role "generic".
  include '::roles::generic'

  # Parameters from these classes are needed.
  include '::puppetagent::params'
  include '::network::params'

  $http_proxy = ::network::get_param(
                  $::network::params::interfaces,
                  $::network::params::inventory_networks,
                  'http_proxy'
                )

  case $http_proxy {
    Undef: {
      $http_proxy_value  = undef
      $https_proxy_value = undef
    }
    default: {
      $proxy_address     = $http_proxy['address']
      $proxy_port        = $http_proxy['port']
      $http_proxy_value  = "http://${proxy_address}:${proxy_port}"
      $https_proxy_value = "http://${proxy_address}:${proxy_port}"
    }
  }

  class { '::puppetforge::params':
    puppet_bin_dir => $::puppetagent::params::bindir,
    http_proxy     => $http_proxy_value,
    https_proxy    => $https_proxy_value,
  }

  include '::puppetforge'

}


