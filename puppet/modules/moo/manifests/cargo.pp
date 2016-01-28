class moo::cargo (
  String[1]           $docker_iface,
  String[1]           $docker_bridge_network,
  Array[String[1]]    $docker_dns,
  String[1]           $ceph_account,
  String[1]           $ceph_client_mountpoint,
  String[1]           $backups_dir,
  Integer[1]          $backups_retention,
  Boolean             $make_backups,
  Boolean             $ceph_mount_on_the_fly,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # WARNING: finally, it's probably better to use the
  # package from Ubuntu repositories.
  #
  #require '::repository::docker'

  include '::network::params'
  require '::moo::common'
  include '::moo::dockerapi'

  $interfaces         = $::network::params::interfaces
  $inventory_networks = $::network::params::inventory_networks
  $shared_root_path   = $::moo::common::shared_root_path

  unless $interfaces.has_key($docker_iface) {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry, problem with the parameter docker_iface. The
      interface `$docker_iface` is not defined among the interfaces
      of the host.
      |- END
  }

  $only_docker_ifcace = { $docker_iface => $interfaces[$docker_iface] }
  $docker_gateway     = ::network::get_param($only_docker_ifcace,
                                             $inventory_networks,
                                             'gateway', '')

  if $docker_gateway.empty {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry, problem with the parameter docker_iface. No
      gateway has been found for the interface docker_iface=`$docker_iface`.
      |- END
  }

  $host_addr = ::network::get_addresses($interfaces)
  if $docker_dns.filter |$a_dns_addr| { $host_addr.member($a_dns_addr) }.empty {
    $iptables_allow_dns = false
  } else {
    $iptables_allow_dns = true
  }

  file_line { 'set-dockertable-name':
    path   => '/etc/iproute2/rt_tables',
    line   => "10    dockertable",
    before  => [ Package['docker.io'],
                 File['/etc/network/if-up.d/docker0-up']
               ],
  }

  file { '/etc/default/docker':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    #before  => Package['docker-engine'],
    before  => Package['docker.io'],
    notify  => Service['docker'],
    content => epp('moo/default_docker.epp',
                   {
                    'docker_bridge_network' => $docker_bridge_network,
                    'docker_dns'            => $docker_dns,
                   }
                  )
  }

  # Packages needed in the script /etc/network/if-up.d/docker0-up.
  ensure_packages( [ 'ipcalc', 'gawk' ], { ensure => present } )
  file { '/etc/network/if-up.d/docker0-up':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    #before  => Package['docker-engine'],
    before  => [ Package['docker.io'], Package['ipcalc'], Package['gawk'] ],
    notify  => Exec['set-iptables-rules'],
    content => epp('moo/docker0-up.epp',
                   {
                    'docker_bridge_network' => $docker_bridge_network,
                    'docker_iface'          => $docker_iface,
                    'docker_gateway'        => $docker_gateway,
                    'iptables_allow_dns'    => $iptables_allow_dns,
                   }
                  )
  }

  exec { 'set-iptables-rules':
    user        => 'root',
    group       => 'root',
    environment => [ "IFACE='${docker_iface}'" ],
    command     => '/etc/network/if-up.d/docker0-up',
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    refreshonly => true,
    require     => File['/etc/network/if-up.d/docker0-up'],
  }

  # From Ubuntu repositories, the name of the package
  # is different.
  #
  #ensure_packages( [
  #                   'docker-engine',
  #                   'aufs-tools',
  #                 ],
  #                 {
  #                   ensure => present,
  #                 }
  #               )
  ensure_packages( [
                     'docker.io',
                     'aufs-tools',
                     'cgroup-lite', # without this package, it doesn't work.
                   ],
                   {
                     ensure => present,
                   }
                 )

  # On Trusty, docker has a "status" command but the exit
  # code is 0 even if docker is not running. The custom
  # command uses pgrep in the "procps" package.
  ensure_packages( [ 'procps' ], { ensure => present } )
  service { 'docker':
    ensure     => running,
    hasstatus  => false,
    status     => 'test "$(pgrep -c docker)" != 0',
    hasrestart => true,
    enable     => true,
    require    => [ File['/etc/default/docker'], Package['procps'] ],
  }

  file { $shared_root_path:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Just shortcuts.
  $c      = $ceph_account
  $climnt = $ceph_client_mountpoint

  # With "present", the entry is added in /etc/fstab.
  # With "mounted", the entry is added in /etc/fstab and the
  # device is mounted immediately. But at this time, we can't
  # know if the ceph packages are already installed.
  mount { $shared_root_path:
    #ensure   => mounted,
    ensure   => present,
    device   => "id=$c,keyring=/etc/ceph/ceph.client.$c.keyring,client_mountpoint=${climnt}",
    fstype   => 'fuse.ceph',
    #
    # ceph-fuse doesn't support the remount option.
    remounts => false,
    #
    # Be careful, because despite of "ensure => present" (ie
    # normally just set /etc/fstab, if options are changed I
    # have noticed a new process of ceph-fuse (like a new
    # mount) and the dockers have access to filedir no
    # longer. To sum up:
    #
    #      /!\ WARNING /!\
    #
    #      Don't change mount options or only when no docker
    #      is started and the server but just reboot the
    #      server after the puppet run
    #
    options  => 'noatime,nonempty,defaults,_netdev',
    require  => File[$shared_root_path],
  }

  if $ceph_mount_on_the_fly {

    $remount_cmd = @("END")
      mountpoint '$shared_root_path' && umount '$shared_root_path'
      mount '$shared_root_path'
      |- END

    exec { 'mount-cephfs':
      user        => 'root',
      group       => 'root',
      command     => $remount_cmd,
      path        => '/usr/sbin:/usr/bin:/sbin:/bin',
      refreshonly => true,
      subscribe   => Mount[$shared_root_path],
    }

  }

  file { '/usr/local/sbin/restart-all-dockers.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('moo/restart-all-dockers.puppet.epp',
                   { 'shared_root_path' => $shared_root_path, },
                  ),
  }

  cron { 'cron-restart-all-dockers-at-boot':
    ensure  => present,
    user    => 'root',
    command => '/usr/local/sbin/restart-all-dockers.puppet',
    require => File['/usr/local/sbin/restart-all-dockers.puppet'],
    special => 'reboot',
  }

  # Packages needed for this script.
  ensure_packages(
                   [
                     'jq',
                     'python',
                     'mysql-client',
                     'rsync',
                   ], { ensure => present } )
  file { '/usr/local/sbin/moobackup.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('moo/moobackup.puppet.epp',
                   {
                    'backups_dir'       => $backups_dir,
                    'backups_retention' => $backups_retention,
                    'shared_root_path'  => $shared_root_path,
                   },
                  ),
  }

  if $make_backups {

    cron { 'cron-backups-moodles':
      ensure  => $present,
      user    => 'root',
      # Yes, 2 consecutive backups are run.
      command => '/usr/local/sbin/moobackup.puppet; /usr/local/sbin/moobackup.puppet',
      hour    => 2,
      minute  => 0,
      require => File['/usr/local/sbin/moobackup.puppet'],
    }

  }

  file { '/usr/local/sbin/cargo-py-wrapper.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('moo/cargo-py-wrapper.puppet.epp',
                   {
                    'shared_root_path'  => $shared_root_path,
                   },
                  ),
  }

}


