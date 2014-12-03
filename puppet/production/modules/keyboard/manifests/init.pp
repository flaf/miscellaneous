# Class: keyboard
#
# Public class which allow to only configure the keyboard.
# Depends on Puppetlabs-stdlib.
#
# Parameters:
# - $xkbmodel: the value of XKBMODEL in the /etc/default/keyboard file.
#   Default value is 'pc105'.
# - $xkblayout: the value of XKBLAYOUT in the /etc/default/keyboard file.
#   Default value is 'fr'.
# - $xkbvariant: the value of XKBVARIANT in the /etc/default/keyboard file.
#   Default value is 'latin9'.
# - $xkboptions: the value of XKBOPTIONS in the /etc/default/keyboard file.
#   Default value is '' (empty string).
# - $backspace: the value of BACKSPACE in the /etc/default/keyboard file.
#   Default value is 'guess'.
#
# Sample Usages:
#
#   include '::keyboard'
#
# or
#
#   class { '::keyboard':
#     xkbmodel   => 'pc105',
#     xkblayout  => 'fr',
#     xkbvariant => 'latin9',
#   }
#
class keyboard (
  $stage      = 'basis',
  $xkbmodel   = 'pc105',
  $xkblayout  = 'fr',
  $xkbvariant = 'latin9',
  $xkboptions = '',
  $backspace  = 'guess',
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # Check parameters.
  unless is_string($xkbmodel) and (! empty($xkbmodel)) {
    fail("Problem in class ${title}, the `xkbmodel` must be a non empty string.")
  }
  unless is_string($xkblayout) and (! empty($xkblayout)) {
    fail("Problem in class ${title}, the `xkblayout` must be a non empty string.")
  }
  unless is_string($xkbvariant) and (! empty($xkbvariant)) {
    fail("Problem in class ${title}, the `xkbvariant` must be a non empty string.")
  }
  unless is_string($xkboptions) {
    fail("Problem in class ${title}, the `xkboptions` must be a string.")
  }
  unless is_string($backspace) and (! empty($backspace)) {
    fail("Problem in class ${title}, the `backspace` must be a non empty string.")
  }

  file { '/etc/default/keyboard':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('keyboard/keyboard.erb'),
  }

  case $::lsbdistcodename {
    wheezy: {
      $command = 'service keyboard-setup restart'
    }
    trusty: {
      $command = 'dpkg-reconfigure --frontend=noninteractive keyboard-configuration'
    }
    default: {
      # Do nothing, change will be enabled in the next reboot.
      $command = 'true'
    }
  }

  exec { 'update-keyboard-conf':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => $command,
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/default/keyboard'],
    subscribe   => File['/etc/default/keyboard'],
  }

}

