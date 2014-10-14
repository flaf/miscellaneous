class profiles::ceph {

  include apt

  $ceph_release = "firefly"

  apt::source { 'ceph':
    location    => "http://ceph.com/debian-${ceph_release}/",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '17ED316D',
    include_src => false,
  }

  if ! defined(Package['ceph']) {
    package { 'ceph':
      ensure  => present,
      require => Apt::Source['ceph'],
  }

}

