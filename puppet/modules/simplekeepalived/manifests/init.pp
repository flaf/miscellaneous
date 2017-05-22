class simplekeepalived {

  include '::simplekeepalived::params'

  [
    $virtual_router_id,
    $interface,
    $priority,
    $nopreempt,
    $auth_pass,
    $virtual_ipaddress,
    $track_script,
    $supported_distributions,
    $default_track_script,
  ] = Class['::simplekeepalived::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ::homemade::fail_if_undef($virtual_router_id, 'simplekeepalived::params::virtual_router_id', $title)
  ::homemade::fail_if_undef($auth_pass, 'simplekeepalived::params::auth_pass', $title)
  ::homemade::fail_if_undef($virtual_ipaddress, 'simplekeepalived::params::virtual_ipaddress', $title)

  $virtual_ipaddress_array = $virtual_ipaddress.reduce([]) |$memo, $entry| {
    $cidr        = $entry['address']
    $label       = $entry['label']
    $dump        = ::network::dump_cidr($cidr)
    $broadcast   = $dump['broadcast']
    $netmask_num = $dump['netmask_num']

    if ($netmask_num == 32) or ($netmask_num == 128) {
      # Broadcast has no sense in this case.
      $line = "${cidr} dev ${interface} label ${interface}:${label}"
    } else {
      $line = "${cidr} broadcast ${broadcast} dev ${interface} label ${interface}:${label}"
    };

    $memo + [$line]
  }

  $track_script_final = case $track_script {
    NotUndef: { $default_track_script + $track_script }
    default:  { undef                                 }
  }

  ensure_packages(['keepalived'], {ensure => present})

  file {'/etc/keepalived/keepalived.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['keepalived'],
    notify  => Service['keepalived'],
    content => epp(
                 'simplekeepalived/keepalived.conf.epp',
                 {
                   'virtual_router_id' => $virtual_router_id,
                   'interface'         => $interface,
                   'priority'          => $priority,
                   'nopreempt'         => $nopreempt,
                   'auth_pass'         => $auth_pass,
                   'virtual_ipaddress' => $virtual_ipaddress_array,
                   'track_script'      => $track_script_final,
                 },
               ),
  }

  service { 'keepalived':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

}


