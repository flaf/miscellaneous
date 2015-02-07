class profiles::users::generic {

  $users = hiera_hash('users')
  validate_non_empty_data($users)

  # Installation of sudo if not yet done.
  ensure_packages(['sudo'], { ensure => present, })

  # The handle of the root account is specific.
  if has_key($users, 'root') {

    $root = $users['root']

    if has_key($root, 'password') {

      user { 'root':
        password => $root['password'],
      }

    }

  }




  if versioncmp($puppetversion, '3.6') >= 0 {
    $purge_ssh_keys = true
  } else {
    $purge_ssh_keys = undef
  }

  user { 'test-pour-voir':
    name           => 'flaf',
    ensure         => present,
    comment        => 'Francois Lafont',
    managehome     => true,
    password       => $pwd,
    purge_ssh_keys => $purge_ssh_keys,
    shell          => '/bin/bash',
    system         => false,
    groups         => ['sudo'],
    # groups ?
    # home   ?
  }

  ssh_authorized_key { 'nick@magpie.puppetlabs.lan':
    user => 'flaf',
    type => 'ssh-rsa',
    key  => $pub_key,
  }

}

x
