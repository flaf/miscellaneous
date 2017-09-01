class roles::httpproxy {

  include '::roles::generic'
  include '::network::params'

  $interfaces            = $::network::params::interfaces
  $inventory_networks    = $::network::params::inventory_networks
  $admin_email           = ::network::get_param($interfaces, $inventory_networks, 'admin_email')
  $http_proxy_netconf    = ::network::get_param($interfaces, $inventory_networks, 'http_proxy')
  $apt_proxy_netconf     = ::network::get_param($interfaces, $inventory_networks, 'apt_proxy')
  $pgp_keyserver_netconf = ::network::get_param($interfaces, $inventory_networks, 'pgp_keyserver');

  {
   '$admin_email'           => $admin_email,
   '$http_proxy_netconf'    => $http_proxy_netconf,
   '$apt_proxy_netconf'     => $apt_proxy_netconf,
   '$pgp_keyserver_netconf' => $pgp_keyserver_netconf,
  }.each |$name, $value| {
    if $value =~ Undef {
      @("END"/L$).fail
        ${title}: sorry the variable `${name}` is undefined but it \
        must be defined for this role.
        |- END
    }
  }

  # We take all CIDR of the current datacenter.
  $squid_allowed_networks = $::network::params::inventory_networks.filter |$entry| {
    $settings = $entry[1];
    $::datacenter in $settings['datacenters']
  }.reduce([]) |$memo, $entry| {
    $memo + [$entry[1]['cidr_address']]
  }.unique

  $apt_proxy_port  = $apt_proxy_netconf['port']
  $keyserver_fqdn  = $pgp_keyserver_netconf['address']
  $http_proxy_port = $http_proxy_netconf['port']

  class { '::httpproxy::params':
    enable_apt_cacher_ng   => true,
    apt_cacher_ng_port     => $apt_proxy_port,
    enable_keyserver       => true,
    keyserver_fqdn         => $keyserver_fqdn,
    enable_squidguard      => true,
    squid_allowed_networks => $squid_allowed_networks,
    squid_port             => $http_proxy_port,
    squidguard_admin_email => $admin_email,
  }

  include '::httpproxy'

  class {'::simplekeepalived::params':
    # The important service to check is "squid".
    track_script => { 'script' => 'pkill -0 squid' },
  }

  include '::simplekeepalived'

  # Add a checkpoint.

  $fqdn = $::facts['networking']['fqdn']

  if $::httpproxy::params::pgp_pubkeys.empty {
    @("END"/L$).fail
      ${title}: sorry the parameter `\$::httpproxy::params::pgp_pubkeys` \
      is empty which is not allowed for this role.
      |- END
  }

  $regex_mask                 = Regexp.new('/[0-9]+$')
  $fqdn_vip                   = $http_proxy_netconf['address']
  $apt_proxy_fqdn             = $apt_proxy_netconf['address']
  # If there are multiple VIP, we take only the first VIP.
  $address_vip_with_mask      = $::simplekeepalived::params::virtual_ipaddress[0]['address']
  $address_vip                = $address_vip_with_mask.regsubst($regex_mask, '')
  $httpproxy_checkpoint_title = "${fqdn_vip} from ${title}"
  $a_pubkey_id                = $::httpproxy::params::pgp_pubkeys[0]['id']

  $http_monitoring_value = {
    'google-via-squidproxy' => [
      "${fqdn_vip}:${http_proxy_port} uri->http://www.google.fr",
      'Recherche Google',
    ],
    'duckduckgo-via-squidproxy' => [
      "${fqdn_vip}:${http_proxy_port} uri->http://duckduckgo.com",
      'Sorry this page is not allowed for you',
    ],
    'apt-cacher-ng' => [
      "${apt_proxy_fqdn}:${apt_proxy_port} uri->http://ftp.fr.debian.org/debian/dists/stable/main/binary-amd64/Release",
      'Architecture: amd64',
    ],
    'keyserver' => [
      "${keyserver_fqdn}/pks/lookup?op=get&search=${a_pubkey_id}",
      'BEGIN PGP PUBLIC KEY BLOCK',
    ],
  }.with |$value| {
    if $::httpproxy::params::enable_puppetforgeapi {
      $puppetforge_fqdn = $::httpproxy::params::puppetforgeapi_fqdn
      $value + {
        'puppetforgeapi-proxy' => [
          "${puppetforge_fqdn}/v3/users/puppetlabs",
          'puppetlabs',
          '--warning 15 --critical 18',
        ]
      }
    } else {
      $value
    }
  }

  $custom_variables = [
    {
      'varname' => '_http_pages',
      'value'   => $http_monitoring_value,
    },
  ]

  if $fqdn_vip == $fqdn {
    @("END"/L$).fail
      ${title}: the external fqdn of this httpproxy server is equal to \
      its "local" fqdn which is not allowed for this role.
      |- END
  }

  # This is the node number 1 which will define the
  # checkpoint of the VIP host.
  if ::roles::is_number_one() {
    monitoring::host::checkpoint {$httpproxy_checkpoint_title:
      host_name        => $fqdn_vip,
      address          => $address_vip,
      templates        => ['generic-host_tpl*', 'http_tpl'],
      custom_variables => $custom_variables,
      monitored        => true,
    }
  }

  # The "per-node" checkpoint.

  $custom_vars = [
    {
      'varname' => '_present_processes',
      'value'   => {
        'processes-proxy' => ['squid squidGuard apt-cacher-ng nginx'],
      },
    },
  ].with |$cm| {
    $nopreempt = $::simplekeepalived::params::nopreempt
    $priority  = $::simplekeepalived::params::priority
    if $nopreempt == false and $priority > 100 {
      # In this case, we add a check concerning the VIP.
      $cm + [
        {
          'varname' => '_has_ip',
          'value' => {
            'virtual-ip' => [$address_vip],
          },
        }
      ]
    } else {
      # In this case, the host can have the VIP or not. If
      # it doesn't, after a reboot the process "squidGuard"
      # is not present while the host is not requested via
      # the squid port. So we add a check to the host to
      # just ensure that the "squidGuard" process is UP.
      $cm + [
        {
          'varname' => '_http_pages',
          'value'   => {
            'duckduckgo-via-squidproxy' => [
              "${fqdn}:${http_proxy_port} uri->http://duckduckgo.com",
              'Sorry this page is not allowed for you',
            ],
          },
          'comment' => [
            'This host has probably not the VIP, so we have',
            'to check squidGuard because the process is not UP',
            'after a reboot while the host is not requested.',
          ],
        },
      ]
    }
  }

  # Don't forget to add the "http_tpl" template if needed.
  $http_tpl_not_required = $custom_vars.filter |$a_var| {
    '_http_pages' == $a_var['varname']
  }.empty

  $templates = if $http_tpl_not_required {
    ['linux_tpl']
  } else {
    ['linux_tpl', 'http_tpl']
  }

  monitoring::host::checkpoint {"${fqdn} from ${title}":
    templates        => $templates,
    custom_variables => $custom_vars,
  }

}


