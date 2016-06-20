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
    'name'                => String[1],
    'user'                => String[1],
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
    'template'            => String[1],
    'reload_cmd'          => String[1],
    'stats_login'         => String[1],
    'stats_password'      => String[1],
    'log_server'          => String[1],
  }],
}]


