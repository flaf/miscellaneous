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
    '::autoupgrade',
    '::monitoring::host',
    '::confkeeper::provider',
  ],
  Array[String[1]] $included_classes = $authorized_classes,
  Array[String[1]] $excluded_classes = [],
  Boolean          $nullclient       = false,
  Struct[{
    Optional['confkeeper::provider::params::repositories'] => NotUndef[Data],
  }]               $classes_params   = {}
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
      ### raid ###
      ############
      '::raid': {

        include '::raid'

        # Warning: the class "raid" do nothing by default
        # unless the custom fact $raid_controllers is not
        # empty. So we add a checkpoint only if this fact is
        # not empty.
        unless $raid_controllers.empty {
          $raid_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| {
            "${fqdn} from ${title} for raid"
          }
          monitoring::host::checkpoint {$raid_checkpoint_title:
            templates => ['raid_tpl'],
          }
        }

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

        $puppetagent_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| {
          "${fqdn} from ${title} for puppetagent"
        }
        monitoring::host::checkpoint {$puppetagent_checkpoint_title:
          templates => ['puppet_tpl'],
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

        $mcoserver_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| {
          "${fqdn} from ${title} for mcollective::server"
        }
        monitoring::host::checkpoint {$mcoserver_checkpoint_title:
          templates        => ['linux_tpl'],
          custom_variables => [
            {
              'varname' => '_present_processes',
              'value'   => {'process-mcollectived' => ['mcollectived']},
              'comment' => ['The process "mcollectived" must be up.'],
            }
          ],
        }

      }


      ###################
      ### autoupgrade ###
      ###################
      '::autoupgrade': {

        # Modules puppetagent and autoupgrade will use the
        # same flag file to disable any puppet run.
        include '::puppetagent::params'

        $autoupgrade_cron_name = 'autoupgrade'

        class { '::autoupgrade::params':
          upgrade_wrapper    => ::roles::wrap_cron_mon($autoupgrade_cron_name),
          flag_no_puppet_run => $::puppetagent::params::flag_puppet_cron,
        }

        include '::autoupgrade'

        # Handle of the resource monitoring::host::checkpoint.
        if $::autoupgrade::params::apply {

          $autoupgrade_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| {
            "${fqdn} from ${title} for autoupgrade"
          }

          $autoupgrade_checkpoint_settings = with(
            $::autoupgrade::params::reboot,
            ::autoupgrade::get_final_hour(),
            $::autoupgrade::params::minute,
            $::autoupgrade::params::monthday,
            $::autoupgrade::params::month,
            $::autoupgrade::params::weekday,
          ) |$reboot, $hour, $minute, $monthday, $month, $weekday| {

            unless $monthday =~ Enum['absent', '*'] and $month =~ Enum['absent', '*'] {
              @("END"/L$).fail
                ${title}: sorry, the values of the parameters \$::autoupgrade::params::monthday \
                and \$::autoupgrade::params::month are `${monthday}` and `${month}` but only \
                the values `*` or `absent` are supported (yet) to define a relevant checkpoint \
                resource `${autoupgrade_checkpoint_title}`.
                |- END
            }

            $one_day  = String.new(60*24   + 50) # in minutes
            $one_week = String.new(60*24*7 + 50) # in minutes

            $h = case $weekday {
              Enum['absent', '*']: {
                {
                 'period'     => '1d',
                 'max-uptime' => $one_day,
                 'comment'    => "A reboot is scheduled: ${one_day} is 1 day and 50 minutes.",
                 'weekdays'   => '*',
                }
              }
              Variant[Integer[0,7], Enum['0','1','2','3','4','5','6','7']]: {
                # Warning: in blacklist, the "weekdays"
                # field uses iso weekdays where 0 is not
                # allowed.
                $int_weekday = Integer.new($weekday)
                $iso_weekday = if $int_weekday == 0 {7} else {$int_weekday};
                {
                 'period'     => '7d',
                 'max-uptime' => $one_week,
                 'comment'    => "A reboot is scheduled: ${one_week} is 1 week and 50 minutes.",
                 'weekdays'   => [$iso_weekday],
                }
              }
              default: {
                @("END"/L$).fail
                  ${title}: sorry, the value of the parameter \$::autoupgrade::params::weekday \
                  `${::autoupgrade::params::weekday}` is not supported (yet) to define a relevant \
                  checkpoint resource `${autoupgrade_checkpoint_title}`.
                  |- END
              }
            }

            $cron_var = {
              'varname' => '_crons',
              'value'   => {"cron-${autoupgrade_cron_name}" => [$autoupgrade_cron_name, $h['period']]},
              'comment' => ["Check of the automatic upgrade (${autoupgrade_cron_name})."],
            }

            $max_reboot_var = {
              'varname' => '_REBOOT_MAX_UPTIME',
              'value'   => $h['max-uptime'],
              'comment' => [$h['comment']],
            }

            if $reboot {
              $z_hour      = if $hour < 10 { "0${hour}" } else { "${hour}" }
              $z_minute    = if $minute < 10 { "0${minute}" } else { "${minute}" }
              $wd          = $h['weekdays'][0] # works if == '*'.
              $msg_reboot  = "A reboot is scheduled at ${z_hour}:${z_minute} weekday ${wd}."
              $msg_upgrade = "An upgrade is scheduled at ${z_hour}:${z_minute} weekday ${wd}."

              $custom_variables = [$cron_var, $max_reboot_var]
              $extra_info       = {
                'blacklist' => [
                  {
                    'comment'     => [$msg_reboot],
                    'contact'     => '.*',
                    'description' => '^reboot$',
                    'timeslots'   => "[${z_hour}h${z_minute};+00h30]",
                    'weekdays'    => $h['weekdays'],
                  },
                  {
                    'comment'     => [$msg_upgrade],
                    'contact'     => '.*',
                    'description' => '^uname$',
                    'timeslots'   => "[${z_hour}h${z_minute};+01h30]",
                    'weekdays'    => $h['weekdays'],
                  },
                ],
              }
            } else {
              $custom_variables = [$cron_var]
              $extra_info       = undef
            };

            {'custom_variables' => $custom_variables, 'extra_info' => $extra_info}

          } # End of the "with" block.

          monitoring::host::checkpoint {$autoupgrade_checkpoint_title:
            templates        => ['linux_tpl'],
            custom_variables => $autoupgrade_checkpoint_settings['custom_variables'],
            extra_info       => $autoupgrade_checkpoint_settings['extra_info'],
          }

        } # End of Handle of the resource monitoring::host::checkpoint.

      }


      ########################
      ### monitoring::host ###
      ########################
      '::monitoring::host': {

        # When the host has an IPMI address, we want to add
        # the template "ipmi-sensors_tpl".
        class { '::monitoring::host::params':
          ipmi_template => 'ipmi-sensors_tpl',
        }

        include '::monitoring::host'

      }


      ############################
      ### confkeeper::provider ###
      ############################
      '::confkeeper::provider': {

        $etckeeper_cron_name = 'etckeeper-push-all'

        class { '::confkeeper::provider::params':
          wrapper_cron => ::roles::wrap_cron_mon($etckeeper_cron_name),
          *            => $classes_params.::roles::reduce2prefix('confkeeper::provider::params'),
        }

        include '::confkeeper::provider'

        $etckeeper_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| {
          "${fqdn} from ${title} for confkeeper::provider"
        }

        monitoring::host::checkpoint {$etckeeper_checkpoint_title:
          templates        => ['linux_tpl'],
          custom_variables => [
            {
              'varname' => '_crons',
              'value'   => {"cron-${etckeeper_cron_name}" => [$etckeeper_cron_name, '1d']},
              'comment' => ["The host should push its configuration daily (${etckeeper_cron_name})."],
            }
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


    } # End of "case $a_class"

  } # End of "each.$remaining_classes"


  ##################################
  ### The case of eximnullclient ###
  ##################################
  if $nullclient {

    include '::network::params'

    $interfaces         = $::network::params::interfaces
    $inventory_networks = $::network::params::inventory_networks
    $admin_email        = ::network::get_param($interfaces, $inventory_networks, 'admin_email')
    $smtp_relay         = ::network::get_param($interfaces, $inventory_networks, 'smtp_relay')
    $smtp_port          = ::network::get_param($interfaces, $inventory_networks, 'smtp_port')

    unless $admin_email =~ NotUndef {
      @("END"/L$).fail
        ${title}: sorry the variable \$admin_email is undefined.
        |- END
    }

    unless $smtp_relay =~ NotUndef {
      @("END"/L$).fail
        ${title}: sorry the variable \$smtp_relay is undefined.
        |- END
    }

    unless $smtp_port =~ NotUndef {
      @("END"/L$).fail
        ${title}: sorry the variable \$smtp_port is undefined.
        |- END
    }

    class { '::eximnullclient::params':
      dc_smarthost         => [ { 'address' => $smtp_relay, 'port' => $smtp_port } ],
      redirect_local_mails => $admin_email,
    }

    include '::eximnullclient'

  } # End of "if $nullclient".

  ##############################################################################################
  ## olc's workaround's -- if flaf discover that a day, I will disavow any knowledge of it :) ##
  ##############################################################################################
  if $::lsbdistcodename == 'stretch' {
    $snmp_workaround_present = present
  } else {
    $snmp_workaround_present = absent
  }

  file { '/etc/sudoers.d/xxx-snmpd-extend-stretch-workaround':
    ensure  => $snmp_workaround_present,
    source  => 'puppet:///modules/roles/etc/sudoers.d/xxx-snmpd-extend-stretch-workaround', 
    owner   => 'root',
    group   => 'root',
    mode    => '0440', 
    require => Package['sudo'],
  }
}


