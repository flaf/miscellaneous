class pxeserver (
  Array[String[1], 2, 2]                  $dhcp_range,
  Array[String[1]]                        $dhcp_dns_servers,
  String[1]                               $dhcp_gateway,
  Hash[String[1], Array[String[1], 2, 2]] $ip_reservations,
  String[1]                               $puppet_collection,
  String[1]                               $pinning_puppet_version,
  String[1]                               $puppet_server,
  String[1]                               $puppet_ca_server,
  Array[String[1], 1]                     $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if $dhcp_range[0] == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry you must provide a value to the
      `dhcp_range` parameter.
      |- END
  }

  if $dhcp_dns_servers.empty {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the parameter `dhcp_dns_servers` is empty.
      You must provide DNS servers in the DHCP configuration.
      |- END
  }

  if $dhcp_gateway == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the parameter `dhcp_gateway` is not defined.
      You must provide a gateway in the DHCP configuration.
      |- END
  }

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

  $my_family      = $facts['os']['distro']['id'].downcase
  $my_ip          = $facts['networking']['ip']

  $install_puppet = [ "wget http://${my_ip}/install-puppet -O /target/tmp/install-puppet",
                      'chmod a+x /target/tmp/install-puppet',
                      'in-target /bin/bash -c /tmp/install-puppet', ]

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
                    'dhcp_range'       => $dhcp_range,
                    'domain'           => $::domain,
                    'dhcp_dns_servers' => $dhcp_dns_servers,
                    'dhcp_gateway'     => $dhcp_gateway,
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


  # Partial preseeds with and without puppet agent.
  [ 'with-puppet', 'without-puppet' ].each |$with_puppet| {

    $distribs_provided.each |$distrib, $settings| {

      $late_command = $with_puppet ? {
        'with-puppet'    => $install_puppet.join("; \\\n    "),
        'without-puppet' => '',
      }

      file { "/var/www/html/preseed-${distrib}-partial-${with_puppet}.cfg":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['apache2'],
        content => epp("pxeserver/preseed-${distrib}.cfg.epp",
                       {
                        'apt_proxy'             => '',
                        'partman_early_command' => '',
                        'skip_boot_loader'      => false,
                        'late_command'          => $late_command,
                       },
                      ),
      }

    }

  }

  file { '/var/www/html/install-puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['apache2'],
    content => epp('pxeserver/install-puppet',
                   {
                    'puppet_collection'      => $puppet_collection,
                    'pinning_puppet_version' => $pinning_puppet_version,
                    'puppet_server'          => $puppet_server,
                    'puppet_ca_server'       => $puppet_ca_server,
                   },
                  ),
  }

}


