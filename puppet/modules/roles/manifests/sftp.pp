class roles::sftp {

  ensure_packages(['openssh-server', ], { ensure => present, })

  group { 'sftp':
    ensure => present,
    system => true,
  }

#  include '::unix_accounts::params'
#
#  #  Get users member of the sftp group
#  $sftp_users = $::unix_accounts::params::users.filter |$username, $settings| {

#    ('supplementary_groups' in $settings) and ('www-data' in $settings['supplementary_groups'])

#  }.reduce([]) |$memo, $entry| {

#    [ $username, $settings ] = $entry
#
#    if $username != 'root' {
#      # Assuming the home directory is there ...
#      file { "/home/${username}":
#        ensure  => directory,
#        owner   => 'root',
#        group   => 'root',
#        mode    => '0750',
#        require => User[$username],
#      }
#    }
#       
#  }  

  file_line { 'edit-subsystem-sftp':
    path    => '/etc/ssh/sshd_config',
    line    => "Subsystem	sftp	/usr/lib/openssh/sftp-server",
    match   => '^#?[[:space:]]*Subsystem[[:space:]]*sftp.*$',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  file_line { 'edit-match-group-sftp':
    path    => '/etc/ssh/sshd_config',
    line    => 'Match Group sftp',
    #line    => "Match Group sftp\n ChrootDirectory /home/%u\n ForceCommand internal-sftp\n X11Forwarding no\n AllowTcpForwarding no\n",
    match   => '^Match Group sftp.*',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  file_line { 'edit-match-group-sftp-chrootDirectory':
    path    => '/etc/ssh/sshd_config',
    line    => ' ChrootDirectory /home',
    match   => '^ ChrootDirectory /home',
    after   => '^Match Group sftp',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  file_line { 'edit-match-group-sftp-forcecommand':
    path    => '/etc/ssh/sshd_config',
    line    => ' ForceCommand internal-sftp',
    match   => '^ ForceCommand internal-sftp',
    after   => '^ ChrootDirectory /home',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  file_line { 'edit-match-group-sftp-x11forwarding':
    path    => '/etc/ssh/sshd_config',
    line    => ' X11Forwarding no',
    match   => '^ X11Forwarding no',
    after   => '^ ForceCommand internal-sftp',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  file_line { 'edit-match-group-sftp-allowtcpforwarding':
    path    => '/etc/ssh/sshd_config',
    line    => ' AllowTcpForwarding no',
    match   => '^ AllowTcpForwarding no',
    after   => '^ X11Forwarding no',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

}


