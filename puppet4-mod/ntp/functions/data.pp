function ntp::data {

  # TODO: it's a bug https://tickets.puppetlabs.com/browse/PUP-5209
  #       Be careful because currently the README of the ntp module
  #       doesn't tell the truth.
  #
  #$ntp_servers = ::network::get_ntp_servers();
  #
  $ntp_servers = [ '0.debian.pool.ntp.org',
                   '1.debian.pool.ntp.org',
                   '2.debian.pool.ntp.org',
                   '3.debian.pool.ntp.org',
                 ];

  { ntp::interfaces              => 'all',
    ntp::ntp_servers             => $ntp_servers,
    ntp::subnets_authorized      => 'all',
    ntp::ipv6                    => false,
    ntp::supported_distributions => [ 'trusty', 'jessie' ],
  }

}


