class gammu_smsd (
  $dongle_device = '/dev/ttyUSB0',
) {

  # Currently, the class is just tested on Wheezy with the
  # 3G dongle "Huawei E1750".
  case $::lsbdistcodename {
    wheezy: {}
    default: {
      fail("Currently, module ${module_name} has never been tested on ${::lsbdistcodename}.")
    }
  }

  if ! defined(Package['usb-modeswitch']) {
    package { 'usb-modeswitch':
      ensure => present,
    }
  }

  if ! defined(Package['gammu-smsd']) {
    package { 'gammu-smsd':
      ensure  => present,
      require => Package['usb-modeswitch'],
    }
  }

  file { '/etc/gammu-smsdrc':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Package['gammu-smsd'],
    content => template("${module_name}/gammu-smsdrc.erb"),
    notify  => Service['gammu-smsd'],
  }

  service { 'gammu-smsd':
    ensure     => running,
    hasrestart => true,
    hasstatus  => false,
    require    => File['/etc/gammu-smsdrc'],
  }

  # Sunday, cleaning of the old files.
  cron { 'remove-old-sms-files':
    environment => 'PATH=/bin:/usr/bin',
    ensure      => present,
    command     => 'find /var/spool/gammu/ -type f -mtime +20 -exec rm -f {} \+',
    user        => 'gammu',
    minute      => 0,
    hour        => 6,
    weekday     => 0,
    require     => Service['gammu-smsd'],
  }

}

