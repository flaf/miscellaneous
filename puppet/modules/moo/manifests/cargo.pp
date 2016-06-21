class moo::cargo (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::moo::cargo::params'

  $moobot_conf                = $::moo::cargo::params::moobot_conf
  $docker_iface               = $::moo::cargo::params::docker_iface
  $docker_bridge_cidr_address = $::moo::cargo::params::docker_bridge_cidr_address
  $docker_dns                 = $::moo::cargo::params::docker_dns
  $ceph_account               = $::moo::cargo::params::ceph_account
  $ceph_client_mountpoint     = $::moo::cargo::params::ceph_client_mountpoint
  $ceph_mount_on_the_fly      = $::moo::cargo::params::ceph_mount_on_the_fly
  $backups_dir                = $::moo::cargo::params::backups_dir
  $backups_retention          = $::moo::cargo::params::backups_retention
  $backups_moodles_per_day    = $::moo::cargo::params::backups_moodles_per_day
  $make_backups               = $::moo::cargo::params::make_backups
  $shared_root_path           = $moobot_conf['main']['shared_root_path']





  $iptables_allow_dns         = $::moo::params::iptables_allow_dns_final
  $docker_gateway             = $::moo::params::docker_gateway_final

  ::homemade::fail_if_undef( $docker_iface, "moo::params::docker_iface", $title )

  if $::moo::params::docker_iface_not_among_interfaces {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry, problem with the parameter docker_iface. The
      interface `$docker_iface` is not defined among the interfaces
      of the host.
      |- END
  }

  if $docker_gateway =~ Undef {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry, problem with the parameter docker_iface. No
      gateway has been found for the interface docker_iface=`$docker_iface`.
      |- END
  }

  # WARNING: finally, it's probably better to use the
  # package from Ubuntu repositories.
  #
  #require '::repository::docker'

  require '::moo::common'
  include '::moo::dockerapi'

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
                    'docker_bridge_cidr_address' => $docker_bridge_cidr_address,
                    'docker_dns'                 => $docker_dns,
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
                    'docker_bridge_cidr_address' => $docker_bridge_cidr_address,
                    'docker_iface'               => $docker_iface,
                    'docker_gateway'             => $docker_gateway,
                    'iptables_allow_dns'         => $iptables_allow_dns,
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

  file { '/usr/local/sbin/moobackup-cron.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('moo/moobackup-cron.puppet.epp', {}),
    require => File['/usr/local/sbin/moobackup.puppet'],
  }

  if $make_backups {

    cron { 'cron-backups-moodles':
      ensure  => $present,
      user    => 'root',
      command => "/usr/local/sbin/moobackup-cron.puppet ${backups_moodles_per_day}",
      hour    => 2,
      minute  => 0,
      require => File['/usr/local/sbin/moobackup-cron.puppet'],
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


