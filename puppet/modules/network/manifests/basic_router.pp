class network::basic_router {

  include '::network::basic_router::params'
  $masqueraded_networks = $::network::basic_router::params::masqueraded_networks

  $ipv4_forwarding_content = @(END)
    ### This file is managed by Puppet, don't edit it. ###
    net.ipv4.ip_forward=1
    | END

  file { '/etc/sysctl.d/70-ipv4-forwarding.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $ipv4_forwarding_content,
    notify  => Exec['update-ipv4-forwarding-kernel-conf'],
  }

  exec{ 'update-ipv4-forwarding-kernel-conf':
    command     => 'sysctl -p /etc/sysctl.d/70-ipv4-forwarding.conf',
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    group       => 'root',
    require     => File['/etc/sysctl.d/70-ipv4-forwarding.conf'],
    refreshonly => true,
  }

  file { '/etc/network/if-up.d/masquerade-networks':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('network/masquerade-networks.epp',
                   { 'masqueraded_networks' => $masqueraded_networks }
                  ),
    notify  => Exec['apply-masquerading'],
  }

  exec{ 'apply-masquerading':
    command     => '/etc/network/if-up.d/masquerade-networks',
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    environment => [ 'IFACE=--all' ],
    user        => 'root',
    group       => 'root',
    require     => File['/etc/network/if-up.d/masquerade-networks'],
    refreshonly => true,
  }

}


