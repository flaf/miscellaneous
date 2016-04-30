class pxeserver {

  #if $dhcp_range[0] == 'NOT-DEFINED' and $dhcp_range[1] == 'NOT-DEFINED' {
  #  regsubst(@("END"), '\n', ' ', 'G').fail
  #    $title: sorry you must provide a value to the
  #    `dhcp_range` parameter.
  #    |- END
  #}

  #if $dhcp_dns_servers.empty {
  #  regsubst(@("END"), '\n', ' ', 'G').fail
  #    $title: sorry the parameter `dhcp_dns_servers` is empty.
  #    You must provide DNS servers in the DHCP configuration.
  #    |- END
  #}

  [ 'puppet_collection',
    'pinning_puppet_version',
    'puppet_server',
    'puppet_ca_server',
  ].each |$var| {
    if getvar($var) == 'NOT-DEFINED' {
      regsubst(@("END"), '\n', ' ', 'G').fail
        $title: sorry the mandatory parameter `$var` is not defined.
        |- END
    }
  }

  require '::pxeserver::conf'

  $distribs_provided = {
    'trusty' => {
      'family'       => 'ubuntu',
      'boot_options' => 'locale=en_US.UTF-8 keymap=fr',
    },
    'jessie' => {
      'family'       => 'debian',
      'boot_options' => 'locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=fr(latin9)',
    },
  }

  $distribs_provided_array = $distribs_provided.keys
  $distribs_provided_str   = $distribs_provided_array.join(', ')
  $my_family               = $facts['os']['distro']['id'].downcase
  $my_ip                   = $facts['networking']['ip']
  $pxe_entries             = $::pxeserver::conf::pxe_entries

  # Check that distribs are in provided distribs.
  $pxe_entries.each |$id, $settings| {

    $distrib = $settings['distrib']

    if ! $distribs_provided_array.member($distrib) {
      regsubst(@("END"), '\n', ' ', 'G').fail
        $title: sorry the distribution `$distrib` is not
        provided by the module $module_name. Currently, the
        allowed distributions are $distribs_provided_str.
        |- END
    }

  }

  $dhcp_conf_updated = $dhcp_conf.reduce({}) |$memo, $entry| {
    $tag         = $entry[0]
    $settings    = $entry[1]
    $range_ip1   = $settings['range'][0]
    $range_ip2   = $settings['range'][1]
    $netmask_tmp = $settings['range'][2]
    $netmask     = ::network::dump_cidr("${range_ip1}/${netmask_tmp}")['netmask']

    $memo + { $tag => $settings + { 'range' => [$range_ip1, $range_ip2, $netmask] } }

  }

  ensure_packages( [ 'dnsmasq',
                     'lsb-release',
                     'apache2',
                   ], { ensure => present } )

  file { '/srv':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => File['/etc/dnsmasq.d/main.conf'],
    require => Package['dnsmasq'],
  }

  file { [ '/srv/tftp', '/srv/tftp/pxelinux.cfg' ]:
    ensure  => directory,
    owner   => 'dnsmasq',
    group   => 'root', # There is no group dnsmasq.
    mode    => '0755',
    before  => File['/etc/dnsmasq.d/main.conf'],
    require => Package['dnsmasq'],
  }

  file { '/srv/tftp/pxelinux.cfg/default':
    ensure  => present,
    owner   => 'dnsmasq',
    group   => 'root', # There is no group dnsmasq.
    mode    => '0644',
    before  => File['/etc/dnsmasq.d/main.conf'],
    require => Package['dnsmasq'],
    content => epp('pxeserver/pxe-default.epp',
                   {
                    'distribs_provided' => $distribs_provided,
                    'my_family'         => $my_family,
                    'my_ip'             => $my_ip,
                    'pxe_entries'       => $pxe_entries,
                   },
                  ),
  }

  file { '/usr/local/sbin/update-di.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => [ Package['dnsmasq'], File['/srv/tftp'] ],
    source  => 'puppet:///modules/pxeserver/update-di.puppet',
  }

  # Install the (debian|ubuntu)-installer of the current distribution.
  exec { 'populate-srv-tftp-installer':
    command => '/usr/local/sbin/update-di.puppet',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => 'test -L /srv/tftp/pxelinux.0',
    before  => File['/etc/dnsmasq.d/main.conf'],
    require => File['/usr/local/sbin/update-di.puppet'],
  }

  # Install the kernel and initrd.gz of each provided distribution.
  $distribs_provided.keys.each |$distrib| {

    exec { "populate-srv-tftp-${distrib}":
      command => "/usr/local/sbin/update-di.puppet '${distrib}'",
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      unless  => "test -d '/srv/tftp/${distrib}'",
      before  => File['/etc/dnsmasq.d/main.conf'],
      require => File['/usr/local/sbin/update-di.puppet'],
    }

  }

  file { '/etc/dnsmasq.d/main.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['dnsmasq'],
    require => Package['dnsmasq'],
    content => epp('pxeserver/dnsmasq-main.conf.epp',
                   {
                    'dhcp_conf'        => $dhcp_conf_updated,
                    'domain'           => $::domain,
                   }
                  ),
  }

  file { "/etc/dnsmasq.d/reservations.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['dnsmasq'],
    require => Package['dnsmasq'],
    content => epp('pxeserver/dnsmasq-reservations.conf.epp',
                   { 'ip_reservations' => $ip_reservations, }
                  ),
  }

  service { 'dnsmasq':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => File['/etc/dnsmasq.d/main.conf'],
  }

  service { 'apache2':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Package['apache2'],
  }

  file { '/var/www/html/index.html':
    ensure  => absent,
    require => Package['apache2'],
  }

  file { '/var/www/html/late-command-install-puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['apache2'],
    content => epp('pxeserver/late-command-install-puppet',
                   {
                    'puppet_collection'      => $puppet_collection,
                    'pinning_puppet_version' => $pinning_puppet_version,
                    'puppet_server'          => $puppet_server,
                    'puppet_ca_server'       => $puppet_ca_server,
                   },
                  ),
  }

  $pxe_entries.each |$id, $settings| {

    ::pxeserver::pxe_entry { "$id":
      distrib                    => $settings['distrib'],
      apt_proxy                  => $settings['apt_proxy'],
      partman_early_command_file => $settings['partman_early_command_file'],
      partman_auto_disk          => $settings['partman_auto_disk'],
      skip_boot_loader           => $settings['skip_boot_loader'],
      late_command_file          => $settings['late_command_file'],
      install_puppet             => $settings['install_puppet'],
      permitrootlogin_ssh        => $settings['permitrootlogin_ssh'],
      require                    => Package['apache2'],
    }

  }

}


