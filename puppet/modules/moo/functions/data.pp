function moo::data {

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

    moo::captain::mysql_rootpwd           => sha1("$r-mysql_rootpwd_moobot")[0,15],
    moo::captain::supported_distributions => [ 'trusty' ],

    moo::cargo::ceph_account            => 'cephfs',
    moo::cargo::ceph_client_mountpoint  => '/moodle',
    moo::cargo::supported_distributions => [ 'trusty' ],

    moo::lb::supported_distributions => [ 'trusty' ],
  }

}


