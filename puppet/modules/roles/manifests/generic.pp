class roles::generic {

  include '::roles::generic::params'

  $supported_classes = $::roles::generic::params::supported_classes
  $excluded_classes  = $::roles::generic::params::excluded_classes
  $included_classes  = $::roles::generic::params::included_classes

  # All classes in $excluded_classes must belong to the
  # $supported_classes array. The goal is to avoid a case
  # where the user wants to exclude a class but he makes a
  # misprint in its name and the real class is not excluded.
  $excluded_classes.each |$a_class| {
    unless $a_class in $supported_classes {
      @("END"/L).fail
        ${title}: you want to exclude the class `${a_class}` from the \
        module `${title}` but this class does not belong to the list of \
        classes supported by this module. Are you sure you have not made \
        a misprint?
        |- END
    }
  }

  # We check that all classes in $included_classes are in
  # $supported_classes.
  $included_classes.each |$a_class| {
    unless $a_class in $supported_classes {
      @("END"/L).fail
        ${title}: you want to include the class `${a_class}` from the \
        module `${title}` but this class does not belong to the list of \
        classes supported by this module. Are you sure you have not made \
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

        # We wabt to manage root at first.
        class { '::unix_accounts::params':
          rootstage => 'basis',
        }

        include '::unix_accounts'

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


