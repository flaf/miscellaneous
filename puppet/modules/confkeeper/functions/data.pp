function confkeeper::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $default_collection   = 'all'
  $fqdn                 = $::facts['networking']['fqdn']
  $etckeeper_ssh_pubkey = $::facts.dig('etckeeper_ssh_pubkey')
  $ssh_host_pubkey      = $::facts.dig('ssh', 'rsa', 'key')
  $provider_sd          = [
                           'trusty',
                           'jessie',
                           'xenial',
                          ]

  # By default, repositories are /etc, /usr/local and /opt
  # with almost default settings.
  $default_repositories = {
    '/etc'       => {'gitignore' => undef},
    '/usr/local' => {},
    '/opt'       => {'gitignore' => ['/puppetlabs/']}, # exclude /opt/puppetlabs/
  };

  {
    confkeeper::collector::params::collection                => $default_collection,
    confkeeper::collector::params::address                   => $fqdn,
    confkeeper::collector::params::ssh_host_pubkey           => $ssh_host_pubkey,
    confkeeper::collector::params::wrapper_cron              => undef,
    confkeeper::collector::params::hour_range_cron           => [5, 6],
    confkeeper::collector::params::additional_exported_repos => {},
    confkeeper::collector::params::allinone_readers          => [],
    confkeeper::collector::params::supported_distributions   => ['xenial'],

    confkeeper::provider::params::collection              => $default_collection,
    confkeeper::provider::params::repositories            => $default_repositories,
    confkeeper::provider::params::wrapper_cron            => undef,
    confkeeper::provider::params::hour_range_cron         => [18, 23],
    confkeeper::provider::params::devnull_cron            => true,
    confkeeper::provider::params::fqdn                    => $fqdn,
    confkeeper::provider::params::etckeeper_ssh_pubkey    => $etckeeper_ssh_pubkey,
    confkeeper::provider::params::supported_distributions => $provider_sd,

    # Merging policy.
    lookup_options => {
      confkeeper::provider::params::repositories => {merge => 'hash'},
    },

  }

}


