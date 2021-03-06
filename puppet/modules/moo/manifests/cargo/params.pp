class moo::cargo::params (
  Moo::MoobotConf  $moobot_conf,
  String[1]        $docker_iface,
  String[1]        $docker_bridge_cidr_address,
  Array[String[1]] $docker_dns,
  String[1]        $docker_gateway,
  Boolean          $iptables_allow_dns,
  String[1]        $ceph_account,
  String[1]        $ceph_client_mountpoint,
  Boolean          $ceph_mount_on_the_fly,
  String[1]        $backup_cmd,
  Boolean          $make_backups,
) {

}


