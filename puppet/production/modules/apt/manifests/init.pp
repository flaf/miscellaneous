class apt {

  define source_list ($content) {

    file { "/etc/apt/sources.list.d/$title.list":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0644,
      content => $content,
      notify  => Exec['apt-get update'],
    }

    ->

    exec { 'apt-get update':
      path        => '/usr/sbin:/usr/bin:/sbin:/bin',
      command     => 'apt-get update',
      user        => 'root',
      refreshonly => true,
    }

  }

}


