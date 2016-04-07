define ppbackup::mcrypt_user (
  String[1] $user = $title,
  String[1] $home = $user ? { 'root' => '/root/', default => "/home/${user}", },
  String[1] $password,
  String[1] $algorithm = 'rijndael-256',
) {

  include '::ppbackup'

  ensure_packages( [ 'mcrypt' ], { ensure => present } )

  file { "${home}/.mcryptrc":
    ensure  => present,
    owner   => "${user}",
    group   => "${user}",
    mode    => '0600',
    content => "algorithm ${algorithm}\nkey ${password}\n",
    require => Package['mcrypt'],
  }



}


