#==Action
#
# Install an Icecast2 server. Tested with Debian Wheezy.
# See the hiera configuration to have more details.
#
# /!\ After the installation of Icecast2, you must
#     finish the installation manually if you use
#     a git repository for the mountpoints configuration
#     (see the hiera conf below):
#
#  a) you must put manually the ssh root public key
#     (/root/.ssh/id_rsa.pub) in the git repository to
#     allow read only access to root (= "git clone" and
#     "git pull").
#
#  b) it will be probably more prudent to make a backup
#     of the mountpoints configuration file
#     (/etc/icecast2/mountpoints/mountpoints.xml).
#
# Bacic scheme to keep in mind:
#
#      sends audio stream to a     +---------------+
#      mountpoint of the server    |               |
#               +--------<<<-------+ Source client |
#               |                  |               |
#         +-----+----+             +---------------+
#         | Icecast2 |
#         |  server  |
#         +--+----+--+             +----------+
#            |    |                |          |
#  receive   |    +------->>>------+ listener |
#  the audio |                     |          |
#  stream of |      +----------+   +----------+
#  server    |      |          |
#            +->>>--+ listener |
#                   |          |
#                   +----------+
#
# /!\ This puppet class depends on: /!\
# - repositories::webradio to add a repository made in CRDP with
#   icecast2 version 2.3.3 and an important security patch.
# - generate_password function to avoid to put clear text passwords in hiera.
#   You can can use clear text passwords or the __pwd__ syntax in hiera.
#
#
# Below, here are explanations about the hiera configuration:
#
# * location: visible on the server info page of the icecast web interface.
#             This entry is optional. The default value is "$datacenter" if
#             defined else it's "$fqdn".
#
# * official_admin_password: visible on the server info page of the icecast
#                            web interface. This entry is optional. The default
#                            value is "$admin_email" if defined else it's
#                            "$admin@$fqdn".
#
# * git_repository: the ssh url of the git repository of the mountpoints.
#                   This entry is optional and the default value is empty,
#                   ie icecast2 doesn't use a git repository (in this case
#                   all the configuration is in the icecast.xml template).
#                   If not empty, ssh public and private keys are generate
#                   by root. The public key (/root/.ssh/id_rsa.pub) must be
#                   manually put in the git repository to allow read only
#                   access. In this case, root will run a "git pull" every
#                   hour.
#
# * admins_mails: address mails to notify when the icecast configuration
#                 is updated (because there are new mountpoints via the
#                 git repository). The mails indicate if icecast server
#                 has well restarted (or if not). The mails give the new
#                 list of the enabled mountpoints too.
#                 This entry, which must be an array, is optional. The
#                 default value is an empty arry, ie no notification.
#
# * source_password: the password of the default username (called 'source') for all
#                    source connections. It can be changed in the individual mount
#                    sections. The password of the 'relay' username is automatically
#                    set to the same value. This entry is optional and the default is
#                    '__pwd__{"salt" => ["$fqdn", "source"], "nice" => true, "max_length" => 10 }'.
#                    So, you can use the '__pwd__{...}' syntax to avoid clear passwords.
#
# * admin_password: admin password in the web administration interface. This entry
#                   is optional and the default value is
#                   '__pwd__{"salt" => ["$fqdn", "admin"], "nice" => true, "max_length" => 10 }'.
#
# * ports: this is the listening ports of icecast. This entry is optional, but,
#          if present, must be an array of string numbers. The default value is
#          [ '8000' ].
#
# * limits_clients: max connections for the entire server (not per mountpoint).
#                   This entry is optional and the default value is 100.
#
# * limits_sources: max number of connected sources supported by the server.
#                   This entry is optional and the default value is 10.
#
# * limits_source_timeout: if source does not send any data within this timeout
#                          period (in seconds), then the source connection is
#                          removed from the server. This entry is optional and
#                          the default value is 10.
#
# * log_level: 4=Debug, 3=Info, 2=Warn, 1=Error. This entry is optional and the
#              default value is 3. This is the minimal recommended value. Indeed,
#              with log_level 2 or 1, icecast don't log in /var/icecast2/error.log
#              the beginning of the source connection and the end.
#
# * log_size: log size in KBytes. If a log file is grower than the log size,
#             then "mv <filename>.log <filename>.log.<datestamp>".
#             Every night, all files older than 1 year are deleted. (in fact,
#             among the files the mtime of which is older than 1 year, all the
#             files are removed except the youngest which can contain information
#             newer than 1 year). This entry is optional and the default value
#             is 10000 (ie 10 MB).
#
#
#==Hiera
#
#icecast2:
#  location: 'Lesseps'
#  official_admin_mail: 'admin@world-compagny.tld'
#  git_repository: git@gitlab.domain.tld:bob/web-radio.git
#  admins_mails:
#    - 'alice@domain.tld'
#    - 'bob@domain.tld'
#  source_password: '__pwd__{"salt" => ["$fqdn", "source"], "nice" => true, "max_length" => 8 }'
#  admin_password: '__pwd__{"salt" => ["$fqdn", "admin"], "nice" => true, "max_length" => 8 }'
#  ports: [ '80', '8000' ]
#  limits_clients: 200
#  limits_sources: 20
#  limits_source_timeout: 20
#  log_level: 3
#  log_size: 10000
#
#
class icecast2 {

