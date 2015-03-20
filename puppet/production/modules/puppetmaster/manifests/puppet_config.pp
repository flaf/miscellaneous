class puppetmaster::puppet_config {

  private("Sorry, ${title} is a private class.")

  exec { 'create-key-ssh':
    user    => 'root',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => 'ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa',
    unless  => '[ -e /root/.ssh/id_rsa ]',
  }

  file { '/puppet':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

}


