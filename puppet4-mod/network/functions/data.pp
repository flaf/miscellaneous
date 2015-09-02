function network::data {

  $v = lookup('azertyhfdhfjkdh');
  #$v = lookup('network::interfaces::restart_network');

  {
    network::interfaces::restart_network => false,
    #network::interfaces::interfaces      => $v,
    network::interfaces::interfaces      => {
                                              'eth0' => {
                                                          'method' => 'dhcp',
                                                        },
                                            },
    network::interfaces::supported_distributions => ['trusty', 'jessie'],
  }

}


