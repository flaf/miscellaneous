class moo::cargo::params (
  Moo::MoobotConf     $moobot_conf,
  Optional[String[1]] $docker_iface = undef,
  String[1]           $docker_bridge_cidr_address,
  Array[String[1]]    $docker_dns,
  String[1]           $ceph_account,
  String[1]           $ceph_client_mountpoint,
  Boolean             $ceph_mount_on_the_fly,
  String[1]           $backups_dir,
  Integer[1]          $backups_retention,
  Integer[1]          $backups_moodles_per_day,
  Boolean             $make_backups,
) {

}


