# * The stats page of haproxy => http://${IP_LB}:8080/haproxy?stats
#
class moo::lb (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)
  require '::moo::common'

  ensure_packages( [ 'haproxy' ], { ensure => present } )

  $content_default_haproxy = @(END)
    ### File managed by Puppet, don't edit it. ###
    ENABLED=1
    | END

  file { '/etc/default/haproxy':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content_default_haproxy,
    require => Package['haproxy'],
    notify  => Service['haproxy']
  }

  # On Trusty, haproxy has a "status" command but the exit
  # code is 0 even if haproxy is not running. The custom
  # command uses pgrep in the "procps" package.
  ensure_packages( [ 'procps' ], { ensure => present } )
  service { 'haproxy':
    ensure     => running,
    hasstatus  => false,
    status     => 'test "$(pgrep -c haproxy)" != 0',
    hasrestart => true,
    enable     => true,
    require    => [ File['/etc/default/haproxy'], Package['procps'] ],
  }

  file_line { 'rsyslog.conf-load-imudp':
    path   => '/etc/rsyslog.conf',
    line   => '$ModLoad imudp # line edited by Puppet',
    match  => '^#?[[:space:]]*\$ModLoad[[:space:]]+imudp.*$',
    notify => Exec['restart-rsyslog'],
  }

  file_line { 'rsyslog.conf-UDPServerRun':
    path   => '/etc/rsyslog.conf',
    line   => '$UDPServerRun 514 # line edited by Puppet',
    match  => '^#?[[:space:]]*\$UDPServerRun[[:space:]]+.*$',
    notify => Exec['restart-rsyslog'],
  }

  exec { 'restart-rsyslog':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    command     => 'service rsyslog restart',
    refreshonly => true,
  }

}


