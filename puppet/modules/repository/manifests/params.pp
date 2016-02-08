class repository::params (

  String[1] $distrib_url,
  Boolean   $distrib_src,
  Boolean   $distrib_install_recommends,

  String[1] $ceph_url,
  Boolean   $ceph_src,
  String[1] $ceph_codename,
  String[1] $ceph_pinning_version,

  String[1] $puppet_url,
  Boolean   $puppet_src,
  String[1] $puppet_collection,
  String[1] $puppet_pinning_agent_version,
  String[1] $puppet_pinning_server_version,

  String[1] $postgresql_url,
  Boolean   $postgresql_src,

  String[1] $shinken_url,
  String[1] $shinken_key_url,
  String[1] $shinken_fingerprint,

  String[1] $raid_url,
  String[1] $raid_key_url,
  String[1] $raid_fingerprint,

  String[1] $moobot_url,
  String[1] $moobot_key_url,
  String[1] $moobot_fingerprint,

  String[1] $mco_url,
  String[1] $mco_key_url,
  String[1] $mco_fingerprint,

  String[1] $jrds_url,
  String[1] $jrds_key_url,
  String[1] $jrds_fingerprint,

  String[1] $docker_url,
  Boolean   $docker_src,
  String[1] $docker_pinning_version,

  String[1] $proxmox_url,

) {

}


