class basic_ntp {

  include '::basic_ntp::params'

  [
   $interfaces,
   $servers,
   $subnets_authorized,
   $ipv6,
   $supported_distributions,
  ] = Class['::basic_ntp::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages([ 'ntp' ], { ensure => present, })

  case $::facts['lsbdistcodename'] {
    /^(trusty|jessie)$/: {
      $restrict_options = 'kod notrap nomodify nopeer noquery'
    }
    default: {
      $restrict_options = 'kod notrap nomodify nopeer noquery limited'
    }
  }

  file { '/etc/ntp.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'basic_ntp/ntp.conf.epp',
                    { 'interfaces'         => $interfaces,
                      'subnets_authorized' => $subnets_authorized,
                      'ipv6'               => $ipv6,
                      'servers'            => $servers,
                      'restrict_options'   => $restrict_options,
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


