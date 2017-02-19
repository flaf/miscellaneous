class proxmox::params (
  Optional[Variant[Integer[1], Pattern[/^([0-9]?[0-9]|100)%$/]]] $zfs_arc_max,
  Optional[Integer[0,100]]                                       $swappiness,
  Array[Proxmox::AdminUser]                                      $admin_users,
  String[1]                                                      $apt_nosub_url,
  String[1]                                                      $apt_nosub_component,
  Array[String[1], 1]                                            $supported_distributions,
) {

  case $zfs_arc_max {

    Integer[1]: {
      $zfs_arc_max_value = $zfs_arc_max
      $ensure_zfs_conf   = 'present'
    }

    String[1]: {
      # The value is a percentage.
      $total_memory      = $::facts['memory']['system']['total_bytes']
      $percent           = Integer.new($zfs_arc_max.regsubst('%', ''))
      $zfs_arc_max_value = $total_memory * $percent / 100
      $ensure_zfs_conf   = 'present'
    }

    default: {
      # The value should be undef.
      $zfs_arc_max_value = undef
      $ensure_zfs_conf   = 'absent'
    }

  }

  case $swappiness {

    # 10 is a recommended value for the swappiness with ZFS
    # (https://pve.proxmox.com/wiki/ZFS_on_Linux).
    Undef: {
      $swappiness_value = $zfs_arc_max ? { NotUndef => 10, default => undef }
    }

    default: {
      $swappiness_value = $swappiness
    }

  }

  $ensure_swappiness_conf = $swappiness_value ? {
    Undef   => 'absent',
    default => 'present',
  }

}


