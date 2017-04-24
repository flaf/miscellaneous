function httpproxy::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  $supported_distributions = [
                              'xenial',
                             ];

  {
    httpproxy::apt_cacher_ng_adminpwd  => undef,
    httpproxy::apt_cacher_ng_port      => 3142,
    httpproxy::supported_distributions => $supported_distributions,
  }

}


