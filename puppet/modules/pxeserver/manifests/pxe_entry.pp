define pxeserver::pxe_entry (
  String[1] $distrib,
  String    $apt_proxy = '',
  String[1] $partman_early_command_file = "${title}/partman_early_command",
  String[1] $late_command_file = "${title}/late_command",
  Boolean   $install_puppet = true,
  Boolean   $permitrootlogin_ssh = true,
) {

  $my_ip          = $::pxeserver::my_ip
  $install_puppet_cmd = [
    "wget http://${my_ip}/late-command-install-puppet -O /target/tmp/install-puppet",
    'chmod a+x /target/tmp/install-puppet',
    'in-target /bin/bash -c /tmp/install-puppet',
  ]

  file { "/var/www/html/${title}":
    ensure  => directory,
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
  }

  if $partman_early_command_file == 'nothing' {

    $partman_early_command = ''

  } else {

    file { "/var/www/html/${title}/partman_early_command":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => file("pxeserver/${partman_early_command_file}"),
    }

    $partman_early_command = [
      "wget http://${my_ip}/${partman_early_command_file} -O /tmp/partman_early_command",
      'chmod a+x /tmp/partman_early_command',
      '/tmp/partman_early_command',
    ].join("; \\\n    ")

  }

  if $late_command_file == 'nothing' {

    $late_command_tmp1 = []

  } else {

    file { "/var/www/html/${title}/late_command":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => file("pxeserver/${late_command_file}"),
    }

    $late_command_tmp1 = [
      "wget http://${my_ip}/${late_command_file} -O /tmp/late_command",
      'chmod a+x /tmp/late_command',
      '/tmp/late_command',
    ]

  }

  if $install_puppet_cmd {
    $late_command_tmp2 = concat($late_command_tmp1, $install_puppet_cmd)
  } else {
    $late_command_tmp2 = $late_command_tmp1
  }

  $set_permitrootlogin = [ "sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /target/etc/ssh/sshd_config" ]

  if $permitrootlogin_ssh {
    $late_command = concat($late_command_tmp2, $set_permitrootlogin).join("; \\\n    ")
  } else {
    $late_command = $late_command_tmp2.join("; \\\n    ")
  }

  file { "/var/www/html/${title}/preseed.cfg":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("pxeserver/preseed-${distrib}.cfg.epp",
                   {
                    'apt_proxy'             => $apt_proxy,
                    'partman_early_command' => $partman_early_command,
                    'skip_boot_loader'      => true,
                    'late_command'          => $late_command,
                   },
                  ),
  }

}
