class autoupgrade::params (
  Boolean             $apply,
  Data                $hour,
  Data                $minute,
  Data                $monthday,
  Data                $month,
  Data                $weekday,
  Boolean             $reboot,
  Boolean             $puppet_run,
  String[1]           $puppet_bin,
  Array[String[1], 1] $supported_distributions,
) {

  $autoupgrade_script          = '/usr/local/sbin/cron-auto-upgrade.puppet'
  $puppet_run_at_reboot_script = '/usr/local/sbin/cron-puppet-run-at-reboot.puppet'
  $flag_puppet_run_at_reboot   = '/usr/local/etc/cron-puppet-run-at-reboot'
  $logfile                     = '/root/auto-upgrade.log'

}


