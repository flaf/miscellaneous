# This function add, if needed, the default settings in
# Confkeeper::GitRepositories hash.
#
function confkeeper::complete_repos_settings (
  Confkeeper::GitRepositories $repositories,
  String[1] $fqdn,
) {

  $repositories.reduce({}) |$memo, $a_repo| {

    [$localdir, $settings] = $a_repo

    # For instance, '/usr/local' becomes 'usr-local'.
    $git_basename = $localdir[1,-1].regsubst('/', '-', 'G');

    $default_settings = {
      'relapath'    => "${fqdn}/${git_basename}.git",
      'permissions' => [{'rights' => 'RW+', 'target' => "root@${fqdn}"}],
      'gitignore'   => [],
    }

    $memo + {$localdir => ($default_settings + $settings)}

  }

}


