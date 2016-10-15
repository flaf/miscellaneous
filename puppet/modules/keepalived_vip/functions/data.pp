function keepalived_vip::data {

  {
    # The "vrrp_instances" parameter will use the "deep"
    # merging (it's a hash). But "deep" merging is
    # impossible if the data() value is undef (it raises an
    # error). The value {} (ie an empty hash) could be
    # possible as data() value but it's too risky. It's
    # better to have an error if the "vrrp_instances"
    # parameter is not provided in hiera. So there is no
    # value which is given in the data() function, even the
    # undef value.
    #
    #keepalived_vip::params::vrrp_instances         => undef,
    keepalived_vip::params::vrrp_scripts            => {},
    keepalived_vip::params::cron_check_vip          => false,
    keepalived_vip::params::cron_check_cmd          => '/usr/local/bin/check-vip',
    keepalived_vip::params::supported_distributions => [ 'trusty', 'jessie' ],

    # Merging policy.
    lookup_options => {
      keepalived_vip::params::vrrp_instances => { merge => 'deep', },
    }

  }

}


