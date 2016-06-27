# * The stats page of haproxy => http://${IP_LB}:8080/haproxy?stats
#
class moo::lb (
  Array[String[1], 1] $supported_distributions,
) {

  # Warning
  #
  # In the file /etc/rsyslog.d/49-haproxy.conf by default on
  # Jessie, there is the discard action (tilde character).
  # It is deprecated:
  #
  # http://www.rsyslog.com/doc/v8-stable/compatibility/v7compatibility.html#omruleset-and-discard-action-are-deprecated
  #
  #    The discard action (tilde character) has been
  #    replaced by the "stop" RainerScript directive. It is
  #    considered more intuitive and offers slightly better
  #    performance.
  #
  # But it's probably better to leave this file in the
  # "debian" default version. It works and we have just a
  # message in syslog which tells the discard action is
  # deprecated.

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $moobot_conf = $::moo::lb::params::moobot_conf

  class { '::moo::common':
    moobot_conf => $moobot_conf,
  }

  # The package "netcat-openbsd" is useful to send requests
  # to the haproxy socket file.
  ensure_packages( [ 'haproxy', 'netcat-openbsd' ], { ensure => present } )

  # The content is not managed (it's managed by moobot),
  # only the UniX permissions.
  file { '/etc/haproxy/haproxy.cfg':
    ensure => present,
    owner   => 'haproxy',
    group   => 'haproxy',
    mode    => '0640',
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  service { 'haproxy':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [ Package['haproxy'], File['/etc/haproxy/haproxy.cfg'] ],
  }

  # Now, we need to redirect http to https with a basic
  # Nginx server.
  ensure_packages( [ 'nginx-light' ], { ensure => present } )

  $content_nginx = @(END)
    ### File managed by Puppet, don't edit it. ###

    server {
        # Normally, haproxy uses already the ports 80 and 8080.
        listen 8000;
        # Redirect to the same url with https
        # (301 <=> Moved Permanently).
        return 301 https://$http_host$request_uri;
    }

    | END

  file { '/etc/nginx/sites-available/default':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content_nginx,
    require => Package['nginx-light'],
    notify  => Service['nginx']
  }

  service { 'nginx':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => File['/etc/nginx/sites-available/default'],
  }

#  #########################################
#  ### Deprecated, was needed for Trusty ###
#  #########################################
#
#  if $::facts['os']['distro']['codename'].downcase == 'trusty' {
#
#    $content_default_haproxy = @(END)
#      ### File managed by Puppet, don't edit it. ###
#      ENABLED=1
#      | END
#
#    file { '/etc/default/haproxy':
#      owner   => 'root',
#      group   => 'root',
#      mode    => '0644',
#      content => $content_default_haproxy,
#      require => Package['haproxy'],
#      notify  => Service['haproxy']
#    }
#
#    # On Trusty, haproxy has a "status" command but the exit
#    # code is 0 even if haproxy is not running. The custom
#    # command uses pgrep in the "procps" package.
#    ensure_packages( [ 'procps' ], { ensure => present } )
#    service { 'haproxy':
#      ensure     => running,
#      hasstatus  => false,
#      status     => 'test "$(pgrep -c haproxy)" != 0',
#      hasrestart => true,
#      enable     => true,
#      require    => [ File['/etc/default/haproxy'], Package['procps'] ],
#    }
#
#    file_line { 'rsyslog.conf-load-imudp':
#      path   => '/etc/rsyslog.conf',
#      line   => '$ModLoad imudp # line edited by Puppet',
#      match  => '^#?[[:space:]]*\$ModLoad[[:space:]]+imudp.*$',
#      notify => Exec['restart-rsyslog'],
#    }
#
#    file_line { 'rsyslog.conf-UDPServerRun':
#      path   => '/etc/rsyslog.conf',
#      line   => '$UDPServerRun 514 # line edited by Puppet',
#      match  => '^#?[[:space:]]*\$UDPServerRun[[:space:]]+.*$',
#      notify => Exec['restart-rsyslog'],
#    }
#
#    exec { 'restart-rsyslog':
#      path        => '/usr/sbin:/usr/bin:/sbin:/bin',
#      user        => 'root',
#      command     => 'service rsyslog restart',
#      refreshonly => true,
#    }
#
#  }
#  #########################################

}


