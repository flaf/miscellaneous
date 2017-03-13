define repository::sourceslist (
  String[1]           $id = $title,
  String[1]           $comment,
  String[1]           $location,
  String[1]           $release,
  Array[String[1], 1] $components,
  Boolean             $src,
  Boolean             $apt_update = true,
) {

  file { "/etc/apt/sources.list.d/${id}.list":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('repository/sourceslist.epp',
                 {
                  'comment'    => $comment,
                  'location'   => $location,
                  'release'    => $release,
                  'components' => $components,
                  'src'        => $src,
                 }
               ),
  }

  if $apt_update {
    exec { "${id}-apt-update":
      command     => 'apt-get update',
      user        => 'root',
      group       => 'root',
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      logoutput   => 'on_failure',
      refreshonly => true,
      timeout     => 40,
      tries       => 1,
      try_sleep   => 2,
      subscribe   => File["/etc/apt/sources.list.d/${id}.list"],
    }
  }

}


