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

  # Add a checkpoint.

  $puppetforge_port             = $::puppetforge::params::port
  $fqdn                         = $::facts['networking']['fqdn']
  $puppetforge_checkpoint_title = "${fqdn} from ${title}"

  $custom_variables = [
    {
      'varname' => '_present_processes',
      'value'   => {'process-update-pp-module' => ['update-pp-modul']},
      'comment' => [
                     'The daemon which updates Puppet modules must be UP.',
                     'Warning, its name is truncated.',
                   ],
    },
    {
      'varname' => '_http_pages',
      'value'   => {
        'http-puppetforge' => ["${fqdn}:${puppetforge_port}", 'Welcome to your Internal Puppet Forge'],
      },
    },
  ]

  monitoring::host::checkpoint {$puppetforge_checkpoint_title:
    templates        => ['linux_tpl', 'http_tpl'],
    custom_variables => $custom_variables,
  }

}


