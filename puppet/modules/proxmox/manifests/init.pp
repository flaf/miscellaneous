class proxmox {

  include '::proxmox::params'

  [
    $zfs_arc_max_value,
    $ensure_zfs_conf,
    $swappiness_value,
    $ensure_swappiness_conf,
    $supported_distributions,
  ] = Class['::proxmox::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $content_zfs_conf = @("END")
    ### This file is managed by Puppet, don't edit it. ###
    options zfs zfs_arc_max=${zfs_arc_max_value}
    | END

  file { '/etc/modprobe.d/zfs.conf':
    ensure  => $ensure_zfs_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content_zfs_conf,
    notify  => Exec['proxmox-update-initramfs'],
  }

  exec { 'proxmox-update-initramfs':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'update-initramfs -u',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
  }

  $content_swappiness_conf = @("END")
    ### This file is managed by Puppet, don't edit it. ###
    vm.swappiness=${swappiness_value}
    | END

  file { '/etc/sysctl.d/swappiness.conf':
    ensure  => $ensure_swappiness_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content_swappiness_conf,
    notify  => Exec['proxmox-update-swappiness'],
  }

  $update_swappiness = $swappiness_value ? {
    # Normally the default value of swappiness is 60 but it
    # can change in function of the Linux version.
    #Undef   => 'sysctl -w "vm.swappiness=60"',
    #
    Undef   => 'echo Need to reboot',
    default => 'sysctl --load=/etc/sysctl.d/swappiness.conf'
  }

  exec { 'proxmox-update-swappiness':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => $update_swappiness,
    user        => 'root',
    group       => 'root',
    refreshonly => true,
  }

}


