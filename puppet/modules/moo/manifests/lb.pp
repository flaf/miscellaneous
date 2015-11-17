# TODO:
#
# * The stats page of haproxy => http://${IP_LB}:8080/haproxy?stats
#
# * In /etc/haproxy/haproxy.cfg, move:
#
#            stats refresh 5
#            stats auth admin:wawa
#
#   From the defaults section to the "listen admin" section.
#
# * Use the fqdn for the backend stanza to have a stats page
#   more readable.
#
class moo::lb (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::moo::common::packages'

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

  service { 'haproxy':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
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


