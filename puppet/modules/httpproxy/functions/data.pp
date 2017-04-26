function httpproxy::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $domain = $::facts['networking']['domain']

  $supported_distributions = [
                              'xenial',
                             ];

  {
    httpproxy::params::enable_apt_cacher_ng    => true,
    httpproxy::params::apt_cacher_ng_adminpwd  => undef,
    httpproxy::params::apt_cacher_ng_port      => 3142,

    httpproxy::params::enable_keyserver        => true,
    httpproxy::params::keyserver_fqdn          => $::facts['networking']['fqdn'],
    httpproxy::params::pgp_pubkeys             => [],

    httpproxy::params::enable_puppetforgeapi   => true,
    httpproxy::params::puppetforgeapi_fqdn     => "puppetforgeapi.${domain}",

    httpproxy::params::supported_distributions => $supported_distributions,
  }

}


