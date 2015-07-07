function network::data {

  {
    network::interfaces::restart_network => false,
    network::interfaces::interfaces      => {
                                              'eth0' => {
                                                          'method' => 'dhcp',
                                                        },
                                            },
    network::interfaces::supported_distributions => ['trusty', 'jessie'],
  }

}


