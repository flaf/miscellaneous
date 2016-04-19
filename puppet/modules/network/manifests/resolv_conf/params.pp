# $dns_servers can be undef for instance in a DHCP network
# where /etc/resolv.conf is not managed by default.
#
class network::resolv_conf::params (
  String[1]                       $domain                        = $::domain,
  Array[String[1], 1]             $search                        = ::network::get_param(
                                                                     $::network::params::interfaces,
                                                                     $::network::params::inventory_networks,
                                                                     'dns_search',
                                                                     [$::domain] ),
  Integer[1]                      $timeout                       = 5,
  Boolean                         $override_dhcp                 = false,
  Optional[ Array[String[1], 1] ] $dns_servers                   = ::network::get_param(
                                                                     $::network::params::interfaces,
                                                                     $::network::params::inventory_networks,
                                                                     'dns_servers'),
  Boolean                         $local_resolver                = true,
  Array[String[1]]                $local_resolver_interface      = [],
  Array[ Array[String[1], 2, 2] ] $local_resolver_access_control = [],
  Array[String[1], 1]             $supported_distributions,
) inherits ::network::params {

  ::homemade::is_supported_distrib($supported_distributions, $title)

}


