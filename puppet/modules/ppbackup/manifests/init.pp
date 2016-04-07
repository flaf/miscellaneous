class ppbackup {

  # It's the result of this command:
  #
  #   mkpasswd --method=sha-512 --salt="$(openssl rand -hex 8)" "backup"
  #
  # So "backup" is the password. But we don't care here because
  # the password will be locked below.
  #
  $pwd = '$6$dcf5365f2a53c3b5$V17cV7d7TywPju3TvOnvcSSrfEDbb63MyLurxISdfjZEQyROfc2KfJomM0OyrT417.4z56uMzIrgA73/dIask.'

  user { 'ppbackup':
    name           => 'ppbackup',
    ensure         => present,
    expiry         => absent,
    managehome     => true,
    home           => '/home/ppbackup',
    password       => "!${pwd}", # <= password locked with "!".
    shell          => '/bin/bash',
    system         => false,
    purge_ssh_keys => true,
  }

}


