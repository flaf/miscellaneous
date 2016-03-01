function moo::data {

  if !defined(Class['::network::params']) { include '::network::params' }
  $has_local_resolver = $::network::params::local_resolver

  # We want to have smart values for these parameters:
  #
  #   - $docker_dns
  #   - $docker_bridge_cidr_address
  #
  # ie values related with the parameters of ::network::params.
  #
  if $has_local_resolver {

    # The host has a local resolver installed. It could be
    # smart that docker containers can use it.
    $listening_addr_resolver = $::network::params::local_resolver_interface

    # We remove the "localhost" addresses in the array.
    $remaining_addr = $listening_addr_resolver.filter |$a_addr| {
      $a_addr !~ /^127\./ and $a_addr != 'localhost'
    }

    # If $remaining_addr is empty, $docker_dns will be empty too
    # and we let docker choose the DNS addresses.
    $docker_dns = $remaining_addr

    # For the "docker" network, if it exists, we choose the
    # first network in access-control == 'allow' in the conf
    # of the local resolver.
    $access_control = $::network::params::local_resolver_access_control
    $remaining_net  = $access_control.filter |$a_access| {
      $a_access[1] == 'allow'
    }
    if $remaining_net.empty {
      # No network available, we take this default network.
      $docker_bridge_cidr_address = '172.17.0.1/16'
    } else {
      # We choose the first network in this array.
      $docker_bridge_cidr_address = $remaining_net[0][0]
    }

  } else {

    # No local resolver, so we let docker choose the DNS addresses
    # and the docker network will have this value below.
    $docker_dns                 = []
    $docker_bridge_cidr_address = '172.17.0.1/16'

  }

  if !defined(Class['::mongodb::params']) { include '::mongodb::params' }
  $replicaset = $::mongodb::params::replset

  $interfaces         = $::network::params::interfaces
  $inventory_networks = $::network::params::inventory_networks
  $ha_log_server = ::network::get_param($interfaces, $inventory_networks,
                                        'log_server', undef)
  $ha_log_format = '%{+Q}o\ %{-Q}b\ %{-Q}ci\ -\ -\ [%T]\ %r\ %ST\ %B\ %hrl'

  $smtp_relay = $::network::params::smtp_relay
  $smtp_port  = $::network::params::smtp_port;

  {
    moo::params::shared_root_path             => '/mnt/moodle',
    moo::params::first_guid                   => 5000,
    moo::params::default_version_tag          => 'latest',
    moo::params::lb                           => undef,
    moo::params::moodle_db_host               => undef,
    moo::params::moodle_db_adm_user           => 'mooadm',
    moo::params::moodle_db_adm_pwd            => undef,
    moo::params::moodle_db_pfx                => undef,
    moo::params::docker_repository            => undef,
    moo::params::default_desired_num          => 2,
    moo::params::moobot_db_host               => undef,
    moo::params::moobot_db_pwd                => undef,
    moo::params::memcached_servers            => undef,
    moo::params::ha_template                  => '/opt/moobot/templates/haproxy.conf.j2',
    moo::params::ha_reload_cmd                => '/opt/moobot/bin/haproxy_graceful_reload',
    moo::params::ha_stats_login               => 'admin',
    moo::params::ha_stats_pwd                 => undef,
    moo::params::ha_log_server                => $ha_log_server,
    moo::params::ha_log_format                => $ha_log_format,
    moo::params::smtp_relay                   => $smtp_relay,
    moo::params::smtp_port                    => $smtp_port,
    moo::params::mongodb_servers              => undef,
    moo::params::replicaset                   => $replicaset,
    moo::params::captain_mysql_rootpwd        => undef,
    moo::params::docker_iface                 => undef,
    moo::params::docker_gateway               => undef,
    # Warning: docker_bridge_cidr_address is the value of
    # the --bip option (from "docker daemon" in the
    # /etc/default/docker file). A value like
    # '172.17.0.0/16' is incorrect because the part before
    # the '/' must be the IP address of the docker0
    # interface.
    moo::params::docker_bridge_cidr_address   => $docker_bridge_cidr_address,
    moo::params::docker_dns                   => $docker_dns,
    moo::params::iptables_allow_dns           => undef,
    moo::params::ceph_account                 => 'cephfs',
    moo::params::ceph_client_mountpoint       => '/moodle',
    moo::params::ceph_mount_on_the_fly        => false,
    moo::params::backups_dir                  => '/backups',
    moo::params::backups_retention            => 2,
    moo::params::backups_moodles_per_day      => 2,
    moo::params::make_backups                 => false,


    moo::captain::supported_distributions => [ 'trusty' ],

    moo::cargo::supported_distributions => [ 'trusty' ],

    # lb available for Jessie not for Trusty because we need
    # to haproxy >= 1.5 to have feature concerning the log
    # format.
    moo::lb::supported_distributions => [ 'jessie' ],
  }

}


