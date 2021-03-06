class pxeserver::params (
  Optional[ Hash[String[1], Pxeserver::Dhcpconf, 1] ] $dhcp_confs,
  Array[String[1]]                                    $no_dhcp_interfaces,
  Array[String[1]]                                    $apache_listen_to,
  String                                              $apt_proxy,
  Hash[String[1], Array[String[1], 2, 2]]             $ip_reservations,
  Hash[String[1], Array[String[1], 1]]                $host_records,
  Boolean                                             $dnsmasq_no_hosts,
  Array[String[1]]                                    $backend_dns,
  String                                              $cron_wrapper,
  Optional[ String[1] ]                               $puppet_collection,
  Optional[ String[1] ]                               $pinning_puppet_version,
  Optional[ String[1] ]                               $puppet_server,
  Optional[ String[1] ]                               $puppet_ca_server,
  Optional[ String[1] ]                               $puppet_apt_url,
  Optional[ String[1] ]                               $puppet_apt_key_finger,
  Array[String[1], 1]                                 $supported_distributions,
) {

  # Some variables for common help messages.
  $semi_manual_install_ubuntu = @(END)
    Semi manual installation of Ubuntu __DISTRIB__.
    Manual handling for:
      - network configuration,
      - disk partioning,
      - Grub installation.
    During the choice of the hostname, put the fqdn directly
    (or just a short hostname if the DHCP sends already a correct domain).
    |- END

  $semi_manual_install_debian = @(END)
    Semi manual installation of Debian __DISTRIB__.
    Manual handling for:
      - network configuration,
      - disk partioning,
      - Grub installation.
    |- END

  $all_in_first_disk_install_ubuntu = @(END)
    Semi manual installation of Ubuntu __DISTRIB__.
    Manual handling for network configuration.
    During the choice of the hostname, put the fqdn directly
    (or just a short hostname if the DHCP sends already a correct domain).
    The disk used is the first disk in the dictionary order.
    |- END

  $all_in_first_disk_install_debian = @(END)
    Semi manual installation of Debian __DISTRIB__.
    Manual handling for network configuration.
    The disk used is the first disk in the dictionary order.
    |- END

  $semi_manual_install_trusty        = $semi_manual_install_ubuntu.regsubst('__DISTRIB__', 'Trusty')
  $semi_manual_install_xenial        = $semi_manual_install_ubuntu.regsubst('__DISTRIB__', 'Xenial')
  $semi_manual_install_jessie        = $semi_manual_install_debian.regsubst('__DISTRIB__', 'Jessie')
  $semi_manual_install_stretch       = $semi_manual_install_debian.regsubst('__DISTRIB__', 'Stretch')
  $all_in_first_disk_install_trusty  = $all_in_first_disk_install_ubuntu.regsubst('__DISTRIB__', 'Trusty')
  $all_in_first_disk_install_xenial  = $all_in_first_disk_install_ubuntu.regsubst('__DISTRIB__', 'Xenial')
  $all_in_first_disk_install_jessie  = $all_in_first_disk_install_debian.regsubst('__DISTRIB__', 'Jessie')
  $all_in_first_disk_install_stretch = $all_in_first_disk_install_debian.regsubst('__DISTRIB__', 'Stretch')

  $pxe_entries = {

    'trusty-partial-preseed-without-puppet' => {
      'insert_begin'               => 'MENU BEGIN Partial preseed without puppet installed',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] Partial preseed without puppet installed',
      'text_help'                  => $semi_manual_install_trusty,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
    },

    'xenial-partial-preseed-without-puppet' => {
      'distrib'                    => 'xenial',
      'menu_label'                 => '[xenial] Partial preseed without puppet installed',
      'text_help'                  => $semi_manual_install_xenial,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
    },

    'jessie-partial-preseed-without-puppet' => {
      'distrib'                    => 'jessie',
      'menu_label'                 => '[jessie] Partial preseed without puppet installed',
      'text_help'                  => $semi_manual_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
    },

    'stretch-partial-preseed-without-puppet' => {
      'distrib'                    => 'stretch',
      'menu_label'                 => '[stretch] Partial preseed without puppet installed',
      'text_help'                  => $semi_manual_install_stretch,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
      'insert_end'                 => 'MENU END',
    },

    'trusty-partial-preseed-with-puppet' => {
      'insert_begin'               => 'MENU BEGIN Partial preseed with puppet installed',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] Partial preseed with puppet installed',
      'text_help'                  => $semi_manual_install_trusty,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'xenial-partial-preseed-with-puppet' => {
      'distrib'                    => 'xenial',
      'menu_label'                 => '[xenial] Partial preseed with puppet installed',
      'text_help'                  => $semi_manual_install_xenial,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'jessie-partial-preseed-with-puppet' => {
      'distrib'                    => 'jessie',
      'menu_label'                 => '[jessie] Partial preseed with puppet installed',
      'text_help'                  => $semi_manual_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'stretch-partial-preseed-with-puppet' => {
      'distrib'                    => 'stretch',
      'menu_label'                 => '[stretch] Partial preseed with puppet installed',
      'text_help'                  => $semi_manual_install_stretch,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'insert_end'                 => 'MENU END',
    },

    'trusty-all-in-first-disk-preseed-without-puppet' => {
      'insert_begin'               => 'MENU BEGIN All in first disk without puppet installed',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] All in first disk without puppet installed',
      'text_help'                  => $all_in_first_disk_install_trusty,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => ' ', # A space to have the entry without value.
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'partman_early_command_first_disk',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
    },

    'xenial-all-in-first-disk-preseed-without-puppet' => {
      'distrib'                    => 'xenial',
      'menu_label'                 => '[xenial] All in first disk without puppet installed',
      'text_help'                  => $all_in_first_disk_install_xenial,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => ' ', # A space to have the entry without value.
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'partman_early_command_first_disk',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
    },

    'jessie-all-in-first-disk-preseed-without-puppet' => {
      'distrib'                    => 'jessie',
      'menu_label'                 => '[jessie] All in first disk without puppet installed',
      'text_help'                  => $all_in_first_disk_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => ' ', # A space to have the entry without value.
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'partman_early_command_first_disk',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
    },

    'stretch-all-in-first-disk-preseed-without-puppet' => {
      'distrib'                    => 'stretch',
      'menu_label'                 => '[stretch] All in first disk without puppet installed',
      'text_help'                  => $all_in_first_disk_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => ' ', # A space to have the entry without value.
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'partman_early_command_first_disk',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
      'insert_end'                 => 'MENU END',
    },

    'trusty-all-in-first-disk-preseed-with-puppet' => {
      'insert_begin'               => 'MENU BEGIN All in first disk with puppet installed',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] All in first disk with puppet installed',
      'text_help'                  => $all_in_first_disk_install_trusty,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => ' ', # A space to have the entry without value.
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'partman_early_command_first_disk',
      'late_command_file'          => 'nothing',
    },

    'xenial-all-in-first-disk-preseed-with-puppet' => {
      'distrib'                    => 'xenial',
      'menu_label'                 => '[xenial] All in first disk with puppet installed',
      'text_help'                  => $all_in_first_disk_install_xenial,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => ' ', # A space to have the entry without value.
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'partman_early_command_first_disk',
      'late_command_file'          => 'nothing',
    },

    'jessie-all-in-first-disk-preseed-with-puppet' => {
      'distrib'                    => 'jessie',
      'menu_label'                 => '[jessie] All in first disk with puppet installed',
      'text_help'                  => $all_in_first_disk_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => ' ', # A space to have the entry without value.
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'partman_early_command_first_disk',
      'late_command_file'          => 'nothing',
    },

    'stretch-all-in-first-disk-preseed-with-puppet' => {
      'distrib'                    => 'stretch',
      'menu_label'                 => '[stretch] All in first disk with puppet installed',
      'text_help'                  => $all_in_first_disk_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => ' ', # A space to have the entry without value.
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'partman_early_command_first_disk',
      'late_command_file'          => 'nothing',
      'insert_end'                 => 'MENU END',
    },

    ###################################
    ### Very specific installations ###
    ###################################

    'jessie-elea-moosql' => {
      'insert_begin' => 'MENU BEGIN Specific installations',
      'distrib'      => 'jessie',
      'menu_label'   => '[jessie] Install Elea moosql (Supermicro - Transtec)',
      'apt_proxy'    => $apt_proxy,
      'text_help'    => @(END),
        1. Network configuration (interface, hostname)
        2. Partitioning (do not format the partitions, it is already done)
         RAID1 dev#0:    fs => EXT4, mntpt => /,              mntopt => noatime
         LV tmp:         fs => EXT4, mntpt => /tmp,           mntopt => noatime
         LV backups:     fs => XFS,  mntpt => /backups,       mntopt => noatime
         LV varlogmysql: fs => XFS,  mntpt => /var/log/mysql, mntopt => noatime
         LV varlibmysql: fs => EXT4, mntpt => /var/lib/mysql, mntopt => noatime
        |- END
    },

    'trusty-elea-cargo' => {
      'distrib'    => 'trusty',
      'menu_label' => '[trusty] Install Elea cargo (HP - Antemeta)',
      'apt_proxy'  => $apt_proxy,
      'text_help'  => @(END),
        WARNING: For the hostname question, put the FQDN of the host
        unless the DHCP server already sends the good domain name.
        Manual handling
          1. Network configuration
          2. Partitioning: just set a) /dev/sdb3 => EXT4 / noatime
             and b) /dev/sdb5 => XFS  /backups noatime.
             (do not format the partition, it is already done)
        |- END
    },

    'xenial-elea-lemming-xerus' => {
      'distrib'          => 'xenial',
      'menu_label'       => '[xenial] Install lemming/xerus (Supermicro - Transtec)',
      'apt_proxy'        => $apt_proxy,
      'skip_boot_loader' => true,
      'text_help'        => @(END),
        1. Network configuration (interface, hostname which should be a fqdn)
        2. Partitioning (do not format the partitions, it is already done)
         RAID10 dev#0:   fs => XFS, mntpt => /,        mntopt => noatime
         RAID10 dev#2:   fs => XFS, mntpt => /backups, mntopt => noatime
        |- END
    },

    'trusty-ceph-dc2' => {
      'distrib'    => 'trusty',
      'menu_label' => '[trusty] Install Ceph (Supermicro - ASInfo)',
      'apt_proxy'  => $apt_proxy,
      'insert_end' => 'MENU END',
      'text_help'  => @(END),
        WARNING: For the hostname question, put the FQDN of the host
        unless the DHCP server already sends the good domain name.
        Manual handling
          1. Network configuration
          2. Partitioning: just set the /dev/sda3 device to
             filesytem => EXT4, mountpoint => /, mount options => noatime
             (do not format the partition, it is already done)
        |- END
    },

  }

  $distribs_provided = {
    ### Ubuntu LTS ###
    'trusty' => {
      'family'       => 'ubuntu',
      'boot_options' => 'locale=en_US.UTF-8 keymap=fr',
    },
    'xenial' => {
      'family'       => 'ubuntu',
      'boot_options' => 'locale=en_US.UTF-8 keymap=fr',
    },
    ### Debian ###
    'jessie' => {
      'family'       => 'debian',
      'boot_options' => 'locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=fr(latin9)',
    },
    'stretch' => {
      'family'       => 'debian',
      'boot_options' => 'locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=fr(latin9)',
    },
  }

}


