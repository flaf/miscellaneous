function network::data {

  $supported_distribs = [ 'trusty', 'jessie' ]
  $sd = 'supported_distributions';

  {

    # Default values of network::*params are defined in the
    # class network::*params directly. Indeed, some defaults
    # values depend on the value of another parameters of
    # the same class.

   "network::params::${sd}"              => $supported_distribs,
   "network::resolv_conf::params::${sd}" => $supported_distribs,
   "network::hosts::params::${sd}"       => $supported_distribs,

    # Merging policy.
    lookup_options => {
      network::params::inventory_networks => { merge => 'deep', },
      network::hosts::params::entries     => { merge => 'deep', },
    },

  }

}


