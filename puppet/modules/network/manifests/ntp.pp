class network::ntp (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::network::params'
  $interfaces         = $::network::params::ntp_interfaces
  $ntp_servers        = $::network::params::ntp_servers
  $subnets_authorized = $::network::params::ntp_subnets_authorized
  $ipv6               = $::network::params::ntp_ipv6

  ensure_packages(['ntp', ], { ensure => present, })

  file { '/etc/ntp.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'network/ntp.conf.epp',
                    { 'interfaces'         => $interfaces,
                      'subnets_authorized' => $subnets_authorized,
                      'ipv6'               => $ipv6,
                      'ntp_servers'        => $ntp_servers,
                    }
                  ),
    require => Package['ntp'],
    before  => Service['ntp'],
    notify  => Service['ntp'],
  }

  # Warning: when ipv6 is disable on ntp, generally
  #          the command `ntpq -pn` works no longer
  #          and you need to use `ntpq -4pn` instead.
  if $ipv6 {
    $ntpd_opts='-g'
  } else {
    $ntpd_opts='-4 -g'
  }

  $content_of_default_ntp = @("END")
    ### This file is managed by Puppet, don't edit it. ###
    NTPD_OPTS='${ntpd_opts}'

    | END

  file { '/etc/default/ntp':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content_of_default_ntp,
    require => Package['ntp'],
    before  => Service['ntp'],
    notify  => Service['ntp'],
  }

  $adjust      = 'timeout --signal=TERM --kill-after=5s 20s ntpd -gq; sleep 0.5'
  $start_cmd   = "${adjust}; ${adjust}; service ntp start"
  $restart_cmd = "service ntp stop; ${adjust}; ${adjust}; service ntp start"

  service { 'ntp':
    ensure    => running,
    hasstatus => true,
    restart   => $restart_cmd,
    start     => $start_cmd,
  }

}


