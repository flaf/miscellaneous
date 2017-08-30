class roles::mysqlnode {

  # This present role include the role "generic".
  include '::roles::generic'

  include '::wrapper_mysql'

  # (i) No longer the case. Now, the VIP is checked via SNMP directly.
  #
  # We want to be able to monitor if the VIP(s) is (are) present.
  #$default_cron_check_cmd = ::keepalived_vip::data()['keepalived_vip::params::cron_check_cmd']
  #$cron_check_cmd         = ::roles::wrap_cron_mon('check-vip', $default_cron_check_cmd)

  class { '::keepalived_vip::params':
    # (i) No longer the case. Now, the VIP is checked via SNMP directly.
    #cron_check_vip => ::roles::is_number_one(),
    #cron_check_cmd => $cron_check_cmd,
    before         => Class['::keepalived_vip'],
  }

  include '::keepalived_vip'


  # Add the checkpoint.
  $hostname      = $::facts['networking']['hostname']
  $regex_eleapoc = Regexp.new('-eleapoc$')

  if $hostname =~ $regex_eleapoc {
    return()
  }

  $custom_variables = if ::roles::is_number_one() {
    # In this role, we assume that the first mysql server
    # must has the VIP. We take the first VIP only (and we
    # hope the only VIP).
    $vrrp_instances       = $::keepalived_vip::params::vrrp_instances
    $first_vrrp_instance  = $vrrp_instances.keys.dig(0)
    $vip                  = $vrrp_instances
                              .dig($first_vrrp_instance, 'virtual_ipaddress', 0)
                              .lest || {
      @("END"/L$).fail
        ${title}: sorry, no VIP address has been found in the module \
        `keepalived_vip` and it is required in this role.
        |- END
    };
    [
      {'varname' => '_has_ip', 'value' => {'virtual-ip' => [$vip]}},
    ]
  } else {
    []
  } + [
    'varname' => '_present_processes',
    'value'   => {'processes-mysql' => ['mysqld mysqld_safe']},
  ]

  monitoring::host::checkpoint {"${fqdn} from ${title}":
    templates        => ['linux_tpl', 'mysql-repl_tpl'],
    custom_variables => $custom_variables,
  }

  # In this role, it will be moosql01 which define the
  # checkpoint for the VIP host.
  if $hostname == 'moosql01' {

    $domain   = $::facts['networking']['domain']
    $vip_fqdn = "moosql-vip.${domain}"

    monitoring::host::checkpoint {"${vip_fqdn} from ${title}":
      host_name        => $vip_fqdn,
      address          => $vip,
      templates        => ['generic-host_tpl*', 'dns_tpl'],
      monitored        => true,
      custom_variables => [
        {
          'varname' => '_resolvconf_dns_lookups',
          'value'   => {"DNS-${vip_fqdn}" => [$vip_fqdn, "-a ${vip}"]},
        },
      ],
    }

  }

}


