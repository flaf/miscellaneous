class roles::generic (
  Array[String[1]] $authorized_classes = [
    '::unix_accounts',
    '::repository::aptkey::params',
    '::repository::aptconf',
    '::network',
    '::network::hosts',
    '::network::resolv_conf',
    '::basic_ntp',
    '::raid',
    '::basic_ssh::server',
    '::basic_ssh::client',
    '::basic_packages',
    '::keyboard',
    '::locale',
    '::timezone',
    '::wget',
    '::puppetagent',
    '::mcollective::server',
    '::snmp',
  ],
  Array[String[1]] $included_classes = $authorized_classes,
  Array[String[1]] $excluded_classes = [],
) {

  # Checks concerning the ENC variables $::datacenter and
  # $::datacenters.
  unless $::datacenter =~ String[1] {
    @("END"/L$).fail
      ${title}: sorry you must define the ENC variable \
      \$::datacenter as a non-empty string.
      |- END
  }

  unless $::datacenters =~ Array[String[1], 1] {
    @("END"/L$).fail
      ${title}: sorry you must define the ENC variable \
      \$::datacenters as a non-empty array of non-empty \
      strings.
      |- END
  }

  unless $::datacenter in $::datacenters {
    @("END"/L$).fail
      ${title}: sorry the ENC variable \$::datacenter must \
      be a member of the array \$::datacenters.
      |- END
  }

  # All classes in $excluded_classes must belong to the
  # $authorized_classes array. The goal is to avoid a case
  # where the user wants to exclude a class but he makes a
  # misprint in its name and the real class is not excluded.
  $excluded_classes.each |$a_class| {
    unless $a_class in $authorized_classes {
      @("END"/L).fail
        ${title}: you want to exclude the class `${a_class}` from the \
        module `${title}` but this class does not belong to the list of \
        classes authorized by this module. Are you sure you have not made \
        a misprint?
        |- END
    }
  }

  # We check that all classes in $included_classes are in
  # $authorized_classes.
  $included_classes.each |$a_class| {
    unless $a_class in $authorized_classes {
      @("END"/L).fail
        ${title}: you want to include the class `${a_class}` from the \
        module `${title}` but this class does not belong to the list of \
        classes authorized by this module. Are you sure you have not made \
        a misprint?
        |- END
    }
  }

  $remaining_classes = $included_classes - $excluded_classes

  $remaining_classes.each |String[1] $a_class| {

    case $a_class {


      #####################
      ### unix_accounts ###
      #####################
      '::unix_accounts': {

        # We want to manage root at first.
        class { '::unix_accounts::params':
          rootstage => 'basis',
        }

        include '::unix_accounts'

      }


      ###########################
      ### repository::aptconf ###
      ###########################
      '::repository::aptconf': {

        include '::network::params'
        $apt_proxy = ::network::get_param(
                       $::network::params::interfaces,
                       $::network::params::inventory_networks,
                       'apt_proxy'
                     )

        case $apt_proxy {
          Undef: {
            $apt_proxy_value = undef
          }
          default: {
            $proxy_address   = $apt_proxy['address']
            $proxy_port      = $apt_proxy['port']
            $apt_proxy_value = "http://${proxy_address}:${proxy_port}"
          }
        }

        class { '::repository::aptconf::params':
          apt_proxy => $apt_proxy_value,
        }
        class { '::repository::aptconf':
          stage => 'repository',
        }

      }


      ##################################
      ### repository::aptkey::params ###
      ##################################
      '::repository::aptkey::params': {

        include '::network::params'
        $pgp_keyserver = ::network::get_param(
                           $::network::params::interfaces,
                           $::network::params::inventory_networks,
                           'pgp_keyserver'
                         )
        $http_proxy    = ::network::get_param(
                           $::network::params::interfaces,
                           $::network::params::inventory_networks,
                           'http_proxy'
                         )

        case $pgp_keyserver {
          Undef: {
            $keyserver_value   = undef
          }
          default: {
            $keyserver_address = $pgp_keyserver['address']
            $keyserver_port    = $pgp_keyserver['port']
            $keyserver_value   = "hkp://${keyserver_address}:${keyserver_port}"
          }
        }

        case [$http_proxy, $pgp_keyserver.dig('proxy_required')] {
          [NotUndef, false]: {
            $http_proxy_value = undef
          }
          [NotUndef, true]: {
            $proxy_address    = $http_proxy['address']
            $proxy_port       = $http_proxy['port']
            $http_proxy_value = "http://${proxy_address}:${proxy_port}"
          }
          [default, default]: {
            $http_proxy_value = undef
          }
        }

        class { '::repository::aptkey::params':
          http_proxy => $http_proxy_value,
          keyserver  => $keyserver_value,
        }

      }


      ############
      ### wget ###
      ############
      '::wget': {

        $http_proxy = ::network::get_param(
                        $::network::params::interfaces,
                        $::network::params::inventory_networks,
                        'http_proxy',
                      )

        case $http_proxy {
          Undef: {
            $http_proxy_value = undef
          }
          default: {
            $proxy_address    = $http_proxy['address']
            $proxy_port       = $http_proxy['port']
            $http_proxy_value = "http://${proxy_address}:${proxy_port}"
          }
        }

        class { '::wget::params':
          http_proxy  => $http_proxy_value,
          https_proxy => $http_proxy_value,
        }

        include '::wget'

      }


      ################################
      ### network _and_ network::* ###
      ################################
      /^::network(::.*)?$/: {

        class { "${a_class}":
          stage => 'network',
        }

      }


      #################
      ### basic_ntp ###
      #################
      '::basic_ntp': {

        include '::network::params'
        $ntp_servers = ::network::get_param(
                         $::network::params::interfaces,
                         $::network::params::inventory_networks,
                         'ntp_servers'
                       )

        if $ntp_servers =~ Undef {
          @("END"/L).fail
            $title: sorry impossible to find the (needed) data 'ntp_servers' \
            in the inventory networks for this host.
            |- END
        }

        # For this class, we have retrieved NTP servers from
        # inventory networks.
        class { '::basic_ntp::params':
          servers => $ntp_servers,
        }

        include '::basic_ntp'

      }


      ############
      ### snmp ###
      ############
      '::snmp': {

        include '::network::params'
        $snmp_syscontact = ::network::get_param(
                             $::network::params::interfaces,
                             $::network::params::inventory_networks,
                             'admin_email'
                           )

        if $snmp_syscontact =~ Undef {
          @("END"/L).fail
            $title: sorry impossible to find the (needed) data 'admin_email' \
            in the inventory networks for this host.
            |- END
        }

        # With SNMP, we want to install the snmpd-extend package.
        include '::repository::shinken'

        [ 'snmpd-extend' ].ensure_packages({
          ensure  => present,
          require => Class['::repository::shinken'],
          # To manage the snmp service after the
          # installation of snmpd-extend.
          before  => Class['::snmp'],
        })

        class { '::snmp::params':
          syscontact => $snmp_syscontact,
        }

        include '::snmp'

      }


      ###################
      ### puppetagent ###
      ###################
      '::puppetagent': {

        include '::repository::puppet'

        class { '::puppetagent':
          require => Class['::repository::puppet'],
        }

      }


      ###########################
      ### mcollective::server ###
      ###########################
      '::mcollective::server': {

        include '::mcomiddleware::params'
        include '::puppetagent::params'

        include '::repository::puppet'
        include '::repository::mco'

        class { '::mcollective::server::params':
          middleware_port => $::mcomiddleware::params::stomp_ssl_port,
          mcollective_pwd => $::mcomiddleware::params::mcollective_pwd,
          puppet_ssl_dir  => $::puppetagent::params::ssldir,
          puppet_bin_dir  => $::puppetagent::params::bindir,
          mco_plugins     => [ 'mcollective-flaf-agents' ],
        }

        class { '::mcollective::server':
          require => [ Class['::repository::mco'],
                       Class['::repository::puppet'],
                     ],
        }

        $::mcollective::server::params::collectives.each |$a_collective| {
          unless $a_collective in $::mcomiddleware::params::exchanges {
            @("END"/L$).fail
              ${title}: sorry, `${a_collective}` is a value of the \
              `collectives` parameter of the MCollective service but \
              the only collectives currently authorized are \
              ${::mcomiddleware::params::exchanges} ie \
              all the exchanges defined in the middleware server.
              |- END
          }
        }

      }


      ########################
      ### The default case ###
      ########################
      default: {
        # By default, it's a simple include.
        include "${a_class}"
      }


    }

  }

}


