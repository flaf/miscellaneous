class network::resolv_conf (
  String[1]           $domain,
  Array[String[1], 1] $search,
  Array[String[1], 1] $nameservers,
  Integer[1]          $timeout,
  Boolean             $local_resolver,
  Boolean             $override_dhcp,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if $local_resolver {

    ensure_packages(['unbound'],
                    {
                     ensure => present,
                     before => Service['unbound'],
                     notify => Service['unbound'],
                    }
                   )

    file { '/etc/unbound/unbound.conf.d/forward.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['unbound'],
      before  => Service['unbound'],
      notify  => Service['unbound'],
      content => epp('network/unbound.conf.epp',
                     { 'nameservers' => $nameservers, }
                    ),
    }

    # We move the file which configures unbound to use
    # the root DNS. Thus, the file will no be included
    # in the configuration. The /etc/unbound/unbound.conf
    # contains this line:
    #
    #   include: "/etc/unbound/unbound.conf.d/*.conf"
    #
    # After the mv command, the file will not be retrieved
    # by unbound.
    $file_auto_trust = '/etc/unbound/unbound.conf.d/root-auto-trust-anchor-file.conf'
    $cmd = "mv '${file_auto_trust}' '${file_auto_trust}.disabled'"

    exec { 'unbound-disable-root-auto-trust':
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      command => $cmd,
      onlyif  => "test -f '${file_auto_trust}'",
      before  => Service['unbound'],
      notify  => Service['unbound'],
    }

    if $::lsbdistcodename == 'jessie' {
      # On Debian Jessie like in Trusty, the service uses a
      # sysvinit script to start, but in Jessie the default
      # provider is "systemd" so we have to tell Puppet that
      # for this service the activation is via sysvinit and
      # not via systemd. "debian" provider is sysvinit in fact.
      $unbound_provider = 'debian'
    } else {
      $unbound_provider = undef
    }

    service { 'unbound':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => Exec['unbound-disable-root-auto-trust'],
      before     => File['/etc/resolv.conf'],
      provider   => $unbound_provider,
    }

  } # Enf of if $local_resolver.

  $interfaces = ::network::data()['network::interfaces']

  # Get the interfaces configured via DHCP.
  # Be careful, with .filter if the first argument is
  # a hash, the loop entry is an array with [key, value].
  $dhcp_ifaces = $interfaces.filter |$iface| {
    $dhcp_families = ['inet', 'inet6'].filter |$family| {
      if $iface[1].has_key($family) and $iface[1][$family]['method'] == 'dhcp' {
        true
      } else {
        false
      }
    }
    !$dhcp_families.empty
  }

  if $override_dhcp {
    $manage_resolv_conf = true
  } else {
    if $dhcp_ifaces.empty {
      # No DHCP interfaces, we manage resolf.conf.
      $manage_resolv_conf = true
    } else {
      # There is at least one DHCP interface, so we don't
      # manage resolv.conf.
      $manage_resolv_conf = false
    }
  }

  # If no DHCP, we can manage the content of the resolv.conf
  # file. Indeed, if at least one interface is configured
  # via DHCP, the content of this file will be (and should
  # be) updated via the DHCP mechanism, not via Puppet. It
  # seems to me more logical.
  if $manage_resolv_conf {
    $resolv_conf_content = epp('network/resolv.conf.epp',
                               {
                                 'domain'         => $domain,
                                 'search'         => $search,
                                 'nameservers'    => $nameservers,
                                 'timeout'        => $timeout,
                                 'local_resolver' => $local_resolver,
                               }
                              )
  } else {
    # There is DHCP configuration, we don't manage the
    # content of the /etc/resolv.conf file.
    $resolv_conf_content = undef
  }

  # With "ensure => file" is the file is a symlink to
  # "../run/resolvconf/resolv.conf", the symlink will
  # be removed and replaced by a regular file. So,
  # resolvconf mechanism will be disabled.
  file { '/etc/resolv.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $resolv_conf_content,
  }

}


