function network::data {

  $supported_distribs = [ 'trusty', 'xenial', 'jessie' ]
  $sd = 'supported_distributions';

  {

    # Default values of network::*params are defined in the
    # class network::*params directly. Indeed, some defaults
    # values depend on the value of another parameters of
    # the same class.
    #
    # Currently, the only exception is
    # network::basic_router::params which uses the classical
    # design where default values are set in this function.

  "network::params::${sd}"                                  => $supported_distribs,
  "network::resolv_conf::params::${sd}"                     => $supported_distribs,
  "network::hosts::params::${sd}"                           => $supported_distribs,
  "network::basic_router::params::${sd}"                    => $supported_distribs,
   network::basic_router::params::masqueraded_networks      => [],
   network::basic_router::params::masqueraded_output_ifaces => [],

    # Merging policy.
    lookup_options => {
      network::params::inventory_networks                      => { merge => 'deep', },
      network::hosts::params::entries                          => { merge => 'deep', },
      network::basic_router::params::masqueraded_networks      => { merge => 'unique', },
      network::basic_router::params::masqueraded_output_ifaces => { merge => 'unique', },
    },

  }

}


