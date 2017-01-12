define pxeserver::pxe_entry (
  String[1] $distrib,
  String    $apt_proxy = '',
  String[1] $partman_early_command_file = "${title}/partman_early_command",
  String    $partman_auto_disk = '',
  Boolean   $skip_boot_loader = true,
  String[1] $late_command_file = "${title}/late_command",
  Boolean   $install_puppet = true,
  Boolean   $permitrootlogin_ssh = true,
) {

  $my_ip             = $::pxeserver::my_ip
  $join_preseed_str  = "; \\\n    "

  file { "/var/www/html/${title}":
    ensure  => directory,
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
  }

  case $partman_early_command_file {

    'nothing': {
      $partman_early_command = ''
    }

    default: {
      file { "/var/www/html/${title}/partman_early_command":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => file("pxeserver/${partman_early_command_file}"),
      }
      $partman_early_command = [
        "wget http://${my_ip}/${title}/partman_early_command -O /tmp/partman_early_command",
        'chmod a+x /tmp/partman_early_command',
        '/tmp/partman_early_command',
      ].join($join_preseed_str)
    }

  }

  # Setting of the $late_command variable.
  $late_command = with($late_command_file, $install_puppet,
                       $permitrootlogin_ssh)
                  |$late_command_file, $install_puppet, $permitrootlogin_ssh| {

    case $late_command_file {

      'nothing': {
        $custom_commands = []
      }

      default: {

        file { "/var/www/html/${title}/late_command":
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => file("pxeserver/${late_command_file}"),
        }

        $custom_commands = [
          "wget http://${my_ip}/${late_command_file} -O /tmp/late_command",
          'chmod a+x /tmp/late_command',
          '/tmp/late_command',
        ]

      }

    }

    if $install_puppet {

      $puppet_commands = [
        "wget http://${my_ip}/late-command-install-puppet -O /target/tmp/install-puppet",
        'chmod a+x /target/tmp/install-puppet',
        'in-target /bin/bash -c /tmp/install-puppet',
      ]

    } else {

      $puppet_commands = []

    }

    $set_permitrootlogin = [
      "sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /target/etc/ssh/sshd_config"
    ]

    if $permitrootlogin_ssh {

      $permitrootlogin_commands = $set_permitrootlogin

    } else {

      $permitrootlogin_commands = []

    }

    # The value returned by the with function.
    $custom_commands + $puppet_commands + $permitrootlogin_commands

  }.join($join_preseed_str)
  # End of the settings of the $late_command variable.

  file { "/var/www/html/${title}/preseed.cfg":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("pxeserver/preseed-${distrib}.cfg.epp",
                   {
                    'distrib'               => $distrib,
                    'apt_proxy'             => $apt_proxy,
                    'partman_early_command' => $partman_early_command,
                    'partman_auto_disk'     => $partman_auto_disk,
                    'skip_boot_loader'      => $skip_boot_loader,
                    'late_command'          => $late_command,
                   },
                  ),
  }

}
