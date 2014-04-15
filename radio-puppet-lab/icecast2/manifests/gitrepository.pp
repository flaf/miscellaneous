class icecast2::gitrepository {

  package{ 'git-for-icecast2':
    name   => 'git',
    ensure => present,
  }

  ->

  # ssh key to "git pull" without password.
  exec { 'create-key-ssh':
    user    => 'root',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa',
    unless  => '[ -e ~/.ssh/id_rsa ]',
  }

  ->

  # A ssh wrapper to git clone without fingerprint confirmation.
  file { '/usr/local/sbin/ssh-for-git-clone':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    content => template('icecast2/ssh-for-git-clone.erb'),
  }

  ->

  # Script to retrieve the mountpoints via git pull.
  file { '/usr/local/sbin/retrieve-mountpoints':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    content => template('icecast2/retrieve-mountpoints.erb'),
  }

  ->

  cron { 'retrieve-mountpoints':
    ensure  => present,
    command => '/usr/local/sbin/retrieve-mountpoints',
    user    => 'root',
    minute  => 45,
  }

}
