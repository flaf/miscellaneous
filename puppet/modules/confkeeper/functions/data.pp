function confkeeper::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $default_collection   = 'all'
  $fqdn                 = $::facts['networking']['fqdn']
  $default_repositories = {
    '/etc' => {
      'relapath'    => "${fqdn}/etc.git",
      'permissions' => [{'rights' => 'RW+', 'target' => "root@${fqdn}"}],
    },
  }
  $etckeeper_ssh_pubkey = $::facts.dig('etckeeper_ssh_pubkey')
  $ssh_host_pubkey      = $::facts.dig('ssh', 'rsa', 'key')
  $provider_sd          = [
                           'trusty',
                           'jessie',
                           'xenial',
                          ];

  # TODO: add a filter tag (filter_tag) parameter in the collector::params class.

  {
    confkeeper::collector::params::collection              => $default_collection,
    confkeeper::collector::params::address                 => $fqdn,
    confkeeper::collector::params::ssh_host_pubkey         => $ssh_host_pubkey,
    confkeeper::collector::params::supported_distributions => ['xenial'],

    confkeeper::provider::params::collection              => $default_collection,
    confkeeper::provider::params::repositories            => $default_repositories,
    confkeeper::provider::params::etckeeper_ssh_pubkey    => $etckeeper_ssh_pubkey,
    confkeeper::provider::params::supported_distributions => $provider_sd,

    # Merging policy.
    lookup_options => {
      confkeeper::provider::params::repositories => {merge => 'hash'},
    },

  }

}


