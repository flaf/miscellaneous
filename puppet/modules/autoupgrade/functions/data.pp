function autoupgrade::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $seed                    = 'upgradereboot-puppet-module'
  $supported_distributions = [
                               'trusty',
                               'jessie',
                               'xenial',
                             ];

  {
    autoupgrade::apply                   => false,
    autoupgrade::hour                    => fqdn_rand(6, $seed),  # from 0 to 5.
    autoupgrade::minute                  => fqdn_rand(60, $seed), # from 0 to 59.
    autoupgrade::monthday                => absent,               # ie * (any day of the month).
    autoupgrade::month                   => absent,               # ie * (any month).
    autoupgrade::weekday                 => fqdn_rand(7, $seed),  # from 0 to 6.
    autoupgrade::reboot                  => true,
    autoupgrade::puppet_run              => true,
    autoupgrade::puppet_bin              => '/opt/puppetlabs/bin/puppet',
    autoupgrade::supported_distributions => $supported_distributions,
  }
}


