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
    autoupgrade::params::apply                   => false,
    autoupgrade::params::hour                    => fqdn_rand(6, $seed),  # from 0 to 5.
    autoupgrade::params::minute                  => fqdn_rand(60, $seed), # from 0 to 59.
    autoupgrade::params::monthday                => absent,               # ie * (any day of the month).
    autoupgrade::params::month                   => absent,               # ie * (any month).
    autoupgrade::params::weekday                 => fqdn_rand(7, $seed),  # from 0 to 6.
    autoupgrade::params::reboot                  => true,
    autoupgrade::params::commands_before_reboot  => [],
    autoupgrade::params::puppet_run              => true,
    autoupgrade::params::puppet_bin              => '/opt/puppetlabs/bin/puppet',
    autoupgrade::params::upgrade_wrapper         => undef,
    autoupgrade::params::supported_distributions => $supported_distributions,
  }
}


