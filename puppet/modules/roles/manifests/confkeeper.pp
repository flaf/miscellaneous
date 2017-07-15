class roles::confkeeper (
  Boolean $first_time = false,
) {

  # If this is the first time of the puppet run, there is no
  # collector (the collector will be UP after this first
  # puppet run). So we have to install the collector without
  # the "provider" installation part.
  if $first_time {
    class { '::roles::generic':
      excluded_classes => 'confkeeper::provider',
    }
  } else {
    include '::roles::generic'
  }

  include '::unix_accounts::params'

  $sudoers = $::unix_accounts::params::users.filter |$username, $settings| {
    $is_sudo = ('is_sudo' in $settings) and $settings['is_sudo'] and ('ssh_authorized_keys' in $settings)
  }

  $allinone_readers = $sudoers.reduce([]) |$memo, $sudoer| {

    [$login, $settings] = $sudoer

    $keyname   = $settings['ssh_authorized_keys'][0]
    $keytype   = $::unix_accounts::params::ssh_public_keys[$keyname]['type']
    $keyvalue  = $::unix_accounts::params::ssh_public_keys[$keyname]['keyvalue']
    $ssh_pubkey = "${keytype} ${keyvalue} ${keyname}"

    $memo + [{'username' => $login, 'ssh_pubkey' => $ssh_pubkey}]

  }

  class { '::confkeeper::collector::params':
    wrapper_cron     => ::roles::wrap_cron_mon('collect-all-git-repos'),
    allinone_readers => $allinone_readers,
  }

  include '::confkeeper::collector'

}


