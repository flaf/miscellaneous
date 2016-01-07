function moo::data {

  include '::network::params'

  $has_local_resolver = $::network::params::local_resolver

  # We want to have $docker_dns and $docker_bridge_network
  # related with the parameters of ::network::params.
  if $has_local_resolver {

    # The host has a local resolver installed. It could be smart
    # that docker containers use it's possible.
    $listening_addr_resolver = $::network::params::local_resolver_interface

    # We remove the "localhost" addresses in the array.
    $remaining_addr = $listening_addr_resolver.filter |$a_addr| {
      $a_addr !~ /^127\./
    }

    # If $remaining_addr is empty, $docker_dns will be empty too
    # and we let docker choose the DNS addresses.
    $docker_dns = $remaining_addr

    # For the "docker" network, if it exist we choose the first
    # network in access-control == 'allow' in the conf of the
    # local resolver.
    $access_control = $::network::params::local_resolver_access_control
    $remaining_net  = $access_control.filter |$a_access| {
      $a_access[1] == 'allow'
    }
    if $remaining_net.empty {
      # No network available, we take this default network.
      $docker_bridge_network = '172.17.0.1/16'
    } else {
      # We choose the first network in this array.
      $docker_bridge_network = $remaining_net[0][0]
    }

  } else {

    # No local resolver, so we let docker choose the DNS addresses
    # and the docker network will have this value below.
    $docker_dns            = []
    $docker_bridge_network = '172.17.0.1/16'

  }

  $smtp_relay = $::network::params::smtp_relay
  $smtp_port  = $::network::params::smtp_port

  $r = 'salt';

  {
    moo::common::shared_root_path    => '/mnt/moodle',
    moo::common::first_guid          => 5000,
    moo::common::default_version_tag => 'latest',
    moo::common::lb                  => [ 'NOT-DEFINED' ],
    moo::common::moodle_db_host      => 'NOT-DEFINED',
    moo::common::moodle_adm_user     => 'mooadm',
    moo::common::moodle_adm_pwd      => sha1("$r-moodle_adm_pwd")[0,15],
    moo::common::moodle_db_pfx       => sha1("$r-moodle_db_pfx")[0,4],
    moo::common::docker_repository   => 'NOT-DEFINED',
    moo::common::default_desired_num => 2,
    moo::common::moobot_db_host      => 'localhost',
    moo::common::moobot_db_pwd       => sha1("$r-moobot_db_pwd")[0,15],
    moo::common::memcached_servers   => [ 'NOT-DEFINED' ],
    moo::common::ha_template         => '/opt/moobot/templates/haproxy.conf.j2',
    moo::common::ha_reload_cmd       => '/opt/moobot/bin/haproxy_graceful_reload',
    moo::common::ha_stats_login      => 'admin',
    moo::common::ha_stats_pwd        => sha1("$r-ha_stats_pwd")[0,15],
    moo::common::smtp_relay          => $smtp_relay,
    moo::common::smtp_port           => $smtp_port,

    moo::captain::mysql_rootpwd           => sha1("$r-mysql_rootpwd_moobot")[0,15],
    moo::captain::supported_distributions => [ 'trusty' ],

    moo::cargo::docker_iface            => 'eth0',
    # Warning: docker_bridge_network is the value of the
    # --bip option (from "docker daemon"). A value like
    # '172.17.0.0/16' is incorrect because the part before
    # the '/' will be the IP address of the docker0
    # interface.
    moo::cargo::docker_bridge_network   => $docker_bridge_network,
    moo::cargo::docker_dns              => $docker_dns,
    moo::cargo::ceph_account            => 'cephfs',
    moo::cargo::ceph_client_mountpoint  => '/moodle',
    moo::cargo::ceph_mount_on_the_fly   => false,
    moo::cargo::supported_distributions => [ 'trusty' ],

    moo::lb::supported_distributions => [ 'trusty' ],
  }

}


