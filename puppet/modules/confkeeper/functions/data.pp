function confkeeper::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  {
    confkeeper::collector::params::supported_distributions => ['xenial'],
  }

}


