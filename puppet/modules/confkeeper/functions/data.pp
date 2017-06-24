function confkeeper::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $default_collection = 'confkeeper-git'
  $provider_sd        = [
                          'trusty',
                          'jessie',
                          'xenial',
                        ];

  {
    confkeeper::collector::params::collection              => $default_collection,
    confkeeper::collector::params::supported_distributions => ['xenial'],

    confkeeper::provider::params::collection              => $default_collection,
    confkeeper::provider::params::supported_distributions => $provider_sd,
  }

}


