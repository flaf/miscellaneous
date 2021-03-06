type Moo::MoobotConf = Struct[{
  'main'      => Struct[{
    'shared_root_path'    => String[1],
    'first_guid'          => Integer[1],
    'default_version_tag' => String[1],
  }],
  'jobs'      => Struct[{
    'update_lb'           => Array[String[1], 1],
  }],
  'docker'    => Struct[{
    'db_host'             => String[1],
    'db_adm_user'         => String[1],
    'db_adm_password'     => String[1],
    'db_pfx'              => String[1],
    'repository'          => String[1],
    'default_desired_num' => Integer[1],
    'smtp_relay'          => String[1],
    'smtp_port'           => Integer[1],
  }],
  'database'  => Struct[{
    'host'                => String[1],
    'name'                => Enum['moobot'],
    'user'                => Enum['moobot'],
    'password'            => String[1],
  }],
  'memcached' => Struct[{
    'servers'             => Array[String[1], 1],
  }],
  'mongodb'        => Struct[{
    'servers'             => Array[String[1], 1],
    'replicaset'          => String[1],
  }],
  'haproxy'   => Struct[{
    'template'            => Enum['/opt/moobot/templates/haproxy.conf.j2'],
    'reload_cmd'          => Enum['/opt/moobot/bin/haproxy_graceful_reload'],
    'stats_login'         => String[1],
    'stats_password'      => String[1],
    'log_server'          => String[1],
    'log_format'          => String[1],
  }],
  'backup'    => Struct[{
    'path'                => String[1],
    'exceptions'          => String[1],
    'db_retention'        => Integer[1],
    'filedir_retention'   => Integer[1],
  }],
}]


