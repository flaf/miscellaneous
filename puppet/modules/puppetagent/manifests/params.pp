class puppetagent::params (
  Boolean                                 $service_enabled,
  String[1]                               $runinterval,
  String[1]                               $server,
  String[1]                               $ca_server,
  Enum['per-day', 'per-week', 'disabled'] $cron,
  String[1]                               $puppetconf_path,
  Boolean                                 $manage_puppetconf,
  String[1]                               $ssldir,
  String[1]                               $bindir,
  String[1]                               $etcdir,
) {
}


