# TODO: I don't know why but a default value for the $stage
#       parameter is mandatory, else the puppet run just
#       fails:
#
#         stage is a metaparameter; please choose another
#         parameter name in the network definition at ... etc.
#
class network (
  Boolean                                      $restart,
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
  Array[String[1], 1]                          $supported_distributions,
  String[1]                                    $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)
  ::network::check_interfaces($interfaces)

  $packages = [ 'vlan',         # To have the vlan feature.
                'ifenslave',    # To have the bonding feature.
                'bridge-utils', # To have the bridge feature.
              ]
  ensure_packages( $packages,
                   { ensure => present,
                     before => File['/etc/network/interfaces.puppet'],
                   }
                 )

  # The udev rule to force the name of interfaces
  # if the macaddress is given.
  file { '/etc/udev/rules.d/70-persistent-net.rules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => File['/etc/network/interfaces.puppet'],
    content => epp( 'network/70-persistent-net.rules.epp',
                    { 'interfaces' => $interfaces }
                  ),
  }

  file { '/etc/network/if-up.d/ignore_icmp_redirect':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/network/ignore_icmp_redirect',
    before => File['/etc/network/interfaces.puppet'],
    notify => Exec['ignore_icmp_redirect_now'],
  }

  exec { 'ignore_icmp_redirect_now':
    user        => 'root',
    command     => '/etc/network/if-up.d/ignore_icmp_redirect NOW',
    require     => File['/etc/network/if-up.d/ignore_icmp_redirect'],
    before      => File['/etc/network/interfaces.puppet'],
    refreshonly => true,
  }

  file { '/usr/local/sbin/restart-network.puppet':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => 'puppet:///modules/network/restart-network.puppet',
    before => File['/etc/network/interfaces.puppet'],
  }

  file { '/usr/local/sbin/rewrite-interfaces.puppet':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => 'puppet:///modules/network/rewrite-interfaces.puppet',
    before => File['/etc/network/interfaces.puppet'],
  }

  file { '/etc/network/interfaces.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'network/interfaces.puppet.epp',
                    { 'interfaces' => $interfaces }
                  ),
  }

  if $restart {

    # Just to avoid a long line below.
    $ifaces_file = '/etc/network/interfaces'

    exec { 'restart-network-now':
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      command => '/usr/local/sbin/restart-network.puppet',
      user    => 'root',
      group   => 'root',
      # Execute only when the files are different.
      unless  => "diff -q '${ifaces_file}' '${ifaces_file}.puppet'",
      # Normally if /etc/network/interfaces.puppet is already managed,
      # all others resources in this class are already managed too,
      # so all is ready for the restart.
      require => File['/etc/network/interfaces.puppet'],
    }
  }

}


