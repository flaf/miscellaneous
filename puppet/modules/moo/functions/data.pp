function moo::data {

  # Some default values in moobot.conf.
  $moobot_conf = {
    'main' => {
      'shared_root_path'    => '/mnt/moodle',
      'first_guid'          => 5000,
      'default_version_tag' => 'latest',
    },
    'docker' => {
      'db_adm_user'         => 'mooadm',
      'default_desired_num' => 2,
      'smtp_port'           => 25,
    },
    'database' => {
      'name' => 'moobot',
      'user' => 'moobot',
    },
    'haproxy' => {
      'template'    => '/opt/moobot/templates/haproxy.conf.j2',
      'reload_cmd'  => '/opt/moobot/bin/haproxy_graceful_reload',
      'stats_login' => 'admin',
      'log_format'  => '%{+Q}o\ %{-Q}b\ %{-Q}ci\ -\ -\ [%T]\ %r\ %ST\ %B\ %hrl'
                         .regsubst('%{', '%{literal("%")}{', 'G'),
    },
  }

  # Warning: docker_bridge_cidr_address is the value of the
  # --bip option (from "docker daemon" in the
  # /etc/default/docker file). A value like '172.17.0.0/16'
  # is incorrect because the part before the '/' must be the
  # IP address of the docker0 interface.
  $docker_bridge_cidr_address = '172.19.0.1/24'

  $docker_dns = [];

### Part below too complicated for too little gain.
### We remove this part.
#
#
#  $has_local_resolver = $::network::params::local_resolver
#
#  # We want to have smart values for these parameters:
#  #
#  #   - $docker_dns
#  #   - $docker_bridge_cidr_address
#  #
#  # ie values related with the parameters of ::network::params.
#  #
#  if $has_local_resolver {
#
#    # The host has a local resolver installed. It could be
#    # smart that docker containers can use it.
#    $listening_addr_resolver = $::network::params::local_resolver_interface
#
#    # We remove the "localhost" addresses in the array.
#    $remaining_addr = $listening_addr_resolver.filter |$a_addr| {
#      $a_addr !~ /^127\./ and $a_addr != 'localhost'
#    }
#
#    # If $remaining_addr is empty, $docker_dns will be empty too
#    # and we let docker choose the DNS addresses.
#    $docker_dns = $remaining_addr
#
#    # For the "docker" network, if it exists, we choose the
#    # first network in access-control == 'allow' in the conf
#    # of the local resolver.
#    $access_control = $::network::params::local_resolver_access_control
#    $remaining_net  = $access_control.filter |$a_access| {
#      $a_access[1] == 'allow'
#    }
#    if $remaining_net.empty {
#      # No network available, we take this default network.
#      $docker_bridge_cidr_address = '172.17.0.1/16'
#    } else {
#      # We choose the first network in this array.
#      $docker_bridge_cidr_address = $remaining_net[0][0]
#    }
#
#  } else {
#
#    # No local resolver, so we let docker choose the DNS addresses
#    # and the docker network will have this value below.
#    $docker_dns                 = []
#    $docker_bridge_cidr_address = '172.17.0.1/16'
#
#  }
#
####
####

  {
    moo::cargo::params::moobot_conf                => $moobot_conf,
    moo::cargo::params::docker_iface               => undef,
    moo::cargo::params::docker_bridge_cidr_address => $docker_bridge_cidr_address,
    moo::cargo::params::docker_dns                 => $docker_dns,
    moo::cargo::params::docker_gateway             => undef,
    moo::cargo::params::iptables_allow_dns         => false,
    moo::cargo::params::ceph_account               => 'cephfs',
    moo::cargo::params::ceph_client_mountpoint     => '/moodle',
    moo::cargo::params::ceph_mount_on_the_fly      => false,
    moo::cargo::params::backups_dir                => '/backups',
    moo::cargo::params::backups_retention          => 2,
    moo::cargo::params::backups_moodles_per_day    => 2,
    moo::cargo::params::make_backups               => false,
    moo::cargo::supported_distributions            => [ 'trusty' ],

    moo::captain::params::moobot_conf     => $moobot_conf,
    moo::captain::params::mysql_rootpwd   => undef,
    moo::captain::supported_distributions => [ 'trusty' ],

    moo::lb::params::moobot_conf     => $moobot_conf,
    moo::lb::supported_distributions => [ 'jessie' ],
    # lb available for Jessie not for Trusty because we need
    # to haproxy >= 1.5 to have feature concerning the log
    # format.

    # Merging policy.
    lookup_options => {
       moo::cargo::params::moobot_conf => { merge => 'deep', },
    },

  }

}


