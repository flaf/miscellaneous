# Internal class to manage the installation and the
# configuration of the moobot package.
#
class moo::common (
  Moo::MoobotConf $moobot_conf,
) {

  ensure_packages( [ 'moobot' ], { ensure => present } )

  file { '/opt/moobot/etc/moobot.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Package['moobot'],
    content => epp('moo/moobot.conf.epp', { 'moobot_conf' => $moobot_conf }),
  }

  file { '/opt/moobot/templates/haproxy.conf.j2':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['moobot'],
    content => epp('moo/haproxy.conf.j2.epp'),
  }

}


