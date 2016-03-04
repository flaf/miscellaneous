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

  # It's not a parameter of the module but it's an internal
  # value which is can be useful if present here. One day,
  # maybe this internal value could be useful in another
  # puppet module.
  $file_flag_puppet_cron = "${etcdir}/no-run-via-cron"

}


