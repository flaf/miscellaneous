function httpproxy::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $domain                  = $::facts['networking']['domain']
  # Minimal SquidGuard configuration "do nothing".
  $default_squidguard_conf  = {
    'acl' => {
      'default' => {
        'pass' => 'all',
      }
    }
  }
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

    httpproxy::params::enable_puppetforgeapi   => false,
    httpproxy::params::puppetforgeapi_fqdn     => "puppetforgeapi.${domain}",

    httpproxy::params::enable_squidguard       => true,
    httpproxy::params::squid_allowed_networks  => [],
    httpproxy::params::squid_port              => 3128,
    httpproxy::params::squidguard_conf         => $default_squidguard_conf,
    httpproxy::params::squidguard_admin_email  => "admin@${domain}",

    httpproxy::params::supported_distributions => $supported_distributions,
  }

}