  require 'repositories::webradio'
  require 'icecast2::params'

  $location              = $icecast2::params::location
  $official_admin_mail   = $icecast2::params::official_admin_mail
  $git_repository        = $icecast2::params::git_repository
  $git_directory         = $icecast2::params::git_directory
  $git_lockfile          = $icecast2::params::git_lockfile
  $mountpoints_file      = $icecast2::params::mountpoints_file
  $admins_mails          = $icecast2::params::admins_mails
  $source_password       = $icecast2::params::source_password
  $admin_password        = $icecast2::params::admin_password
  $ports                 = $icecast2::params::ports
  $limits_clients        = $icecast2::params::limits_clients
  $limits_sources        = $icecast2::params::limits_sources
  $limits_source_timeout = $icecast2::params::limits_source_timeout
  $log_level             = $icecast2::params::log_level
  $log_size              = $icecast2::params::log_size

  if ($git_repository != '') {
    include 'icecast2::gitrepository'
  }

  package { 'icecast2':
    ensure => present,
    notify => Service['icecast2'],
  }

  ->

  file { '/etc/icecast2/icecast.xml.puppet':
    ensure  => present,
    owner   => 'icecast2',
    group   => 'icecast',
    mode    => 660,
    content => template('icecast2/icecast.xml.puppet.erb'),
    notify  => Service['icecast2'],
  }

  ->

  file { '/etc/default/icecast2':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('icecast2/icecast2.default.erb'),
    notify  => Service['icecast2'],
  }

  ->

  file { '/usr/local/bin/print_mountpoints':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    content => template('icecast2/print_mountpoints.erb'),
  }

  ->

  file { '/usr/local/sbin/icecast-service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    content => template('icecast2/icecast-service.erb'),
  }

  ->

  exec { 'update-icecast-conf':
    user    => 'root',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => '/usr/local/sbin/icecast-service update-conf',
    unless  => '/usr/local/sbin/icecast-service is-updated',
    notify  => Service['icecast2'],
  }

  ->

  service { 'icecast2':
    # The return value of The icecast2 init script is false.
    # Must use a specific script to start/restart/status.
    hasrestart => false,
    hasstatus  => false,
    status     => '/usr/local/sbin/icecast-service status',
    start      => '/usr/local/sbin/icecast-service start',
    restart    => '/usr/local/sbin/icecast-service restart',
    ensure     => running,
  }

  ->

  # Script to remove old logs (logs which contain information older than 1 year).
  file { '/usr/local/bin/remove-old-icecast-logs':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    content => template('icecast2/remove-old-icecast-logs.erb'),
  }

  ->

  # At 2:00 a.m, removing of old logs.
  cron { 'remove-old-icecast-logs':
    ensure  => present,
    command => '/usr/local/bin/remove-old-icecast-logs >/dev/null 2>&1',
    user    => 'icecast2',
    minute  => 0,
    hour    => 2,
  }


}


