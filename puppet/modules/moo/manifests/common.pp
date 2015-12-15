class moo::common (
  String[1]           $shared_root_path,
  Integer[5000]       $first_guid,
  String[1]           $default_version_tag,
  Array[String[1], 1] $lb,
  String[1]           $moodle_db_host,
  String[1]           $moodle_adm_user,
  String[1]           $moodle_adm_pwd,
  String[1]           $moodle_db_pfx,
  String[1]           $docker_repository,
  Integer[1]          $default_desired_num,
  String[1]           $moobot_db_host,
  String[1]           $moobot_db_pwd,
  Array[String[1], 1] $memcached_servers,
  String[1]           $ha_template,
  String[1]           $ha_reload_cmd,
  String[1]           $ha_stats_login,
  String[1]           $ha_stats_pwd,
) {

  if $lb[0] == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the mandatory parameter `lb` is not defined.
      |- END
  }
  if $memcached_servers[0] == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the mandatory parameter `memcached_servers` is not defined.
      |- END
  }
  [ 'moodle_db_host', 'docker_repository' ].each |$param| {
    if getvar($param) == 'NOT-DEFINED' {
      regsubst(@("END"), '\n', ' ', 'G').fail
        $title: sorry the mandatory parameter `$param` is not defined.
        |- END
    }
  }

  require '::repository::moobot'
  ensure_packages( [ 'moobot' ], { ensure => present } )

  file { '/opt/moobot/etc/moobot.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    require => Package['moobot'],
    content => epp('moo/moobot.conf.epp',
                   {
                    'shared_root_path'    => $shared_root_path,
                    'first_guid'          => $first_guid,
                    'default_version_tag' => $default_version_tag,
                    'lb'                  => $lb,
                    'moodle_db_host'      => $moodle_db_host,
                    'moodle_adm_user'     => $moodle_adm_user,
                    'moodle_adm_pwd'      => $moodle_adm_pwd,
                    'moodle_db_pfx'       => $moodle_db_pfx,
                    'docker_repository'   => $docker_repository,
                    'default_desired_num' => $default_desired_num,
                    'moobot_db_host'      => $moobot_db_host,
                    'moobot_db_pwd'       => $moobot_db_pwd,
                    'memcached_servers'   => $memcached_servers,
                    'ha_template'         => $ha_template,
                    'ha_reload_cmd'       => $ha_reload_cmd,
                    'ha_stats_login'      => $ha_stats_login,
                    'ha_stats_pwd'        => $ha_stats_pwd,
                   },
                  ),
  }

}


