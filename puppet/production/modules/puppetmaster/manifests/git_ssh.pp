class puppetmaster::git_ssh {

  private("Sorry, ${title} is a private class.")

  $environment_path = $::puppetmaster::environment_path
  $hieradata_dir    = "${environment_path}/production/hieradata"

  $git_repo = $::puppetmaster::hiera_git_repository
  $git_host = inline_template('<%= @git_repo.gsub(/(^.*?@|:.*$)/, "") %>')

  # The ssh key.
  exec { 'create-key-ssh':
    user    => 'root',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => 'ssh-keygen -t rsa -b 4096 -N "" -f /root/.ssh/id_rsa',
    unless  => '[ -e /root/.ssh/id_rsa ]',
    before  => File['/root/.ssh/known_hosts'],
  }

  file { '/root/.ssh/known_hosts':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    before => Exec['add-repo-host-to-known-hosts'],
  }

  exec { 'add-repo-host-to-known-hosts':
    command => "ssh-keyscan -T 20 -t rsa ${git_host} >>/root/.ssh/known_hosts",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "grep -q '^${git_host} ' /root/.ssh/known_hosts",
    before  => Exec['git-clone'],
  }

  # I don't know why but, if the "git clone" fails, the target
  # directory is removed. So the command below recreate the
  # directory if it has been removed. But the return value of
  # these command is the return value of the `git clone` command.
  $cmd_git_clone = "git clone '${git_repo}' '${hieradata_dir}'; rt=\$?\n\
[ ! -d '${hieradata_dir}' ] && mkdir '${hieradata_dir}'\n\
exit \$rt"

  exec { 'git-clone':
    command => $cmd_git_clone,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  =>  "test -d '${hieradata_dir}/.git'"
  }

}


