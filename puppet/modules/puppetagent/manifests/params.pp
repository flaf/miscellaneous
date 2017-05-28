class puppetagent::params (
  Boolean             $service_enabled,
  String[1]           $runinterval,
  String[1]           $server,
  String[1]           $ca_server,
  Puppetagent::Cron   $cron,
  String[1]           $puppetconf_path,
  Boolean             $manage_puppetconf,
  Boolean             $dedicated_log,
  String[1]           $ssldir,
  String[1]           $bindir,
  String[1]           $etcdir,
  Array[String[1], 1] $supported_distributions,
) {

  # It's not a parameter of the module but it's an internal
  # value which is can be useful if present here. One day,
  # maybe this internal value could be useful in another
  # puppet module.
  $file_flag_puppet_cron = "${etcdir}/no-run-via-cron"

  $dedicated_log_file = '/var/log/puppet-agent.log'

  # The command to reload rsyslog after a log rotation.
  $reload_rsyslog_cmd = case $::facts['os']['distro']['codename'] {
    "trusty": {
      'reload rsyslog >/dev/null 2>&1 || true'
    }
    default: {
      # Currently, this is the command in Jessie and Xenial.
      'invoke-rc.d rsyslog rotate > /dev/null'
    }
  }

}


