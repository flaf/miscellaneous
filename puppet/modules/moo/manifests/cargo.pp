class moo::cargo (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::moo::cargo::params'

  $moobot_conf                = $::moo::cargo::params::moobot_conf
  $docker_iface               = $::moo::cargo::params::docker_iface
  $docker_bridge_cidr_address = $::moo::cargo::params::docker_bridge_cidr_address
  $docker_dns                 = $::moo::cargo::params::docker_dns
  $docker_gateway             = $::moo::cargo::params::docker_gateway
  $iptables_allow_dns         = $::moo::cargo::params::iptables_allow_dns
  $ceph_account               = $::moo::cargo::params::ceph_account
  $ceph_client_mountpoint     = $::moo::cargo::params::ceph_client_mountpoint
  $ceph_mount_on_the_fly      = $::moo::cargo::params::ceph_mount_on_the_fly
  $backup_cmd                 = $::moo::cargo::params::backup_cmd
  $make_backups               = $::moo::cargo::params::make_backups

  # Just for convenience.
  $shared_root_path           = $moobot_conf['main']['shared_root_path']

  # WARNING: finally, it's probably better to use the
  # package from Ubuntu repositories. From Ubuntu
  # repositories, the name of the package is different.
  #
  #     require '::repository::docker'
  #     $docker_packages = ['docker-engine', 'aufs-tools']

  # Without the package 'cgroup-lite', it just doesn't work.
  $docker_packages = ['docker.io', 'aufs-tools', 'cgroup-lite']

  ensure_packages($docker_packages, { ensure => present })

  class { '::moo::common':
    moobot_conf => $moobot_conf,
  }

  include '::moo::dockerapi'

  file_line { 'set-dockertable-name':
    path   => '/etc/iproute2/rt_tables',
    line   => '10    dockertable',
    before  => File['/etc/network/if-up.d/docker0-up'],
  }

  # Packages needed in the script /etc/network/if-up.d/docker0-up.
  ensure_packages( [ 'ipcalc', 'gawk' ], { ensure => present } )

  file { '/etc/network/if-up.d/docker0-up':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Exec['set-iptables-rules'],
    require => [ Package['ipcalc'], Package['gawk'] ],
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

  file { '/etc/default/docker':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['docker'],
    require => Package['docker.io'],
    content => epp('moo/default_docker.epp',
                   {
                    'docker_bridge_cidr_address' => $docker_bridge_cidr_address,
                    'docker_dns'                 => $docker_dns,
                   }
                  )
  }

  # On Trusty, docker has a "status" command but the exit
  # code is 0 even if docker is not running. The custom
  # command uses pgrep in the "procps" package.
  ensure_packages(
    [ 'procps' ],
    { ensure => present, before => Service['docker'], }
  )

  service { 'docker':
    ensure     => running,
    hasstatus  => false,
    status     => 'test "$(pgrep -c docker)" != 0',
    hasrestart => true,
    #
    # It's very special but, with docker in Trusty (and
    # Jessie too), when the docker daemon starts (for
    # instance at boot), it creates _automatically_ the
    # binded volumes directories of the containers, _even_
    # _if_ the containers have already the status "exited".
    # A typical example is after a reboot: before the reboot
    # the containers were "running" containers but after the
    # reboot they became "exited" containers. But generally,
    # the docker daemon starts before the cephfs mount. So
    # the volumes directories are automatically created in
    # the root partition and, then, hidden by the cephfs
    # mount. To avoid this, we disable the docker daemon
    # which will be launched by the @reboot cron (see
    # below). The @reboot cron will ensure that the cephfs
    # mount is well mounted and _then_ will start the docker
    # daemon.
    #
    # So yes, it's special, we want to have a docker service
    # running but disable.
    #
    enable     => false,
    require    => File['/etc/default/docker'],
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

  # With "ensure => present", the entry is added in
  # /etc/fstab. With "ensure => mounted", the entry is added
  # in /etc/fstab and the device is mounted immediately.
  # But at this time, we can't know if the ceph packages are
  # already installed.
  mount { $shared_root_path:
    ensure   => present,
    device   => "id=$c,client_mountpoint=${climnt},keyring=/etc/ceph/ceph.client.$c.keyring",
    fstype   => 'fuse.ceph',
    remounts => false, # ceph-fuse doesn't support the remount option.
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
    #      is started in the server but just reboot the
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

  # Packages needed for the backup script (cron below).
  ensure_packages(['jq', 'python', 'mysql-client', 'rsync'], { ensure => present })

  # Unused now.
  #
  #file { '/usr/local/sbin/moobackup.puppet':
  #  ensure  => present,
  #  owner   => 'root',
  #  group   => 'root',
  #  mode    => '0755',
  #  content => epp('moo/moobackup.puppet.epp',
  #                 {
  #                  'backups_dir'       => $backups_dir,
  #                  'backups_retention' => $backups_retention,
  #                  'shared_root_path'  => $shared_root_path,
  #                 },
  #                ),
  #}
  #
  #file { '/usr/local/sbin/moobackup-cron.puppet':
  #  ensure  => present,
  #  owner   => 'root',
  #  group   => 'root',
  #  mode    => '0755',
  #  content => epp('moo/moobackup-cron.puppet.epp', {}),
  #  require => File['/usr/local/sbin/moobackup.puppet'],
  #}

  if $make_backups {

    cron { 'cron-backups-moodles':
      ensure  => present,
      user    => 'root',
      command => $backup_cmd,
      hour    => 3,
      minute  => 0,
      require => [
                   Package['jq'],
                   Package['python'],
                   Package['mysql-client'],
                   Package['rsync']
                 ],
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


