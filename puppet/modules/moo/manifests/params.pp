class moo::params (
  String[1]                       $shared_root_path,
  Integer[5000]                   $first_guid,
  String[1]                       $default_version_tag,
  Optional[ Array[String[1], 1] ] $lb = undef,
  Optional[ String[1] ]           $moodle_db_host = undef,
  String[1]                       $moodle_db_adm_user,
  Optional[ String[1] ]           $moodle_db_adm_pwd = undef,
  Optional[ String[1] ]           $moodle_db_pfx = undef,
  Optional[ String[1] ]           $docker_repository = undef,
  Integer[1]                      $default_desired_num,
  Optional[ String[1] ]           $moobot_db_host = undef,
  Optional[ String[1] ]           $moobot_db_pwd = undef,
  Optional[ Array[String[1], 1] ] $memcached_servers = undef,
  String[1]                       $ha_template,
  String[1]                       $ha_reload_cmd,
  String[1]                       $ha_stats_login,
  Optional[ String[1] ]           $ha_stats_pwd = undef,
  Optional[ String[1] ]           $ha_log_server = undef,
  String[1]                       $ha_log_format,
  String[1]                       $smtp_relay,
  Integer[1]                      $smtp_port,
  Optional[ Array[String[1], 1] ] $mongodb_servers = undef,
  String[1]                       $replicaset,
  Optional[ String[1] ]           $captain_mysql_rootpwd = undef,
  Optional[ String[1] ]           $docker_iface = undef,
  Optional[ String[1] ]           $docker_gateway = undef, # Specific, definitive value $docker_gateway_final
  String[1]                       $docker_bridge_cidr_address,
  Array[String[1]]                $docker_dns,
  Optional[ Boolean ]             $iptables_allow_dns = undef, # Specific, definitive value $docker_allow_dns_final
  String[1]                       $ceph_account,
  String[1]                       $ceph_client_mountpoint,
  Boolean                         $ceph_mount_on_the_fly,
  String[1]                       $backups_dir,
  Integer[1]                      $backups_retention,
  Integer[1]                      $backups_moodles_per_day,
  Boolean                         $make_backups,
) {

  # The parameter $docker_gateway is special. Indeed, its
  # default value can not be set in the data() function
  # because its default value depends on the value of the
  # parameter $docker_iface. It's only in this class
  # "params" that we can know the real and definitive value
  # of the parameter $docker_iface, so it's only in this
  # class "params" that we can set the smart default value
  # of $docker_gateway (unless the value of the
  # $docker_gateway parameter has been set in hiera by the
  # user).

  # Because reassignment is forbidden, we must use a new
  # variable $docker_gateway_final (yes it socks).

  case $docker_gateway {

    Undef: {

      # $docker_gateway is not set by the user (for instance via hiera).

      if !defined(Class['::network::params']) { include '::network::params' }
      $interfaces         = $::network::params::interfaces
      $inventory_networks = $::network::params::inventory_networks

      if $docker_iface !~ Undef and $interfaces.has_key($docker_iface) {

        $only_docker_ifcace   = { $docker_iface => $interfaces[$docker_iface] }
        $docker_gateway_final = ::network::get_param($only_docker_ifcace,
                                                     $inventory_networks,
                                                     'gateway', undef)

      } else {

        # Bad case when $docker_iface is undef or not in the
        # $interfaces of the current node. It will fail in the
        # cargo class.
        $docker_iface_not_among_interfaces = true
        $docker_gateway_final              = undef

      }

    } ### end Undef case ###

    NotUndef: {

      # $docker_gateway is already set.
      $docker_gateway_final = $docker_gateway

    } ### end NotUndef case ###

  }

#  ### The same as above but with a if {} else {} instruction.
#  ### Finally it's less readable.
#
#  if $docker_gateway =~ Undef {
#
#    # $docker_gateway is not set by the user (for instance via hiera).
#
#    if !defined(Class['::network::params']) { include '::network::params' }
#    $interfaces         = $::network::params::interfaces
#    $inventory_networks = $::network::params::inventory_networks
#
#    if $docker_iface !~ Undef and $interfaces.has_key($docker_iface) {
#
#      $only_docker_ifcace   = { $docker_iface => $interfaces[$docker_iface] }
#      $docker_gateway_final = ::network::get_param($only_docker_ifcace,
#                                                   $inventory_networks,
#                                                   'gateway', undef)
#
#    } else {
#
#      # Bad case when $docker_iface is undef or not in the
#      # $interfaces of the current node. It will fail in the
#      # cargo class.
#      $docker_iface_not_among_interfaces = true
#      $docker_gateway_final              = undef
#
#    }
#
#  } else {
#
#    # $docker_gateway is already set.
#    $docker_gateway_final = $docker_gateway
#
#  }


  # Same problem with the parameter $iptables_allow_dns. Its
  # default value depends on the $docker_dns.

  $host_addr = ::network::get_addresses($interfaces)

  if $docker_dns.filter |$a_dns_addr| { $host_addr.member($a_dns_addr) }.empty {
    $iptables_allow_dns_final = false
  } else {
    $iptables_allow_dns_final = true
  }

}


