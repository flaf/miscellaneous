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
    'backup'  => {
      'path'              => '/backups',
      'exceptions'        => '^(dev[0-9]+|test|backup)$',
      'db_retention'      => 10,
      'filedir_retention' => 10,
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
    moo::cargo::params::backup_cmd                 => '/opt/moobot/maintenance/backup_moodle',
    moo::cargo::params::make_backups               => false,
    moo::cargo::supported_distributions            => [ 'trusty' ],

    moo::captain::params::moobot_conf     => $moobot_conf,
    moo::captain::params::mysql_rootpwd   => undef,
    moo::captain::params::backup_cmd      => '/opt/moobot/maintenance/dump_captain_database 100',
    moo::captain::supported_distributions => [ 'trusty' ],

    moo::lb::params::moobot_conf         => $moobot_conf,
    moo::lb::params::redirect_http2https => false,
    moo::lb::supported_distributions => [ 'jessie' ],
    # lb available for Jessie not for Trusty because we need
    # to haproxy >= 1.5 to have feature concerning the log
    # format.

    moo::quickwproxy::params::listen                  => [],
    moo::quickwproxy::params::public_domain           => $::domain,
    moo::quickwproxy::params::proxy_pass_address      => "moolb-vip.${::domain}",
    moo::quickwproxy::params::ssl_cert                => undef,
    moo::quickwproxy::params::ssl_key                 => undef,
    moo::quickwproxy::params::supported_distributions => [ 'trusty' ],

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


