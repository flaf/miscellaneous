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

  file { '/etc/network/interfaces.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'network/interfaces.puppet.epp',
                    { 'interfaces' => $interfaces }
                  ),
  }

  # The command to restart the network properly.
  $restart_network_cmd = @(END)
    ifdown --all
    sleep 0.5

    if [ -f '/etc/network/interfaces.puppet' ]
    then
      cat '/etc/network/interfaces.puppet' >'/etc/network/interfaces'
    fi

    # Refresh the names of interfaces.
    udevadm control --reload-rules
    sleep 0.25
    udevadm trigger --subsystem-match='net' --action='add'
    sleep 0.25

    # Configure all interfaces marked 'auto'.
    ifup --all
    sleep 0.25
    | END

  if $restart {
    exec { 'restart-network-now':
      path        => '/usr/sbin:/usr/bin:/sbin:/bin',
      command     => "${restart_network_cmd}",
      user        => 'root',
      group       => 'root',
      refreshonly => true,
      require     => File['/etc/network/interfaces.puppet'],
      subscribe   => [
                       File['/etc/udev/rules.d/70-persistent-net.rules'],
                       File['/etc/network/interfaces.puppet'],
                     ],
    }
  }

  # Remark about "resolvconf"
  #
  # Trusty uses the package "resolvconf" by default and it's
  # not recommended to remove "resolvconf" in Trusty (if you
  # do that, you will remove the "ubuntu-minimal" package that
  # is not recommended). To come back to the classical
  # /etc/resolv.conf in Trusty, just keep the "resolvconf"
  # package and replace the symlink /etc/resolv.conf by a
  # regular file.

}


