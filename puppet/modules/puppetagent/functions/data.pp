function puppetagent::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  # Warning: the $server_facts will be defined for the node
  #          only if the parameter `trusted_server_facts`
  #          is set to true in the puppet.conf of the server.
  if $::server_facts {
    $server = $::server_facts['servername']
  } else {
    $server = 'puppet'
  }

  $etcdir = '/etc/puppetlabs/puppet'
  $bindir = '/opt/puppetlabs/puppet/bin'
  $sd     = 'supported_distributions';

  {
    puppetagent::params::service_enabled   => false,
    puppetagent::params::runinterval       => '7d',
    puppetagent::params::server            => $server,
    puppetagent::params::ca_server         => '$server',
    puppetagent::params::cron              => 'per-week',
    puppetagent::params::puppetconf_path   => "${etcdir}/puppet.conf",
    puppetagent::params::manage_puppetconf => true,
    puppetagent::params::dedicated_log     => true,
    puppetagent::params::ssldir            => "${etcdir}/ssl",
    puppetagent::params::bindir            => $bindir,
    puppetagent::params::etcdir            => $etcdir,
   "puppetagent::params::${sd}"            => [
                                               'trusty',
                                               'xenial',
                                               'jessie',
                                              ],
  }

}


