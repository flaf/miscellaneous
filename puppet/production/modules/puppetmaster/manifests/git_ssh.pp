class puppetmaster::git_ssh {

  private("Sorry, ${title} is a private class.")

  # The ssh key.
  exec { 'create-key-ssh':
    user    => 'root',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => 'ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa',
    unless  => '[ -e /root/.ssh/id_rsa ]',
  }

}


