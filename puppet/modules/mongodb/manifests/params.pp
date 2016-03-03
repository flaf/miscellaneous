class mongodb::params (
  Array[String[1], 1]                                 $bind_ip,
  Variant[Integer[1], String[1]]                      $port,
  Boolean                                             $auth,
  String[1]                                           $replset,
  Boolean                                             $smallfiles,
  Optional[ String[1] ]                               $keyfile = undef,
  Boolean                                             $quiet,
  Integer                                             $log_level,
  Enum[ '/var/log/mongodb/mongodb.log', '/dev/null' ] $logpath,
  Hash[String[1], Array[Data, 1]]                     $databases,
) {
}


