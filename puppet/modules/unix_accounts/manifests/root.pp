# Internal class.
#
class unix_accounts::root (
  String[1] $stage = 'main',
) {

  $params_class = '::unix_accounts::params'
  if !defined(Class[$params_class]) { include $params_class }
  $users = $::unix_accounts::params::users

  # Normally, if this class is called, the value
  # $users['root']['password'] should always exist.

  unless ($users =~ Hash) and ('root' in $users) {
    @("END"/$).regsubst('\n', ' ', 'G').fail
      ${title} (internal class): the variable
      `\$::unix_accounts::params::user` must be a hash
      with the 'root' key.
      |- END
  }

  $root = $users['root']

  unless ($root =~ Hash) and ('password' in $root)
  and ($root['password'] =~ String[1]) {
    @("END"/$).regsubst('\n', ' ', 'G').fail
      ${title} (internal class): the value of
      `\$::unix_accounts::params::user['root']` must be a hash
      with the 'password' key and this key must be a non-empty string.
      |- END
  }

  $password = $root['password']

  user { 'root':
    name           => 'root',
    ensure         => present,
    home           => '/root',
    password       => $password,
    purge_ssh_keys => true,
  }

}


