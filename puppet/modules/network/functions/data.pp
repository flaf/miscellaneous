function network::data {

  $supported_distribs = [ 'trusty', 'jessie' ];

  {

    # Default values of network::params are defined in the
    # class network::params itself. Indeed, some defaults
    # values depend on the value of another parameters of
    # the same class.

    network::supported_distributions              => $supported_distribs,
    network::resolv_conf::supported_distributions => $supported_distribs,
    network::hosts::supported_distributions       => $supported_distribs,

    # Merging policy.
    lookup_options => {
      network::params::inventory_networks => { merge => 'deep', },
      network::params::hosts              => { merge => 'deep', },
    },

  }

}


