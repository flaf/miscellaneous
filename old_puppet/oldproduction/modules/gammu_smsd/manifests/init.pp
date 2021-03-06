# Class: gammu_smsd
#
# Tested with Debian Wheezy and the 3G dongle "Huawei E1750".
# /!\ The PIN code in the SIM card must be disabled. /!\.
# This class installs and configures the 'gammu-smsd' package
# with the 'files' backend for the storage of SMS.
# Old files in the backend are cleaned with a cron task.
# You can send SMS with the command:
#
#   gammu-smsd-inject TEXT 0666666666 -text "Hello world."
#
# as root or as account which is member of "gammu" group.
# The class provides a command in /usr/local/sbin/ to
# start and restart the "gammu-smsd" service.
#
# Parameters:
# - $dongle_device, default value is '/dev/ttyUSB0'
#   (Unfortunately the device name is difficult to guess safely.)
# - $phones_to_test, default value is false.
#   If not false, this parameter must be a non empty array
#   of phone numbers like [ '0612345678', '0698765432' ].
#   In this case, for each number, a SMS will be sent
#   at 11:59 AM to check that gammu-smsd is working well.
# - $web_service, default value is false.
#   If the value is true, then apache2 is installed and
#   it's possible to send SMS with curl:
#       curl --data "phone=0666666666"          \
#            --data "msg=Hello, how do you do?" \
#            http://<address>/cgi-bin/sendsms.pl
# - $limit_access, default value is false.
#   You can set this parameter to a non empty array
#   of IP addresses which will be allowed to access to
#   the service. For instance [ '172.31.0.1', '172.31.0.2' ].
#   With the default value (ie false), it's "Allow from all".
#
# Sample Usages:
#
#  include 'gammu_smsd'
#
#  class { 'gammu_smsd':
#    dongle_device  => '/dev/ttyUSB1',
#    phones_to_test => [ '0612345678', '0698765432' ],
#    $web_service   => true,
#    limit_access   => [ 'localhost', '172.31.0.1' ],
#  }
#
class gammu_smsd (
  $dongle_device  = '/dev/ttyUSB0',
  $phones_to_test = false,
  $web_service    = false,
  $limit_access   = false,
) {

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

  # It's a wrapper of the init script because (re)starting
  # of gammu-smsd is a little sensitive.
  file { '/usr/local/sbin/wgammu-smsd.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0754,
    source => "puppet:///modules/${module_name}/wgammu-smsd.sh",
  }

  service { 'gammu-smsd':
    ensure     => running,
    hasrestart => false,
    hasstatus  => false,
    start      => '/usr/local/sbin/wgammu-smsd.sh start',
    restart    => '/usr/local/sbin/wgammu-smsd.sh restart',
    status     => '/usr/local/sbin/wgammu-smsd.sh status',
    require    => [ File['/etc/gammu-smsdrc'],
                    File['/usr/local/sbin/wgammu-smsd.sh'],
                  ],
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

  if $phones_to_test {

    file { '/usr/local/bin/phones_to_test.sh':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0755,
      content => template("${module_name}/phones_to_test.sh.erb"),
      require => Service['gammu-smsd'],
    }

    cron { 'phones-to-test':
      ensure  => present,
      command => '/usr/local/bin/phones_to_test.sh',
      user    => 'gammu',
      minute  => 59,
      hour    => 11,
      require => [ Service['gammu-smsd'],
                   File['/usr/local/bin/phones_to_test.sh'],
                 ],
    }

  }

  if $web_service {
    include '::gammu_smsd::web_service'
  }

}

