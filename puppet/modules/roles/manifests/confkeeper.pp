class roles::confkeeper (
  Boolean $no_provider = false,
) {

  # Frequent (per day) puppet runs for a confkeeper collector.
  class { '::puppetagent::params':
    cron => {'per-day' => {}},
  }

  # If this is the first time of the puppet run, there is no
  # collector (the collector will be UP after this first
  # puppet run). So we have to install the collector without
  # the "provider" installation part.
  if $no_provider {
    class { '::roles::generic':
      excluded_classes => ['::confkeeper::provider'],
    }
  } else {
    include '::roles::generic'
  }

  include '::unix_accounts::params'

  $sudoers = $::unix_accounts::params::users.filter |$username, $settings| {
    $is_sudo = ('is_sudo' in $settings) and $settings['is_sudo']
               and ('ssh_authorized_keys' in $settings)
  }

  $allinone_readers = $sudoers.reduce([]) |$memo, $sudoer| {

    [$login, $settings] = $sudoer

    $keyname    = $settings['ssh_authorized_keys'][0]
    $keytype    = $::unix_accounts::params::ssh_public_keys[$keyname]['type']
    $keyvalue   = $::unix_accounts::params::ssh_public_keys[$keyname]['keyvalue']
    $ssh_pubkey = "${keytype} ${keyvalue} ${keyname}"

    $memo + [{'username' => $login, 'ssh_pubkey' => $ssh_pubkey}]

  }

  $cron_all_in_one_name = 'update-all-in-one'

  class { '::confkeeper::collector::params':
    wrapper_cron     => ::roles::wrap_cron_mon($cron_all_in_one_name),
    allinone_readers => $allinone_readers,
  }

  include '::confkeeper::collector'

  # The cron task which updates the all-in-one git
  # repository is launched by git not root, so the file in
  # /usr/local/cron-status/ must be created.
  file { "/usr/local/cron-status/${cron_all_in_one_name}":
    ensure  => 'file',
    owner   => 'git',
    group   => 'staff',
    mode    => '0644',
    require => Class['::confkeeper::collector'],
  }

  # Add a checkpoint.

  $fqdn                        = $::facts['networking']['fqdn']
  $confkeeper_checkpoint_title = "${fqdn} from ${title}"

  $custom_variables = [
    {
      'varname' => '_crons',
      'value'   => {"cron-${cron_all_in_one_name}" => [$cron_all_in_one_name, '1d']},
      'comment' => ["There is a daily update of the all-in-one Git repository (${cron_all_in_one_name})."],
    },
  ]

  $extra_info = {
    'check_dns' => {
      'DNS-external-fqdn' => {
        'fqdn'             => $::confkeeper::collector::params::address,
        'expected-address' => '$HOSTADDRESS$',
      },
    },
  }

  monitoring::host::checkpoint {$confkeeper_checkpoint_title:
    templates        => ['linux_tpl'],
    custom_variables => $custom_variables,
    extra_info       => $extra_info,
  }

}


