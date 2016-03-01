class moo::common  {

  if !defined(Class['::moo::params']) { include '::moo::params' }

  $shared_root_path    = $::moo::params::shared_root_path
  $first_guid          = $::moo::params::first_guid
  $default_version_tag = $::moo::params::default_version_tag
  $lb                  = $::moo::params::lb
  $moodle_db_host      = $::moo::params::moodle_db_host
  $moodle_db_adm_user  = $::moo::params::moodle_db_adm_user
  $moodle_db_adm_pwd   = $::moo::params::moodle_db_adm_pwd
  $moodle_db_pfx       = $::moo::params::moodle_db_pfx
  $docker_repository   = $::moo::params::docker_repository
  $default_desired_num = $::moo::params::default_desired_num
  $moobot_db_host      = $::moo::params::moobot_db_host
  $moobot_db_pwd       = $::moo::params::moobot_db_pwd
  $memcached_servers   = $::moo::params::memcached_servers
  $ha_template         = $::moo::params::ha_template
  $ha_reload_cmd       = $::moo::params::ha_reload_cmd
  $ha_stats_login      = $::moo::params::ha_stats_login
  $ha_log_server       = $::moo::params::ha_log_server
  $ha_log_format       = $::moo::params::ha_log_format
  $ha_stats_pwd        = $::moo::params::ha_stats_pwd
  $smtp_relay          = $::moo::params::smtp_relay
  $smtp_port           = $::moo::params::smtp_port
  $mongodb_servers     = $::moo::params::mongodb_servers
  $replicaset          = $::moo::params::replicaset

  [
    'lb',
    'moodle_db_host',
    'moodle_db_adm_pwd',
    'moodle_db_pfx',
    'docker_repository',
    'moobot_db_host',
    'moobot_db_pwd',
    'memcached_servers',
    'ha_stats_pwd',
    'ha_log_server',
    'mongodb_servers',
  ].each |$var_name| {
    ::homemade::fail_if_undef( getvar($var_name), "moo::params::${var_name}",
                               $title )
  }

  require '::repository::moobot'
  ensure_packages( [ 'moobot' ], { ensure => present } )

  file { '/opt/moobot/etc/moobot.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Package['moobot'],
    content => epp('moo/moobot.conf.epp',
                   {
                    'shared_root_path'    => $shared_root_path,
                    'first_guid'          => $first_guid,
                    'default_version_tag' => $default_version_tag,
                    'lb'                  => $lb,
                    'moodle_db_host'      => $moodle_db_host,
                    'moodle_db_adm_user'  => $moodle_db_adm_user,
                    'moodle_db_adm_pwd'   => $moodle_db_adm_pwd,
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
                    'ha_log_server'       => $ha_log_server,
                    'smtp_relay'          => $smtp_relay,
                    'smtp_port'           => $smtp_port,
                    'mongodb_servers'     => $mongodb_servers,
                    'replicaset'          => $replicaset,
                   },
                  ),
  }

  file { '/opt/moobot/templates/haproxy.conf.j2':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['moobot'],
    content => epp('moo/haproxy.conf.j2.epp',
                   {
                     'ha_log_format' => $ha_log_format,
                   },
                  ),
  }

}


