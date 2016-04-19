function basic_ntp::data {

  $default_ntp = [
                  '0.debian.pool.ntp.org',
                  '1.debian.pool.ntp.org',
                  '2.debian.pool.ntp.org',
                  '3.debian.pool.ntp.org',
                 ]

  $supported_distribs = [ 'trusty', 'jessie' ]
  $sd                 = 'supported_distributions';

  {
    basic_ntp::params::interfaces         => 'all',
    basic_ntp::params::servers            => $default_ntp,
    basic_ntp::params::subnets_authorized => 'all',
    basic_ntp::params::ipv6               => false,
   "basic_ntp::params::${sd}"             => $supported_distribs,
  }

}


