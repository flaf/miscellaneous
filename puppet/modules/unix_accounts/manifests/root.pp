# Internal class.
#
class unix_accounts::root {

  include '::unix_accounts::params'

  $users = $::unix_accounts::params::users

  # Normally, if this class is called, the value
  # $users['root'] should have the right structure.

  $root     = $users['root']
  $password = $root['password']

  user { 'root':
    name           => 'root',
    ensure         => present,
    home           => '/root',
    password       => $password,
    purge_ssh_keys => true,
  }

}


