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
  $docker_dns                 = [];

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

    moo::params::moobot_conf => $moobot_conf,

    # Merging policy.
    lookup_options => {
       moo::cargo::params::moobot_conf   => { merge => 'deep', },
       moo::captain::params::moobot_conf => { merge => 'deep', },
       moo::lb::params::moobot_conf      => { merge => 'deep', },
       moo::params::moobot_conf          => { merge => 'deep', },
    },

  }

}


