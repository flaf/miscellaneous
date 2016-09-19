function rsyncd::check_params (
  Rsyncd::Modules $modules,
  Rsyncd::Users   $users,
  String[1]       $title,
) {

  $modules.each |$module_name, $settings| {
    if 'auth_users' in $settings {
      $settings['auth_users'].each |$a_user| {
        unless $a_user in $users {
          @("END"/L$).fail
            Class ${title}: in the rsync-module `${module_name}` the user \
            `${a_user}` in the `auth users` option is not present in the \
            `\$users` parameter.
            |-END
        }
      }
    }
  }

}


